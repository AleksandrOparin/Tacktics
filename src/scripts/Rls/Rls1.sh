#!/bin/bash

# Constants
source src/constants/Paths.sh
source src/constants/Rls.sh
source src/constants/Spro.sh

# Runs
source src/runs/Station.sh

runStation RLS2 SPRO > logs/RLS2.log 2>/dev/null &
echo $! >> "$PidsFile"
