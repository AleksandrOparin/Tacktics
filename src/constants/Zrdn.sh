#!/bin/bash

# Массив ключей для ЗРДН
declare -a ZRDNKeys=(
  'name'
  'x'
  'y'
  'distance'
)

# г.Краснодар
declare -a ZRDN1=(
  "ZRDN1"
  "3250000"
  "2750000"
  "600000"
)

# г.Одесса
declare -a ZRDN2=(
  "ZRDN2"
  "2700000"
  "2850000"
  "400000"
)

# г.Оренбург
declare -a ZRDN3=(
  "ZRDN3"
  "4300000"
  "3350000"
  "550000"
)

export ZRDNKeys ZRDN1 ZRDN2 ZRDN3 
  