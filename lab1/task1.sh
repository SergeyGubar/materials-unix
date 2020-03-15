#!/bin/bash
# ./task1.sh -h | --help -n num file
# Write all data to file, or to ~/bash/task1.out if it's not specified

check_directory() {
    if [ ! -d $parent_directory ]; then
        echo "Directory $parent_directory does not exist, creating..."
        error_msg=$(mkdir -p "$parent_directory" 2>&1)
    fi
    if [ $? -ne 0 ]; then
        >&2 echo "Error creating directory $parent_directory, reason: $error_msg"
        exit 1
    fi
}

remove_old_files() {
    updated_files_created_before=($(ls -1v "$parent_directory" | grep -E "^$filename_with_date"))
    num_files=${#updated_files_created_before[@]}

    if [ $number_of_files -ne -1 ] && [ $number_of_files -le $num_files ]; then
        for ((i = $num_files - 1; i >= $number_of_files - 1; i--)); do
            file_to_delete="${updated_files_created_before[$i]}"
            echo "Delete $file_to_delete"
            rm -f "$parent_directory/$file_to_delete"
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
    echo "Date: $(date)" > $1 
    echo "---- Hardware ----" >> $1 

    cpu=$(cat /proc/cpuinfo | grep 'model name' | uniq)
    
    if [ -z "$cpu" ]; then
        if [[ $LANG =~ uk_UA ]]; then
            echo "Немає інформації про CPU" 1>&2
            cpu="CPU: Невідомо"
        else
            echo "Failed to fetch CPU info, skipping..." 1>&2
            cpu="CPU: Unknown"
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
            ram="RAM: Unknown"
        fi
    else
        ram="RAM ${ram} MB"
    fi

   echo $ram >> $1

    manufacturer=$(dmidecode --type baseboard | grep Manufacturer: || echo Unknown)
    echo "Manufacturer:${manufacturer#*:}"
    echo "Manufacturer:${manufacturer#*:}" >> $1

    product_name=$(dmidecode -t baseboard | grep -i 'Product name' || echo Unknown)
    echo "Product:${product_name#*:}"
    echo "Product:${product_name#*:}" >> $1

    serial_number=$(dmidecode -t baseboard | grep -i Serial || echo Unkown)
    echo "System Serial Number:$serial_number"
    echo "System Serial Number:$serial_number" >> $1

    echo "---- System ----" >> $1

    os_distribution=$(cat /etc/os-release | grep "PRETTY_NAME" | grep -o -E "\".+\"")
    echo "OS Distribution: $os_distribution"
    echo "OS Distribution: $os_distribution" >> $1

    kernel_version=$(uname -v)
    echo "Kernel version: $kernel_version"
    echo "Kernel version: $kernel_version" >> $1

    created_info=$(dumpe2fs $(mount | grep 'on / ' | awk '{print $1}') | grep 'Filesystem created: ')
    echo $created_info

    if [ -z "$created_info" ]; then
        echo "Installation date - error" 1>&2
        created_info="Unknown"
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
    echo "Uptime $uptime"
    echo "Uptime $uptime" >> $1

    running_proccesses=$(ps aux | wc -l)
    echo "Running processes: $running_proccesses"
    echo "Running processes: $running_proccesses" >> $1

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

if (($# > 3)) ; then
    if [[ $LANG =~ uk_UA ]]; then
        echo "Забагато аргументів" 1>&2
    else
        echo "Too many arguments" 1>&2;
    fi
    exit 1;
fi

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

shift $(($OPTIND - 1))

# Get outfile from args
outFile=$1

# Default n value

if [ -z "$number_of_files" ]; then
    number_of_files=-1
fi

# Default file value

if [ -z "$outFile" ]; then
    outFile="$HOME/bash/task1.out"
fi

parent_directory=$(dirname "$outFile")
file_name=$(basename $outFile)


check_directory

cur_d=$(date "+%Y%m%d")

file_with_date="${outFile}-${cur_d}"
filename_with_date="${file_name}-${cur_d}"

if [ -f "$outFile" ]; then
    # get all files created today with numbers (like 0000)
    all_files_created_before=($(ls -1v "$parent_directory" | grep -E "^$filename_with_date"))
    # number of these files
    num_found=${#all_files_created_before[@]}
    echo $num_found

    if [ $num_found -ne 0 ]; then
        last_created_file_name=${all_files_created_before[$((num_found - 1))]}
        # remove all text, leave only number (0000)
        last_created_number=${last_created_file_name##*-}
        
        new_number=$(expr "$last_created_number" + 1)

        for ((i = $num_found - 1; i >= 0; i--)); do
            new_number_formatted="$(printf "%04d" $new_number)"
            old_file=${all_files_created_before[$i]}
            new_file="${filename_with_date}-${new_number_formatted}"
            
            mv "$parent_directory/$old_file" "$parent_directory/$new_file"

            new_number=$((new_number - 1))
        done   
    fi  

    # move task.out -> task1.out-date-0000 (Initial move)
    mv "$outFile" "$file_with_date-0000"
fi

# Write all data
collect "$outFile"

remove_old_files