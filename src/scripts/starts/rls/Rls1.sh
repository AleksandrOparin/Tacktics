#!/bin/bash

# Constants
source src/constants/Rls.sh
source src/constants/Spro.sh

# Helpers
source src/helpers/Cp.sh
source src/helpers/Json.sh

# Runs
source src/runs/Station.sh


runStation RLS1 SPRO 2>/dev/null &

sleep 0.1

updateFieldInFileByName "${RLS1['stationFile']}" "${RLS1['name']}" "pid" "$!"
sendUpdateToCP "${RLS1['stationFile']}" "${RLS1['name']}"
