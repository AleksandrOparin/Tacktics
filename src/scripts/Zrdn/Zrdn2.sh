#!/bin/bash

# Constants
source src/constants/Paths.sh
source src/constants/Zrdn.sh

# Runs
source src/runs/PowerStation.sh

runPowerStation ZRDN2 2>&1 &
echo $! >> "$PidsFile"
