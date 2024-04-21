#!/bin/bash

# Constants
source src/constants/Zrdn.sh

# Helpers
source src/helpers/Cp.sh
source src/helpers/Station.sh

sendDeleteToCP "${ZRDN2['stationFile']}" "${ZRDN2['name']}"
stopStation ZRDN2
