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
    echo "Unix Timestamp: $(date +%s)" >> $1
    echo "---- Hardware ----" >> $1 

    cpu=$(cat /proc/cpuinfo | grep 'model name' | uniq)
    
    if [ -z "$cpu" ]; then
        if [[ $LANG =~ uk_UA ]]; then
            echo "Немає інформації про CPU" 1>&2
            cpu="CPU: Невідомо"
        else
            echo "Failed to fetch CPU info, skipping..." 1>&2
            cpu="CPU: \"Unknown\""
        fi
    else
        cpu=${cpu##*:}
        cpu=$(echo $cpu | sed -e 's/^[[:space:]]*//')
        cpu="CPU: \"$cpu\""
    fi
    echo $cpu >> $1

    ram=$(free -m | grep Mem: | awk '{print $2}')

    if [ -z "$ram" ]; then
        if [[ $LANG =~ uk_UA ]]; then
            echo "Немає інформації про RAM" 1>&2
            ram ="RAM: Невідомо"
        else
            echo "Memory info - error" 1>&2
            ram="RAM: "\"Unknown\"""
        fi
    else
        ram="RAM ${ram} MB"
    fi

    echo $ram >> $1

    product_name=$(dmidecode -t baseboard | grep -i 'Product name' || echo "\"Unknown\"")
    echo "Motherboard: ${product_name#*:}"
    echo "Motherboard: ${product_name#*:}" >> $1

    serial_number=$(dmidecode -t baseboard | grep -i Serial || echo "\"Unknown\"")
    echo "System Serial Number: $serial_number"
    echo "System Serial Number: $serial_number" >> $1

    echo "---- System ----" >> $1

    os_distribution=$(lsb_release -a | grep "Description")
    if [ -z "$os_distribution" ]; then
        os_distribution="\"Unknown\""
    else
        os_distribution=${os_distribution##*:}
        os_distribution=$(echo "$os_distribution" | awk '$1=$1')
    fi
    echo "OS Distribution: $os_distribution"
    echo "OS Distribution: $os_distribution" >> $1

    kernel_version=$(uname -v)
    echo "Kernel version: $kernel_version"
    echo "Kernel version: $kernel_version" >> $1

    created_info=$(dumpe2fs $(mount | grep 'on / ' | awk '{print $1}') | grep 'Filesystem created: ')
    echo $created_info

    if [ -z "$created_info" ]; then
        echo "Installation date - error" 1>&2
        created_info="\"Unknown\""
    else
        created_info=${created_info#*:}
        created_info=$(echo $created_info | sed -e 's/^[[:space:]]*//')
    fi

    echo "Installation date: $created_info"
    echo "Installation date: $created_info" >> $1

    hostname=$(hostname)
    echo "Hostname: $hostname"
    echo "Hostname: $hostname" >> $1

    uptime=$(uptime | awk '{print $1}')
    echo "Uptime: $uptime"
    echo "Uptime: $uptime" >> $1

    running_proccesses=$(ps aux | wc -l | awk '$1=$1')
    echo "Processes running: $running_proccesses"
    echo "Processes running: $running_proccesses" >> $1

    host=$(whoami)
    id=$(id -u $host)
    echo "User logged in: $id"
    echo "User logged in: $id" >> $1

    echo "---- Network ----" >> $1

    net_interfaces=($(ip link show | grep -oE '^[0-9]+:\s[^\w]+:' | awk '{print $2}' | sed 's/://'))
    if [ -z "$net_interfaces" ]; then
        echo "Network info - error" 1>&2
        echo "\n" >> $1
    else
        for var in ${net_interfaces[@]}; do
            ip_addr=$(ip addr show "$var" | grep -E 'inet ' | awk '{print $2}')
            if [ -z "$ip_addr" ]; then
                ip_addr='-/-'
            fi
            echo "${var}: ${ip_addr}" >> $1
        done
    fi 
    echo "----EOF----" >> $1

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
        echo "you must specify N" >&2
        exit 1
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
output_file=$3

# Default file value
if [ -z "$output_file" ]; then
    output_file="$HOME/bash/task1.out"
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
    remove_old_files "$filename_with_date" $parent_directory
fi

mv temp.out "$output_file"