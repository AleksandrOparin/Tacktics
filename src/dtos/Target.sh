#!/bin/bash

# Поля цели
# id - id цели
# x - x координата
# y - y координата
# speed - скорость цели
# type - тип цели
# detected - цель обнаружена?
# destroyed - цель уничтожена?

targetToJSON() {
  local id=${1}
  local x=${2}
  local y=${3}
  local speed=${4:0}
  local type=${5:-''}
  local detected=${6:-false}
  local detectedTime=${7:-''}
  local destroyed=${8:-false}
  
  jq -n \
  --arg id "$id" \
  --arg x "$x" \
  --arg y "$y" \
  --arg speed "$speed" \
  --arg type "$type" \
  --arg detected "$detected" \
  --arg detectedTime "$detectedTime" \
  --arg destroyed "$destroyed" \
  '{
      "id": $id,
      "x": $x,
      "y": $y,
      "speed": $speed,
      "type": $type,
      "detected": $detected,
      "detectedTime": $detectedTime,
      "destroyed": $destroyed
  }'
}
