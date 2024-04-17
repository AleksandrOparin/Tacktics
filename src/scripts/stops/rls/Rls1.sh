#!/bin/bash

# Constants
source src/constants/Rls.sh

# Helpers
source src/helpers/Cp.sh
source src/helpers/Process.sh


sendDeleteToCP "${RLS1['stationFile']}" "${RLS1['name']}"
stopStation RLS1
