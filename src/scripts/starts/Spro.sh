#!/bin/bash

# Constants
source src/constants/Paths.sh
source src/constants/Spro.sh

# Helpers
source src/helpers/Json.sh

# Runs
source src/runs/PowerStation.sh


runPowerStationWithRegistration SPRO 2>/dev/null
