#!/bin/bash

# Constants
source src/constants/Cp.sh
source src/constants/Messages.sh
source src/constants/Paths.sh
source src/constants/Variables.sh

# Dtos
source src/dtos/Process.sh

# Helpers
source src/helpers/Cp.sh
source src/helpers/Json.sh
source src/helpers/Time.sh


# Функция посылает сообщения
ping() {
  local file="$PIDsFile"
  
#  declare -a 
  
  while true; do
    local cpProcessData
    cpProcessData=$(findByName "$file" "${CP['name']}")
    local isCpFounded=$?
    
    # Если не нашли запись о КП
    if [ $isCpFounded -ne 0 ]; then
      sleep 1
      continue
    fi
    
    # Устанавливаем статус опроса
    updateFieldInFileByName "$file" "${CP['name']}" "pending" "true"
    sleep 1
    
    # Проходимся по именам станций
    local stationName
    for stationName in "${AllStationNames[@]}"; do
      # Ищем станцию в файле JSON по имени
      local stationData
      stationData=$(findByName "$file" "$stationName")
      local exists=$?

      # Если не нашли
      if [ "$exists" -eq 1 ]; then
        writeToFileCheckName "$file" "$(processToJSON "$stationName")"
        sendDataToCP "$stationName" "$(getTime)" "${Messages['stationDisable']}"
        continue
      fi

      # Получаем поле, содержащее ответ
      local active pending
      active=$(getFieldValue "$stationData" "active")
      pending=$(getFieldValue "$stationData" "pending")
      
      # Станция была активна и сейчас не ответила
      if [[ $active == "true" && $pending == "false" ]]; then
        updateFieldInFileByName "$file" "$stationName" "active" "false"
        sendDataToCP "$stationName" "$(getTime)" "${Messages['stationDisable']}"
      fi
      
      # Станция была не активна и сейчас ответила
      if [[ $active == "false" && $pending == "true" ]]; then
        updateFieldInFileByName "$file" "$stationName" "active" "true"
        sendDataToCP "$stationName" "$(getTime)" "${Messages['stationActive']}"
      fi

      
#      # Проверяем ответила ли станция
#      if [[ $pending == "true" ]]; then
#        updateFieldInFileByName "$file" "$stationName" "active" "true"
#        sendDataToCP "$stationName" "$(getTime)" "${Messages['stationActive']}"
#      else
#        updateFieldInFileByName "$file" "$stationName" "active" "false"
#        sendDataToCP "$stationName" "$(getTime)" "${Messages['stationDisable']}"
#      fi
    done

    # Сбрасывем статус опроса
    sleep 1
    updateFieldInFileByName "$file" "${CP['name']}" "pending" "false"
    sleep 10
  done
}

# Функция отслеживает сообщения
handlePing() {
  local name=$1 # Имя станции
  
  local file="$PIDsFile"
  
  while true; do
    local cpProcessData
    cpProcessData=$(findByName "$file" "${CP['name']}")
    local isCpFounded=$?
    
    # Если не нашли запись о КП
    if [ $isCpFounded -ne 0 ]; then
      sleep 0.5
      continue
    fi
    
    local pending
    pending=$(getFieldValue "$cpProcessData" "pending")
    
    if [[ $pending == "true" ]]; then
      local stationProcessData
      stationProcessData=$(findByName "$file" "$name")
      local isStationFounded=$?
      
      # Если не нашли запись о станции
      if [ $isStationFounded -ne 0 ]; then
        sleep 0.5
        continue
      fi
      
      # Выставляем поле pending у станции
      updateFieldInFileByName "$file" "$name" "pending" "true"
    else
      updateFieldInFileByName "$file" "$name" "pending" "false"
    fi
    
    sleep 0.5
  done
}
