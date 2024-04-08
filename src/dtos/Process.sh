#!/bin/bash

# Поля иформации о процессе запущенного элемента
# name - имя станции
# pid - PID процесса станции
# workPid - PID процесса проверки работоспособности
# active? - запущена ли станция
# pending? - находится ли станции в статусе приемки/отправки сообщения о работоспособности

processToJSON() {
  local name=${1}
  local workPid=${2:-''}
  local pid=${3:-''}
  local active=${4:-'false'}
  local pending=${5:-'false'}
  
  jq -n \
  --arg name "$name" \
  --arg workPid "$workPid" \
  --arg pid "$pid" \
  --arg active "$active" \
  --arg pending "$pending" \
  '{
      "name": $name,
      "workPid": $workPid,
      "pid": $pid,
      "active": $active,
      "pending": $pending
  }'
}
