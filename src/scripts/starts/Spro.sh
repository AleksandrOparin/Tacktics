#!/bin/bash

# Constants
source src/constants/Paths.sh
source src/constants/Spro.sh

# Runs
source src/runs/PowerStation.sh

runPowerStation SPRO 2>&1 &
echo $! >> "$PidsFile"
