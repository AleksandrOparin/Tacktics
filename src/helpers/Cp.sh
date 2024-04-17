#!/bin/bash

# Constants
source src/constants/Cp.sh
source src/constants/Paths.sh

# Dtos
source src/dtos/Message.sh
source src/dtos/Station.sh

# Helpers
source src/helpers/Code.sh
source src/helpers/Json.sh
source src/helpers/Random.sh


sendTextToCP() {
  local directory=$1
  local text=$2
  
  # Шифруем данные
  local encodedText
  encodedText=$(encodeText "$text")
  
  # Создаем файл
  local file
  file="$directory/$(generateRandomSequence)"
    
  # Записываем в него зашифрованные данные и контрольную сумму
  echo "$encodedText" > "$file"
}

sendMessageToCP() {
  local stationName=$1
  local detectedTime=$2
  local messageText=$3

  local jsonData
  jsonData=$(messageToJSON "$stationName" "$detectedTime" "$messageText")
    
  # Отправляем данные
  sendTextToCP "${CPTargetsDir:?}" "$jsonData"
}

sendTargetToCP() {
  local stationName=$1
  local detectedTime=$2
  local messageText=$3
  local targetId=${4:-''}
  local targetType=${5:-''}
  local targetX=${6:-''}
  local targetY=${7:-''}
  
  local jsonData
  jsonData=$(messageToJSON "$stationName" "$detectedTime" "$messageText" "$targetId" "$targetType" "$targetX" "$targetY")
    
  # Отправляем данные
  sendTextToCP "${CPTargetsDir:?}" "$jsonData"
}

sendResponseToCP() {
  local type=$1
  local jsonData=$2
  
  # Добавляем поле type к данным
  jsonData=$(addField "$jsonData" "type" "$type")
  
  sendTextToCP "${CPResponseDir:?}" "$jsonData"
}

sendPingToCP() {
  local stationName=$1
  local pingPid=${2:-''}
  local pid=${3:-''}
  
  local jsonData
  jsonData=$(stationToJSON "$stationName" "$pingPid" "$pid")
    
  # Отправляем данные
  sendResponseToCP "${CPResponseTypes['ping']}" "$jsonData"
}

sendUpdateToCP() {
  local stationFile=$1
  local stationName=$2
  
  local stationData
  stationData=$(findByName "$stationFile" "$stationName")
    
  # Отправляем данные
  sendResponseToCP "${CPResponseTypes['update']}" "$stationData"
}

sendDeleteToCP() {
  local stationFile=$1
  local stationName=$2
  
  local stationData
  stationData=$(findByName "$stationFile" "$stationName")
    
  # Отправляем данные
  sendResponseToCP "${CPResponseTypes['delete']}" "$stationData"
}
