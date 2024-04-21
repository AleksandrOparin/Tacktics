#!/bin/bash

# Constants
source src/constants/Paths.sh


declare -A DneprRLS=(
  ['distance']="3000000"
  ['deviation']="120"
)

declare -A DarialRLS=(
  ['distance']="7000000"
  ['deviation']="90"
)
  
declare -A VoronezhRLS=(
  ['distance']="6000000"
  ['deviation']="200"
)
  
# г.Минск + "Днепр"
declare -A RLS1=(
  ['name']="РЛС1"
  ['x']="2500000"
  ['y']="3700000"
  ['angle']="135"
  ['distance']="${DneprRLS['distance']}"
  ['deviation']="${DneprRLS['deviation']}"
  ['targets']="Бал.блок"
  
  ['jsonFile']="${StationTargetsDir:?}/RLS1.json"
  ['stationFile']="${StationInfoDir:?}/RLS1.json"
)

# Координаты + "Воронеж ДМ"
declare -A RLS2=(
  ['name']="РЛС2"
  ['x']="12000000"
  ['y']="5000000"
  ['angle']="135"
  ['distance']="${VoronezhRLS['distance']}"
  ['deviation']="${VoronezhRLS['deviation']}"
  ['targets']="Бал.блок"
  
  ['jsonFile']="${StationTargetsDir:?}/RLS2.json"
  ['stationFile']="${StationInfoDir:?}/RLS2.json"
)
  
# г.Омск + "Днепр"
declare -A RLS3=(
  ['name']="РЛС3"
  ['x']="5500000"
  ['y']="3750000"
  ['angle']="270"
  ['distance']="${DneprRLS['distance']}"
  ['deviation']="${DneprRLS['deviation']}"
  ['targets']="Бал.блок"
  
  ['jsonFile']="${StationTargetsDir:?}/RLS3.json"
  ['stationFile']="${StationInfoDir:?}/RLS3.json"
)

export RLS1 RLS2 RLS3
