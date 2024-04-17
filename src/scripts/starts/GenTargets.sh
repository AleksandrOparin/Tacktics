#!/bin/bash

# Constants
source src/constants/GenTargets.sh
source src/constants/Paths.sh

# Dtos
source src/dtos/Station.sh

# Helpers
source src/helpers/Json.sh


./GenTargets.sh &
writeToFileCheckName "${GenTargets['stationFile']}" "$(stationToJSON "${GenTargets['name']}" "" "$!")"
writeToFileCheckName "${StationsFile:?}" "$(stationToJSON "${GenTargets['name']}" "" "$!")"
