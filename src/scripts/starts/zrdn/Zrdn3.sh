#!/bin/bash

# Constants
source src/constants/Paths.sh
source src/constants/Zrdn.sh

# Runs
source src/runs/PowerStation.sh


runPowerStationWithRegistration ZRDN3 2>/dev/null
