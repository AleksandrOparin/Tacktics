#!/bin/bash

# Constants
source src/constants/Paths.sh
source src/constants/Rls.sh
source src/constants/Spro.sh

# Helpers
source src/helpers/Json.sh

# Runs
source src/runs/Station.sh


runStation RLS2 SPRO 2>/dev/null &
sleep 0.2
updateFieldInFileByName "$PIDsFile" "${RLS2['name']}" "pid" "$!"
