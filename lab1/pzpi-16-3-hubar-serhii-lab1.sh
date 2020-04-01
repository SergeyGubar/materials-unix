#!/bin/bash
# ./task1.sh -h | --help -n num file
# Write all data to file, or to ~/bash/task1.out if it's not specified

check_directory() {
    if [ ! -d $1 ]; then
        echo "Directory was not found and will be automatically created."
        mkdir -pv "$1"
    fi
    if [ $? -ne 0 ]; then
        if [[ $LANG =~ uk_UA ]]; then
            echo "Директорію не було створено" 1>&2
        else
            echo "Error creating directory" 1>&2
        fi
        exit 1
    fi
}

remove_old_files() {
    files=($(ls -1v "$2" | grep -E "^$1"))
    length=$(ls -v "$2" | grep -E "^$1" | wc -l)
    # If we have files overflow
    if [ $number_of_files -ne -1 ] && [ $number_of_files -le $length ]; then
        for ((i = $number_of_files - 1; i < $length; i++)); do
            file_to_delete="${files[$i]}"
            rm "$2/$file_to_delete"
            echo "Delete $file_to_delete"
        done
    fi
}

if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    echo "Usage ./task1.sh [-h | --help] [-n num] [file]";
    echo "Script gathers system information and writes it to the [file] option";
    echo "[n] parameter specifies, how many files with the similar name can be in output directory";
    exit 0;
fi

collect() {
    echo "Date: $(date '+%a, %d %b %Y %X %z')" > $1
    echo "Job is done"
}

validate_args() {
    if (($# > 3)) ; then
        if [[ $LANG =~ uk_UA ]]; then
            echo "Забагато аргументів" 1>&2
        else
            echo "Too many arguments" 1>&2;
        fi
        exit 1;
    fi
    if [ -z "$number_of_files" ]; then
        echo "N was not specified" >&2
    fi
}

while getopts "n:" OPTION; do
    if [[ "$OPTARG" =~ ^-?[0-9]+$ ]]; then
        if ! (($OPTARG >= 1)); then
            if [[ $LANG =~ uk_UA ]]; then
                echo "-n має бути числом, більшим за 1" 1>&2
            else
                echo "-n must be an integer > 1, got $OPTARG" >&2
            fi
            exit 1
        else
            number_of_files=$OPTARG
        fi
    else
        if [[ $LANG =~ uk_UA ]]; then
            echo "-n має бути числом" 1>&2
        else
            echo "-n must be an integer, got $OPTARG" >&2
        fi
        exit 1
    fi
done

validate_args

# Get outfile from args

if [ -z $number_of_files ]; then
    output_file=$1
else 
    output_file=$3
fi

# Default file value
if [ -z "$output_file" ]; then
    output_file="$HOME/log/task2.out"
fi


# File rotation
parent_directory=$(dirname "$output_file")
check_directory "$parent_directory"

# Write all data
collect temp.out

if [ -f "$output_file" ]; then
    current_date=$(date "+%Y%m%d")
    file_name=$(basename $output_file)
    filename_with_date="${file_name}-${current_date}"
    # number of files with numbers
    length=$(ls -v "$parent_directory" | grep -E "^$filename_with_date" | wc -l)

    if [ $length -gt 0 ]; then
         # get all files created today with numbers (like 0000)
        all_files_with_numbers=($(ls -v "$parent_directory" | grep -E "^$filename_with_date"))
        last=$((length - 1))
        last_created_file_name=${all_files_with_numbers[$last]}
        # remove all text, leave only last four digits (like 0000)
        last_created_number=($(echo $last_created_file_name | grep -oP "\d{4}$"))
        for ((i = $length - 1; i >= 0; i--)); do
            num=$(($i + 1))            
            new_number_formatted="$(printf "%04d" $num)"
            mv "$parent_directory/${all_files_with_numbers[$i]}" "$parent_directory/${filename_with_date}-${new_number_formatted}"
        done
    fi

    # move task.out -> task1.out-date-0000 (last move)
    mv "$output_file" "${output_file}-${current_date}-0000"

    if [ ! -z $number_of_files ]; then
        remove_old_files "$filename_with_date" $parent_directory
    fi
    
fi

mv temp.out "$output_file"
echo "Out file ${output_file}"