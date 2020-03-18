#!/bin/bash

set abc def

echo "Hi pz 3" > test.txt
echo "Hi once again" >> test.txt

ls -a | grep "test"

cat *.txt | sort | uniq > result-file.out

cat < test.txt | tee > outfile.out

num_found=$(ls -a | grep "test" | wc -l)

echo $num_found
echo "Found $num_found"

echo "Some variables"
echo "Home directory: $HOME"
echo $PS1
echo "Path $PATH"

false && echo "Test"

# Test
false || echo "Test"
# Test Test2
false || echo "Test" && echo "Test2"

counter=1
while [ $counter -le 10 ]
do
    echo $counter
    ((counter++))
done

if test $# -lt 2 
then
    echo "Two args needed"
fi

echo "Arguments: "
echo "First argument $1"
echo "First argument \$1"
echo "First argument $2"

my_var="test"
echo "Some interpolation ${my_var}"