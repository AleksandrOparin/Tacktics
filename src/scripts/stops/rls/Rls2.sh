#!/bin/bash

# Constants
source src/constants/Rls.sh

# Helpers
source src/helpers/Cp.sh
source src/helpers/Process.sh


sendDeleteToCP "${RLS2['stationFile']}" "${RLS2['name']}"
stopStation RLS2
