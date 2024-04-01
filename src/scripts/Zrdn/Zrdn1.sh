#!/bin/bash

# Constants
source src/constants/Paths.sh
source src/constants/Zrdn.sh

# Runs
source src/runs/PowerStation.sh

runPowerStation ZRDN1 2>&1 &
echo $! >> "$PidsFile"
