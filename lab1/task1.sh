#!/bin/bash
# ./task1.sh -h | --help -n num file
# Write all data to file, or to ~/bash/task1.out if it's not specified
echo "Date: $(date)" > task1.out
echo "--- Hardware ---" >> task1.out
cat /proc/cpuinfo | grep 'model name' | uniq >> task1.out
