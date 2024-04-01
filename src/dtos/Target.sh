#!/bin/bash

# Поля цели
# id - id цели
# x - x координата
# y - y координата
# speed - скорость цели
# destroyed - цель уничтожена?

targetToJSON() {
  local id=${1}
  local x=${2}
  local y=${3}
  local speed=${4:0}
  local discovered=${5:-false}
  local destroyed=${6:-false}
  
  jq -n \
  --arg id "$id" \
  --arg x "$x" \
  --arg y "$y" \
  --arg speed "$speed" \
  --arg discovered "$discovered" \
  --arg destroyed "$destroyed" \
  '{
      "id": $id,
      "x": $x,
      "y": $y,
      "speed": $speed,
      "discovered": $discovered,
      "destroyed": $destroyed
  }'
}
