#!/bin/bash

# Массив ключей для ЗРДН
declare -a SPROKeys=(
  'name'
  'x'
  'y'
  'distance'
  'amount'
  'targets'
  'jsonFile'
  'shotFile'
)

# г.Хабаровск
declare -a SPRO1=(
  "SPRO"
  "9550000"
  "3050000"
  "1200000"
  "10"
  "Бал.блок"
  "temp/SPRO.json"
  "temp/SPRO-shot.json"
)
  
declare -A SPRO2=(
  ['name']="СПРО"
  ['x']="9550000"
  ['y']="3050000"
  ['distance']="1200000"
  ['amount']="10"
  ['targets']="Бал.блок"
  ['jsonFile']="temp/SPRO2.json"
  ['shotFile']="temp/SPRO2-shot.json"
)

export SPROKeys SPRO1 SPRO2
  