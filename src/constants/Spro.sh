#!/bin/bash

# Constants
source src/constants/Paths.sh


# г.Хабаровск
declare -A SPRO=(
  ['name']="СПРО"
  ['x']="9550000"
  ['y']="3050000"
  ['distance']="1200000"
  ['amount']="10"
  ['targets']="Бал.блок"
  
  ['jsonFile']="${StationTargetsDir:?}/SPRO.json"
  ['shotFile']="${StationTargetsDir:?}/SPRO-shot.json"
  ['stationFile']="${StationInfoDir:?}/SPRO.json"
)

export SPRO
  