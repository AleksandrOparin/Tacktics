#!/bin/bash

while read -r pid; do
    # Kill the process
    kill "$pid"
done < temp/pids.txt
