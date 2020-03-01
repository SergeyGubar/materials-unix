#!/bin/bash
# ./task1.sh -h | --help -n num file
# Write all data to file, or to ~/bash/task1.out if it's not specified
output='out.out'
echo "Date: $(date)" > $output 
echo "--- Hardware ---" >> $output 

cat /proc/cpuinfo | grep 'model name' | uniq >> $output
free -m | grep Mem: | awk '{print $2}' >> $output

