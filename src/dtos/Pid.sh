#!/bin/bash

# Поля иформации о PID
# name - имя станции
# pid - PID

pidToJSON() {
  local name=${1}
  local pid=${2}
  
  jq -n \
  --arg name "$name" \
  --arg pid "$pid" \
  '{
      "name": $name,
      "pid": $pid
  }'
}
