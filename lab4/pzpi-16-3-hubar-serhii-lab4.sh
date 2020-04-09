#!/bin/bash

if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    echo "Usage ./pzpi-16-3-hubar-serhii-lab4.sh [-h | --help]";
    echo "Script launches child process and waits for interactive communication with user";
    echo "Possible interaction options:";
    echo "1) ping - send ping signal to child subshell";
    echo "2) kill - to kill child subshell"
    echo "3) back - to send ping back (child subshell will respond)"
    echo "q to quit"
    exit 0;
fi

localize_error() {
    if [[ $LANG =~ uk_UA ]]; then
        echo "$1" 1>&2
    else
        echo  "$2" 1>&2
    fi
}

if [ "$#" -ne 0 ]; then
    localize_error "Скрипт не може приймати аргументів крім --help" "Script can't be run with arguments (excuding --help)"
    exit 1
fi


path_to_log_file="$HOME/log/pzpi-16-3-hubar-serhii-lab4.log"

check_dir() {
    if [ ! -d "$HOME/log" ]; then
        mkdir "$HOME/log"
    fi
}

check_log() {
    if [ ! -f "${path_to_log_file}" ]; then
        touch "${path_to_log_file}"
    fi
}

check_dir

check_log

write_to_log() {
    log_date=$(date '+%a, %d %b %Y %X %z')
    unix_temistamp=$(date +%s)
    formatted_message=$(printf "%s; %s; %s" "$log_date" "$unix_temistamp" "$1")
    echo $formatted_message >> "${path_to_log_file}"
    logger "\"${formatted_message}\""
}

start_log() {
    write_to_log "${current_pid}; -1; INIT; Process start"
    write_to_log "${child}; -1; INIT; Child Process start"
}

finish_log() {
    write_to_log "${current_pid}; -1; END; Parent process stop"
}

send_test_signal_to_child() {
    kill -SIGUSR1 "$child"
    echo "Sent test signal to child process"
}

kill_child_process() {
    kill -SIGTERM "$child"
    echo "Killed child process"
}

send_ping_back_signal_to_child() {
    kill -SIGUSR2 "$child"
    echo "Sent ping back signal to child process"
}

on_parent_terminated() { 
    kill -SIGTERM "$child"
    write_to_log "${current_pid}; 15; SIGTERM; parent exits and throws SIGTERM to subshell"
    echo "Sent sigterm to child ${child}"
    exit 1
}

on_parent_interrupted() {
    write_to_log "${current_pid}; 2; SIGINT; parent got interrupted"
    exit 1
}

on_parent_pinged() {
    write_to_log "${current_pid}; 12; SIGUSR2; nothing, parent confirms that child process pinged back"
}


# Child process

(
on_child_terminated() {
    pid=$(exec sh -c 'echo "$PPID"')
    write_to_log "${pid}; 15; SIGTERM; child process terminated"
    exit 1
}
on_child_ping_back() {
    pid=$(exec sh -c 'echo "$PPID"')
    write_to_log "${pid}; 12; SIGUSR2; ping father back"
    kill -SIGUSR2 $$
}
on_child_pinged() {
    pid=$(exec sh -c 'echo "$PPID"')
    write_to_log "${pid}; 10; SIGUSR1; just ping signal"
}
on_child_heartbeat() {
    pid=$(exec sh -c 'echo "$PPID"')
    write_to_log "${pid}; 18; SIGCONTv; on_child_heartbeat"
}


trap on_child_terminated SIGTERM
trap on_child_pinged SIGUSR1
trap on_child_ping_back SIGUSR2
trap on_child_heartbeat 18


# Script

while true; do
    echo "Child process is doing some work..." 1>/dev/null
    sleep 2
done
) &

# Script start


child=$!
current_pid=$$

start_log

trap on_parent_pinged SIGUSR2
trap on_parent_interrupted SIGINT
trap on_parent_terminated SIGTERM

(
    while true; do
        kill -18 "$child" 2>/dev/null
        sleep 2
    done
) &

ping_pid=$!

while read -r -p "Select your option. For options - open --help " && [[ $REPLY != q ]]; do
  case $REPLY in
    ping) send_test_signal_to_child;;
    kill) kill_child_process;;
    back) send_ping_back_signal_to_child;;
    *) echo "Please, Try Again.";;
  esac
done

finish_log

kill $ping_pid