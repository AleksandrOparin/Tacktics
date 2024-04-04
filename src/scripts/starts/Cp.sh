#!/bin/bash

# Constants
source src/constants/Cp.sh
source src/constants/Paths.sh

# Dtos
source src/dtos/Pid.sh

# Helpers
source src/helpers/Json.sh

# Runs
source src/runs/Cp.sh


runCP 2>/dev/null &
writeToFileCheckName "$PIDsFile" "$(pidToJSON "${CP['name']}" "$!")"
