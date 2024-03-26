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

export SPROKeys SPRO1
  