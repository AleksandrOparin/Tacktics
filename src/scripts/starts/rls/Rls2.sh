#!/bin/bash

# Constants
source src/constants/Rls.sh
source src/constants/Spro.sh

# Runs
source src/runs/Station.sh


runStationWithRegistration RLS2 SPRO 2>/dev/null
