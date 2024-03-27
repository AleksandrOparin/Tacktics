#!/bin/bash

# Constants
source src/constants/Rls.sh
source src/constants/Spro.sh

# Runs
source src/runs/Rls.sh

runRLS RLS1 SPRO > logs/RLS1.log 2>&1 &
echo $! > temp/pids.txt

runRLS RLS2 SPRO > logs/RLS2.log 2>&1 &
echo $! > temp/pids.txt

runRLS RLS3 SPRO > logs/RLS3.log 2>&1 &
echo $! > temp/pids.txt

./GenTargets.sh &
echo $! >> temp/pids.txt
