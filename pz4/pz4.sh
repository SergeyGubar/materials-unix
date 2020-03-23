#!/bin/bash

echo "Enter file extension:"
read extension

echo "Enter report filename:"
read report

echo "Looking for .${extension} files.."
num=$(ls -a | grep .${extension}\$ | wc -l)

if [[ $num -eq 0 ]]; then 
    echo "No files were found"
    exit 0
fi

date_formatted=$(date +%D)

echo "Found $num files" > $report
echo "Report formed at ${date_formatted}" >> $report
echo "=======" >> $report

print_perm() {
  case "$1" in
    0) printf "NO PERMISSIONS";;
    1) printf "Execute only";;
    2) printf "Write only";;
    3) printf "Write & execute";;
    4) printf "Read only";;
    5) printf "Read & execute";;
    6) printf "Read & write";;
    7) printf "Read & write & execute";;
  esac
}

for f in *.${extension}; do 
    echo "Processing $f file..";
    modify_date=$(date -r ${f})
    echo "$f was last modified at ${modify_date}" >> $report
    file_type=$(file ${f})
    echo "$f has type ${file_type}" >> $report


    perm=$(stat -c%a "$f")
    user=${perm:0:1}
    group=${perm:1:1}
    global=${perm:2:1}

    echo "Permissions :" >> $report
    echo "Owner Access: $(print_perm $user)" >> $report
    echo "Group Access: $(print_perm $group)" >> $report
    echo "Others Access: $(print_perm $global)" >> $report

    echo "$f content:" >> $report
    echo "=======" >> $report
    cat $f >> $report
done