#!/bin/bash

# Constants
source src/constants/Paths.sh


declare -A CP=(
  ['name']="КП"
  
  ['stationFile']="${StationInfoDir:?}/CP.json"
)
  
declare -A CPResponseTypes=(
  ['ping']="ping"
  ['update']="update"
  ['delete']="delete"
)

export CP CPResponseTypes
