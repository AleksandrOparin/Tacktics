#!/bin/bash

# Constants
source src/constants/Rls.sh

# Helpers
source src/helpers/Cp.sh
source src/helpers/Station.sh


sendDeleteToCP "${RLS1['stationFile']}" "${RLS1['name']}"
stopStation RLS1
