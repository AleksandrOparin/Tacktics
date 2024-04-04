#!/bin/bash

# Constants
source src/constants/Paths.sh
source src/constants/Rls.sh
source src/constants/Spro.sh

# Dtos
source src/dtos/Pid.sh

# Helpers
source src/helpers/Json.sh

# Runs
source src/runs/Station.sh


runStation RLS3 SPRO 2>/dev/null &
writeToFileCheckName "$PIDsFile" "$(pidToJSON "${RLS3['name']}" "$!")"
