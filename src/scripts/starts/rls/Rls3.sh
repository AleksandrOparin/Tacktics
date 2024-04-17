#!/bin/bash

# Constants
source src/constants/Rls.sh
source src/constants/Spro.sh

# Helpers
source src/helpers/Cp.sh
source src/helpers/Json.sh

# Runs
source src/runs/Station.sh


runStation RLS3 SPRO 2>/dev/null &

sleep 0.1

updateFieldInFileByName "${RLS3['stationFile']}" "${RLS3['name']}" "pid" "$!"
sendUpdateToCP "${RLS3['stationFile']}" "${RLS3['name']}"
