#!/bin/bash

declare -A DneprRLS=(
  ['distance']="3000000"
  ['deviation']="120"
)

declare -A DarialRLS=(
  ['distance']="7000000"
  ['deviation']="90"
)
  
declare -A VoronezhRLS=(
  ['distance']="4000000"
  ['deviation']="200"
)
  
# Массив ключей для РЛС
declare -a RLSKeys=(
  'name'
  'x'
  'y'
  'angle'
  'distance'
  'deviation'
  'targets'
  'jsonFile'
)

# г.Минск + "Днепр"
declare -a RLS1=(
  "RLS1"
  "2500000"
  "3700000"
  "135"
  "${DneprRLS['distance']}"
  "${DneprRLS['deviation']}"
  "Бал.блок"
  "temp/RLS1.json"
)

# Координаты + "Воронеж ДМ"
declare -a RLS2=(
  "RLS2"
  "12000000"
  "5000000"
  "135"
  "${VoronezhRLS['distance']}"
  "${VoronezhRLS['deviation']}"
  "Бал.блок"
  "temp/RLS2.json"
)
  
# г.Омск + "Днепр"
declare -a RLS3=(
  "RLS3"
  "5500000"
  "3750000"
  "270"
  "${DneprRLS['distance']}"
  "${DneprRLS['deviation']}"
  "Бал.блок"
  "temp/RLS3.json"
)
  
declare -A RLS5=(
  ['name']="РЛС"
  ['x']="12000000"
  ['y']="5000000"
  ['angle']="135"
  ['distance']="${VoronezhRLS['distance']}"
  ['deviation']="${VoronezhRLS['deviation']}"
  ['targets']="Бал.блок"
  ['jsonFile']="temp/RLS5.json"
)

export RLSKeys RLS1 RLS2 RLS3 RLS5
