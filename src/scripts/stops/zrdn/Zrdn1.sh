#!/bin/bash

# Constants
source src/constants/Zrdn.sh

# Helpers
source src/helpers/Cp.sh
source src/helpers/Station.sh

sendDeleteToCP "${ZRDN1['stationFile']}" "${ZRDN1['name']}"
stopStation ZRDN1
