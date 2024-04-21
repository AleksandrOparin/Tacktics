#!/bin/bash

# Constants
source src/constants/Cp.sh
source src/constants/Messages.sh
source src/constants/Paths.sh

# Dtos
source src/dtos/Process.sh
source src/dtos/Station.sh

# Helpers
source src/helpers/Code.sh
source src/helpers/Cp.sh
source src/helpers/Format.sh
source src/helpers/Json.sh
source src/helpers/Ping.sh
source src/helpers/Time.sh


runCP() {  
  local directory="${CPTargetsDir:?}"
  
  # Проверяем, запущен ли КП
  if [[ -e "${CP['stationFile']}" ]]; then
    echo "${CP['name']} уже запущена"
    return
  else
    echo "${CP['name']} запущен"
  fi
  
  # Активируем отправку сообщений и запоминаем PID
  ping &
  local stationPingPid="$!"
  
  # Сохраняем информацию о том, что КП запущен
  writeToFileCheckName "${CP['stationFile']}" "$(stationToJSON "${CP['name']}" "$stationPingPid")"
  writeToFileCheckName "${StationsFile:?}" "$(stationToJSON "${CP['name']}" "$stationPingPid")"

  # Цикл для непрерывного чтения файлов
  while true; do
    # Проверяем, запущен ли КП
    if [[ ! -e "${CP['stationFile']}" ]]; then
      sleep 0.5
      continue
    fi
        
    # Объявляем массив файлов и считываем их
    declare -a files=()
    files=($(ls -lt "$directory"))
      
    # Перебираем файлы
    local file
    for file in "${files[@]}"; do
      if [ -f "$directory/$file" ]; then
        # Обработка данных
        local jsonData
        jsonData=$(decodeTextFromFile "$directory/$file")
        local isDecrypted=$?
        
        # Отправляем сообщение о НСД
        if [ $isDecrypted -eq 1 ]; then
          saveMessage "${Messages['unknown']}" "$(getTime)" "${Messages['unauthorizedAccess']}"
          continue
        fi
        
        # Извлекаем данные из JSON
        local stationName detectedTime message targetId targetType targetX targetY
        stationName=$(getFieldValue "$jsonData" "stationName")
        detectedTime=$(getFieldValue "$jsonData" "detectedTime")
        message=$(getFieldValue "$jsonData" "message")
        targetId=$(getFieldValue "$jsonData" "targetId")
        targetType=$(getFieldValue "$jsonData" "targetType")
        targetX=$(getFieldValue "$jsonData" "targetX")
        targetY=$(getFieldValue "$jsonData" "targetY")
        
        # Добавляем запись в БД и в логи
        saveMessage "$stationName" "$detectedTime" "$message" "$targetId" "$targetType" "$targetX" "$targetY"
        format "$stationName" "$detectedTime" "$message" "$targetId" "$targetType" "$targetX" "$targetY" >> "${LogsDir:?}/${stationName}.log"
     
        # Удаляем файл после обработки
        rm "$directory/$file"
      fi
    done
    
    sleep 0.5
  done
}
