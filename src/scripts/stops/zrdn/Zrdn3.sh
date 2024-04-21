#!/bin/bash

# Constants
source src/constants/Zrdn.sh

# Helpers
source src/helpers/Cp.sh
source src/helpers/Process.sh

sendDeleteToCP "${ZRDN3['stationFile']}" "${ZRDN3['name']}"
stopStation ZRDN3
