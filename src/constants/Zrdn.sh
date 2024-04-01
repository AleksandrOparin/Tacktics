#!/bin/bash
  
# г.Краснодар
declare -A ZRDN1=(
  ['name']="ЗРДН1"
  ['x']="3250000"
  ['y']="2750000"
  ['distance']="2000000"
  ['amount']="20"
  ['targets']="Самолет К.ракета"
  ['jsonFile']="temp/ZRDN1.json"
  ['shotFile']="temp/ZRDN1-shot.json"
)
  
# г.Одесса
declare -A ZRDN2=(
  ['name']="ЗРДН2"
  ['x']="2700000"
  ['y']="2850000"
  ['distance']="400000"
  ['amount']="20"
  ['targets']="Самолет К.ракета"
  ['jsonFile']="temp/ZRDN2.json"
  ['shotFile']="temp/ZRDN2-shot.json"
)
  
# г.Оренбург
declare -A ZRDN3=(
  ['name']="ЗРДН3"
  ['x']="4300000"
  ['y']="3350000"
  ['distance']="550000"
  ['amount']="20"
  ['targets']="Самолет К.ракета"
  ['jsonFile']="temp/ZRDN3.json"
  ['shotFile']="temp/ZRDN3-shot.json"
)

export ZRDN1 ZRDN2 ZRDN3 
  