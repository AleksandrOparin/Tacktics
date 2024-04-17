#!/bin/bash

# Constants
source src/constants/Cp.sh
source src/constants/Paths.sh

# Helpers
source src/helpers/Json.sh

# Runs
source src/runs/Cp.sh


runCP 2>/dev/null &

sleep 0.1

updateFieldInFileByName "${CP['stationFile']}" "${CP['name']}" "pid" "$!"
updateFieldInFileByName "${StationsFile:?}" "${CP['name']}" "pid" "$!"
