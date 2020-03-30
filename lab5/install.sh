#!/bin/bash

check_directory() {
    if [ ! -d $1 ]; then
        echo "Directory was not found and will be automatically created."
        mkdir -p "$1" 2>&1
    fi
    if [ $? -ne 0 ]; then
        if [[ $LANG =~ uk_UA ]]; then
            echo "Директорію не було створено" 1>&2
        else
            echo "Error creating directory" 1>&2
        fi
        exit 1
    fi
}

add_to_path() {
    echo "export PATH="\$HOME/bin:\$PATH"" >> $HOME/.bash_profile
}

change_permissions() {
    chmod 755 $HOME/bin/pzpi-16-3-hubar-serhii-lab5.out
}

install() {
    check_directory "$HOME/bin"
    cp pzpi-16-3-hubar-serhii-lab5.out "$HOME/bin"
    add_to_path 
    change_permissions
}

install