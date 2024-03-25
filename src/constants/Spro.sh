#!/bin/bash

# Массив ключей для ЗРДН
declare -a SPROKeys=(
  'name'
  'x'
  'y'
  'distance'
)

# г.Хабаровск
declare -a SPRO1=(
  "SPRO"
  "9550000"
  "3050000"
  "1200000"
)

export SPROKeys SPRO1
  