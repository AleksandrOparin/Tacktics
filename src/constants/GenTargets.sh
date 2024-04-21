#!/bin/bash

# Constants
source src/constants/Paths.sh


declare -A GenTargets=(
  ['name']="Генератор целей"
  
  ['stationFile']="${StationInfoDir:?}/GenTargets.json"
)

export GenTargets
