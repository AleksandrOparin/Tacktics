#!/bin/bash

# Поля сообщения (для КП)
# stationName - имя станции
# stationPid - PID работы станции
# stationPingPid - PID процесса общения

stationToJSON() {
  local stationName=$1
  local stationPingPid=${2:-''}
  local stationPid=${3:-''}
  
  jq -n \
  --arg stationName "$stationName" \
  --arg stationPingPid "$stationPingPid" \
  --arg stationPid "$stationPid" \
  '{
      "name": $stationName,
      "pingPid": $stationPingPid,
      "pid": $stationPid
  }'
}
