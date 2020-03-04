#!/bin/bash
# ./task1.sh -h | --help -n num file
# Write all data to file, or to ~/bash/task1.out if it's not specified

print_error() {
    >&2 echo "$1"
    exit 1
}

if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
  echo "Usage ./task1.sh [-h | --help] [-n num] [file]";
  exit 0;
fi

collectInfo() {
    echo "Date: $(date)" > $1 
    echo "---- Hardware ----" >> $1 

    cpu=$(cat /proc/cpuinfo | grep 'model name' | uniq)
    
    if [ -z $cpu ]; then
        >&2 echo "Failed to fetch CPU info, skipping..."
        cpu="CPU: Unknown"
    else
        cpu="CPU: $cpu"
    fi
    echo $cpu >> $1

    ram=$(free -m | grep Mem: | awk '{print $2}')

    if [ -z $ram ]; then
        >&2 echo "Failed to fetch memory info, skipping..."
        ram="RAM: Unknown"
    else
        ram="RAM ${ram}"
    fi

   echo $ram >> $1

    manufacturer=$(dmidecode --type baseboard | grep Manufacturer: || echo Unknown)
    echo "Manufacturer: $manufacturer"
    echo "Manufacturer: $manufacturer" >> $1

    product_name=$(dmidecode -t baseboard | grep -i 'Product name' || echo Unknown)
    echo "Product name: $product_name"
    echo "Manufacturer: $product_name" >> $1

    serial_number=$(dmidecode -t baseboard | grep -i Serial || echo Unkown)
    echo "System Serial Number: $serial_number"
    echo "System Serial Number: $serial_number" >> $1

    echo "---- System ----" >> $1

    os_distribution=$(cat /etc/os-release | grep "PRETTY_NAME" | grep -o -E "\".+\"")
    echo "OS Distribution: $os_distribution"
    echo "OS Distribution: $os_distribution" >> $1

    kernel_version=$(uname -v)
    echo "Kernel version: $kernel_version"
    echo "Kernel version: $kernel_version" >> $1

    created_info=$(dumpe2fs $(mount | grep 'on / ' | awk '{print $1}') | grep 'Filesystem created: ')
    echo "AAAA"
    echo "$created_info"
    if [ -z $created_info ]; then
        >&2 echo "Failed to fetch installation date info, skipping..."
        created_info="Unknown"
    else
        created_info=${created_info#*:}
        created_info=$(echo "$created_info" | awk '$1=$1')  
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
    if [ -z net_interfaces ]; then
        >&2 echo "Failed to fetch network info, skipping..."
        echo "\n" >> $1
    else
        for var in ${net_interfaces[@]}; do
            ip_addr=$(ip addr show "$var" | grep -E 'inet ' | awk '{print $2}')
            if [ -z "$ip_addr" ]; then
                ip_addr='-/-'
            fi
            echo "${var}: ${ip_addr}\n" >> $1
        done
    fi 
    echo "----EOF----\n" >> $1
}

if (($# > 3)); then
    >&2 echo "Too many arguments";
    exit 1;
fi

while getopts "n:" OPTION; do
    if [[ "$OPTARG" =~ ^-?[0-9]+$ ]]; then
        if ! (($OPTARG >= 1)); then
            print_error "-n option must be an integer > 1, got $OPTARG"
        else
            n=$OPTARG
        fi
    else
        print_error "-n must be an integer, got $OPTARG"
    fi
done

shift $(($OPTIND - 1))
file=$1

if [ -z "$n" ]; then
    n=-1
fi

if [ -z "$file" ]; then
    file="$HOME/bash/task1.out"
fi

parent_directory=$(dirname "$file")
file_name=$(basename $file)
if [ ! -d $parent_directory ]; then
    echo "Directory $parent_directory does not exist, creating..."
    error_msg=$(mkdir -p "$parent_directory" 2>&1)
    if [ $? -ne 0 ]; then
        print_error "Error creating directory $parent_directory, reason: $error_msg"
    fi
fi

if [ -f "$file" ]; then
    cur_d=$(date "+%Y%m%d")

    file="${file}-${cur_d}"
    # we get all the files with -nnnn in their names, sorted numerically from lowest to highest
    allfiles_created_before=($(ls -1v "$parent_directory" | grep -E "^$file_name-[0-9]{4,}"))
    num_found=${#allfiles_created_before[@]}
    if [ $num_found -eq 0 ]; then # if no such files found (i.e. len(allfiles...) == 0)
        file="${file}-0000"
    else
        last_createdfile_name=${allfiles_created_before[$((num_found - 1))]}
        last_created_number=${last_createdfile_name##*-}
        last_created_number=$(expr "$last_created_number" + 1)
        new_created_number="$(printf "%04d" $last_created_number)"
        file="${file}-${new_created_number}"
        if [ $n -ne -1 ] && [ $n -le $num_found ]; then
            leave_nfiles=$(expr $num_found - $_n + 1) #
            for var in ${allfiles_created_before[@]:0:$leave_nfiles}; do
                echo "Deleting old output file ${var}..."
                rm "${parent_directory}/${var}"
            done
        fi
    fi
fi

collectInfo $file
echo "Created output file $file at $(date)."
