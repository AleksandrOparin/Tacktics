#!/bin/bash

# Поля сообщения (для КП)
# name - имя станции
# message - сообщение

messageToJSON() {
  local name=${1}
  local message=${2}
  
  jq -n \
  --arg name "$name" \
  --arg message "$message" \
  '{
      "name": $name,
      "message": $message
  }'
}
