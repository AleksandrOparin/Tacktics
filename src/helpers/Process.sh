#!/bin/bash

# Constants
source src/constants/Paths.sh

# Helpers
source src/helpers/Json.sh


stopProcesses() {
  local pids=()
  pids=($(getFieldsFromFile "$PIDsFile" "pid"))
  
  for pid in "${pids[@]}"; do
    kill "$pid"
  done
}

stopProcessByName() {
  local name=$1
  
  # Находим запись по имени станции
  local jsonData
  jsonData=$(findByName "$PIDsFile" "$name")
  
  # Получаем PID
  local pid
  pid=$(getFieldValue "$jsonData" "pid")
  
  kill "$pid"
  removeFromFile "$PIDsFile" "name" "$name"
}