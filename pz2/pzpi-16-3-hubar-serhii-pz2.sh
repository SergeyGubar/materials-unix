#!/bin/bash

sed 's/test/and/' test.txt > output1.txt

# n - suppress output, p - print second line

sed -n '2p' test.txt

sed '7,10d' test.txt > output2.txt 

sed '7,10aTEST' test.txt > output2.txt 

sed '/^to/q' test.txt > output3.txt

# combining

sed '/^delete/d ; s/test/nottest/' test.txt > output4.txt

sed -e '/^delete/d' -e 's/test/nottest/' test.txt > output5.txt

# deletings

sed '/5/ a #Next line is the 6th line, not this' test.txt > output6.txt

sed 'n;n;s/./x/'

echo hello world | sed 'y/abcdefghij/0123456789/'