#!/bin/bash

while true; do
    read -p "Enter the process ID: " pid
    if ps -p $pid > /dev/null; then
        echo "Process ID $pid exists."
        exit 0
    else
        echo "Process ID $pid does not exist. Please try again."
    fi
done