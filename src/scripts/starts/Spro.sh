#!/bin/bash

# Constants
source src/constants/Paths.sh
source src/constants/Spro.sh

# Helpers
source src/helpers/Json.sh

# Runs
source src/runs/PowerStation.sh


runPowerStation SPRO 2>&1 &
sleep 0.2
updateFieldInFileByName "$PIDsFile" "${SPRO['name']}" "pid" "$!"
