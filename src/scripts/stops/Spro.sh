#!/bin/bash

# Constants
source src/constants/Spro.sh

# Helpers
source src/helpers/Cp.sh
source src/helpers/Station.sh

sendDeleteToCP "${SPRO['stationFile']}" "${SPRO['name']}"
stopStation SPRO
