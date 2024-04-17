#!/bin/bash

# Поля сообщения (для КП)
# stationName - имя станции
# detectedTime - время обнаружения
# messageText - текст сообщения
# targetId - id цели
# targetType - тип цели
# targetX - x координата цели
# targetY - y координата цели

messageToJSON() {
  local stationName=$1
  local detectedTime=$2
  local messageText=$3
  local targetId=${4:-''}
  local targetType=${5:-''}
  local targetX=${6:-''}
  local targetY=${7:-''}
  
  jq -n \
  --arg stationName "$stationName" \
  --arg detectedTime "$detectedTime" \
  --arg message "$messageText" \
  --arg targetId "$targetId" \
  --arg targetType "$targetType" \
  --arg targetX "$targetX" \
  --arg targetY "$targetY" \
  '{
      "stationName": $stationName,
      "detectedTime": $detectedTime,
      "message": $message,
      "targetId": $targetId,
      "targetType": $targetType,
      "targetX": $targetX,
      "targetY": $targetY
  }'
}
