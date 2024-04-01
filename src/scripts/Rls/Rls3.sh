#!/bin/bash

# Constants
source src/constants/Paths.sh
source src/constants/Rls.sh
source src/constants/Spro.sh

# Runs
source src/runs/Station.sh

runStation RLS3 SPRO 2>/dev/null &
echo $! >> "$PidsFile"
