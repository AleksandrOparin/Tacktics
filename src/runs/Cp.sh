#!/bin/bash

# Constants
source src/constants/Cp.sh
source src/constants/Messages.sh
source src/constants/Paths.sh

# Dtos
source src/dtos/Process.sh

# Helpers
source src/helpers/Cp.sh
source src/helpers/Db.sh
source src/helpers/Format.sh
source src/helpers/Json.sh
source src/helpers/Ping.sh
source src/helpers/Time.sh


runCP() {  
  local directory=$CPMessagesDir
  
  # Проверяем, что КП еще не запущен
  if (findByName "$PIDsFile" "${CP['name']}" true); then
    return
  fi
  
  # Сохраняем информацию о станции
  writeToFile "$PIDsFile" "$(processToJSON "${CP['name']}" "" "" "true")" "name"
  
  # Активируем отправку сообщений
  ping &
  updateFieldInFileByName "$PIDsFile" "${CP['name']}" "workPid" "$!"
  
  # Цикл для непрерывного чтения файлов
  while true; do
    # Объявляем массив файлов и считываем их
    declare -a files=()
    files=($(ls -rt "$directory"))
  
    # Перебираем файлы
    local file
    for file in "${files[@]}"; do
      if [ -f "$directory/$file" ]; then
        # Обработка данных
        local jsonData
        jsonData=$(decryptDataFromPC "$directory/$file")
        local isDecrypted=$?
        
        if [ $isDecrypted -eq 1 ]; then
          insertMessageInDB "${Messaages['unknown']}" "$(getTime)" "${Messaages['unauthorizedAccess']}"
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
        insertMessageInDB "$stationName" "$detectedTime" "$message" "$targetId" "$targetType" "$targetX" "$targetY"
        format "$stationName" "$detectedTime" "$message" "$targetId" "$targetType" "$targetX" "$targetY" >> "$AllLogsFile"
        format "$stationName" "$detectedTime" "$message" "$targetId" "$targetType" "$targetX" "$targetY" >> "${LogsDir}/${stationName}.log"

                
        # Удаляем файл после обработки
        rm "$directory/$file"
      fi
    done

    sleep 0.5
  done
}
