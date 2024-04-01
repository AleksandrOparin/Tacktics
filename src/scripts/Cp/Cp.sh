#!/bin/bash

# Constants
source src/constants/Paths.sh
source src/constants/Cp.sh

# Runs
source src/runs/Cp.sh

runCP > logs/Cp.log &
echo $! >> "$PidsFile"
