#!/bin/bash

source src/runs/Rls.sh

runRLS RLSKeys[@] RLS1[@] SPROKeys[@] SPRO1[@] > logs/RLS1.log 2>&1 &
echo $! > temp/pids.txt

runRLS RLSKeys[@] RLS2[@] SPROKeys[@] SPRO1[@] > logs/RLS2.log 2>&1 &
echo $! >> temp/pids.txt

runRLS RLSKeys[@] RLS3[@] SPROKeys[@] SPRO1[@] > logs/RLS3.log 2>&1 &
echo $! >> temp/pids.txt

./GenTargets.sh &
echo $! >> temp/pids.txt

while true; do
  a=5
done

