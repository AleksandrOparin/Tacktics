#!/bin/bash

# Constants
source src/constants/Rls.sh
source src/constants/Spro.sh

# Helpers
source src/helpers/Cp.sh
source src/helpers/Json.sh

# Runs
source src/runs/Station.sh


runStation RLS2 SPRO 2>/dev/null &

sleep 0.1

updateFieldInFileByName "${RLS2['stationFile']}" "${RLS2['name']}" "pid" "$!"
sendUpdateToCP "${RLS2['stationFile']}" "${RLS2['name']}"
