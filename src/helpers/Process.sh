#!/bin/bash

# Constants
source src/constants/Paths.sh

# Helpers
source src/helpers/Json.sh


stopStation() {
  local -n StationMap=$1
  
  # Находим запись по имени станции
  local jsonData
  jsonData=$(findByName "${StationMap['stationFile']}" "${StationMap['name']}")
  
  # Получаем PID-ы
  local pingPid pid
  pingPid=$(getFieldValue "$jsonData" "pingPid")
  pid=$(getFieldValue "$jsonData" "pid")
  
  if [[ -n $pingPid ]]; then
    kill "$pingPid"
  fi
  
  if [[ -n $pid ]]; then
    kill "$pid"
  fi
  
  rm "${StationMap['stationFile']}"
}

stopStations() {
  local stationsFile stationInfoDirectory
  stationsFile="${StationsFile:?}"
  stationInfoDirectory="${StationInfoDir:?}"
  
  local pids=()
  pids=($(getFieldsFromFile "$stationsFile" "pid"))
  
  local pid
  for pid in "${pids[@]}"; do
    if [[ -n $pid ]]; then
      kill "$pid"
    fi
  done
  
  local pingPids=()
  pingPids=($(getFieldsFromFile "$stationsFile" "pingPid"))
  
  local pingPid
  for pingPid in "${pingPids[@]}"; do
    if [[ -n $pingPid ]]; then
      kill "$pingPid"
    fi
  done
  
  rm "$stationInfoDirectory"/*.json
  rm "$stationsFile"
}

stop() {
  local pattern="src/scripts/starts"
  
  pgrep -fla "$pattern"
  
  pkill -f "$pattern"
}

#stop
