#!/bin/bash

# Constants
source src/constants/Rls.sh
source src/constants/Spro.sh

# Runs
source src/runs/Station.sh
source src/runs/PowerStation.sh

runStation RLS1 SPRO > logs/RLS1.log 2>&1 &
echo $! > temp/pids.txt

runStation RLS2 SPRO > logs/RLS2.log 2>&1 &
echo $! > temp/pids.txt

runStation RLS3 SPRO > logs/RLS3.log 2>&1 &
echo $! > temp/pids.txt

./GenTargets.sh &
echo $! >> temp/pids.txt
