#!/bin/bash

# Constants
source src/constants/Rls.sh

# Helpers
source src/helpers/Cp.sh
source src/helpers/Process.sh


sendDeleteToCP "${RLS3['stationFile']}" "${RLS3['name']}"
stopStation RLS3
