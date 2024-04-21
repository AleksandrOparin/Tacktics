#!/bin/bash

# Constants
source src/constants/Paths.sh


# г.Краснодар
declare -A ZRDN1=(
  ['name']="ЗРДН1"
  ['x']="3250000"
  ['y']="2750000"
  ['distance']="600000"
  ['amount']="20"
  ['targets']="Самолет К.ракета"

  ['jsonFile']="${StationTargetsDir:?}/ZRDN1.json"
  ['shotFile']="${StationTargetsDir:?}/ZRDN1-shot.json"
  ['stationFile']="${StationInfoDir:?}/ZRDN1.json"
)
  
# г.Одесса
declare -A ZRDN2=(
  ['name']="ЗРДН2"
  ['x']="2700000"
  ['y']="2850000"
  ['distance']="400000"
  ['amount']="20"
  ['targets']="Самолет К.ракета"

  ['jsonFile']="${StationTargetsDir:?}/ZRDN2.json"
  ['shotFile']="${StationTargetsDir:?}/ZRDN2-shot.json"
  ['stationFile']="${StationInfoDir:?}/ZRDN2.json"
)
  
# г.Оренбург
declare -A ZRDN3=(
  ['name']="ЗРДН3"
  ['x']="4300000"
  ['y']="3350000"
  ['distance']="550000"
  ['amount']="20"
  ['targets']="Самолет К.ракета"

  ['jsonFile']="${StationTargetsDir:?}/ZRDN3.json"
  ['shotFile']="${StationTargetsDir:?}/ZRDN3-shot.json"
  ['stationFile']="${StationInfoDir:?}/ZRDN3.json"
)

export ZRDN1 ZRDN2 ZRDN3 
  