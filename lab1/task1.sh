#!/bin/bash
# ./task1.sh -h | --help -n num file
# Write all data to file, or to ~/bash/task1.out if it's not specified
output='out.out'

if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
  echo "Usage ./task1.sh [-h | --help] [-n num] [file]";
  exit 0;
fi


if [ "$1" = "-n" ]; then
    re='^[0-9]+$'
    if ! [[ $2 =~ $re ]] ; then
        echo "error: Not a number" >&2;
        exit 1;
    fi
    if [ "$2" -gt 2 ]; then 
        echo "GOTCHA";
    fi
  exit 0
fi

echo "Date: $(date)" > $output 
echo "---- Hardware ----" >> $output 

cpu=$(cat /proc/cpuinfo | grep 'model name' | uniq)
echo "CPU: $cpu"
echo "CPU: $cpu" >> $output

ram=$(free -m | grep Mem: | awk '{print $2}')
echo "RAM: $ram MB"
echo "RAM: $ram MB" >> $output

manufacturer=$(sudo dmidecode --type baseboard | grep Manufacturer: || echo Unknown)
echo "Manufacturer: $manufacturer"
echo "Manufacturer: $manufacturer" >> $output

product_name=$(sudo dmidecode -t baseboard | grep -i 'Product name' || echo Unknown)
echo "Product name: $product_name"
echo "Manufacturer: $product_name" >> $output

serial_number=$(sudo dmidecode -t baseboard | grep -i Serial || echo Unkown)
echo "System Serial Number: $serial_number"
echo "System Serial Number: $serial_number" >> $output

echo "---- System ----" >> $output

os_distribution=$(cat /etc/os-release | grep "PRETTY_NAME" | grep -o -E "\".+\"")
echo "OS Distribution: $os_distribution"
echo "OS Distribution: $os_distribution" >> $output

kernel_version=$(uname -v)
echo "Kernel version: $kernel_version"
echo "Kernel version: $kernel_version" >> $output

install_date=$(sudo dumpe2fs $(mount | grep 'on \/ ' | awk '{print $1}') | grep 'Filesystem created: ')
echo "Installation date: $install_date"
echo "Installation date: $install_date" >> $output

hostname=$(hostname)
echo "Hostname: $hostname"
echo "Hostname: $hostname" >> $output

uptime=$(uptime | awk '{print $1}')
echo "Uptime $uptime"
echo "Uptime $uptime" >> $output


running_proccesses=$(ps aux | wc -l)
echo "Running processes: $running_proccesses"
echo "Running processes: $running_proccesses" >> $output

host=$(whoami)
id=$(id -u $host)
echo "User logged in: $id"
echo "User logged in: $id" >> output

echo "---- Network ----"
