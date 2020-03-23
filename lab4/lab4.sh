#!/bin/bash

log=log.out

log_message() {
    current_date=$(date)
    timestamp=$(date +%s)
    printf "%s %s %s" "$current_date" "$timestamp" "$1" >> $log
    echo >> $log
}

send_test_signal_to_child() {
    kill -SIGUSR1 "$child"
    echo "Sent test signal to child process"
}

kill_child_process() {
    kill -SIGTERM "$child"
    echo "Killed child process"
}

parent_term() { 
    kill -SIGTERM "$child"
    log_message "Sent sigterm to child ${child}"
    exit 1
}

parent_interruption() {
    log_message "Parent was interrupted"
    exit 1
}



(
child_term() {
    pid=$(exec sh -c 'echo "$PPID"')
    log_message "PID: ${pid} signal: SIGTERM number: 15 action: child process terminated"
    exit 1
}

custom_signal() {
    log_message "Child process caught custom signal! SIGUSR1"
    
}

echo "Inside the subshell"

trap child_term SIGTERM
trap custom_signal SIGUSR1

while true; do
    echo "Child is working..." 1>/dev/null
    sleep 5
done
) &



child=$!
current_pid=$$
echo "Created child process ${child}"
echo "My process ${current_pid}"


trap parent_term SIGTERM
trap parent_interruption SIGINT

echo "Log start" > $log

while read -r -p "What you wanna do? For options - open --help " && [[ $REPLY != q ]]; do
  case $REPLY in
    test) send_test_signal_to_child;;
    exit) kill_child_process;;
    *) echo "Try Again.";;
  esac
done

