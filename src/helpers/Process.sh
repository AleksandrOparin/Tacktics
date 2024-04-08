#!/bin/bash

# Constants
source src/constants/Paths.sh

# Helpers
source src/helpers/Json.sh


stopProcesses() {
  local pids=()
  pids=($(getFieldsFromFile "$PIDsFile" "pid"))
  
  local pid
  for pid in "${pids[@]}"; do
    kill "$pid"
  done
  
  local workPids=()
  workPids=($(getFieldsFromFile "$PIDsFile" "workPid"))
  
  local workPid
  for workPid in "${workPids[@]}"; do
    kill "$workPid"
  done
}

stopProcessByName() {
  local name=$1
  
  # Находим запись по имени станции
  local jsonData
  jsonData=$(findByName "$PIDsFile" "$name")
  
  # Получаем PID-ы
  local pid workPid
  pid=$(getFieldValue "$jsonData" "pid")
  workPid=$(getFieldValue "$jsonData" "workPid")
  
  kill "$pid"
  kill "$workPid"
  removeFromFile "$PIDsFile" "name" "$name"
}