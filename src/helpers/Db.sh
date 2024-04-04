#!/bin/bash

# Constants
source src/constants/Paths.sh


insertMessageInDB() {
  local stationName=$1
  local detectedTime=$2
  local messageText=$3
  local targetId=${4:-''}
  local targetType=${5:-''}
  local targetX=${6:-''}
  local targetY=${7:-''}
  
  sqlite3 "$DBFile" "INSERT INTO messages VALUES ('$stationName', '$detectedTime', '$messageText', '$targetId', '$targetType', '$targetX', '$targetY');"
}
