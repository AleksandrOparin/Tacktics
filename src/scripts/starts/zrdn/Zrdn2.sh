#!/bin/bash

# Constants
source src/constants/Paths.sh
source src/constants/Zrdn.sh

# Helpers
source src/helpers/Json.sh

# Runs
source src/runs/PowerStation.sh


runPowerStation ZRDN2 2>&1 &
sleep 0.2
updateFieldInFileByName "$PIDsFile" "${ZRDN2['name']}" "pid" "$!"
