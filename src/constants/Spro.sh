#!/bin/bash

# г.Хабаровск
declare -A SPRO=(
  ['name']="СПРО"
  ['x']="9550000"
  ['y']="3050000"
  ['distance']="3000000"
  ['amount']="10"
  ['targets']="Бал.блок"
  
  ['jsonFile']="temp/SPRO.json"
  ['shotFile']="temp/SPRO-shot.json"
  ['stationFile']="temp/StationInfo/SPRO.json"
)

export SPRO
  