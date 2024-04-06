#!/bin/bash

# Constants
source src/constants/Paths.sh
source src/constants/Zrdn.sh

# Dtos
source src/dtos/Pid.sh

# Helpers
source src/helpers/Json.sh

# Runs
source src/runs/PowerStation.sh


runPowerStation ZRDN3 2>&1 &
writeToFileCheckName "$PIDsFile" "$(pidToJSON "${ZRDN3['name']}" "$!")"