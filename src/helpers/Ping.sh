#!/bin/bash

# Credentials
source src/Credentials.sh

# Constants
source src/constants/Cp.sh
source src/constants/Messages.sh
source src/constants/Paths.sh
source src/constants/Variables.sh

# Helpers
source src/helpers/Code.sh
source src/helpers/Cp.sh
source src/helpers/Json.sh
source src/helpers/Other.sh
source src/helpers/Time.sh


ping() {
  local responseDirectory="${CPResponseDir:?}"
  local requestFile="${CPRequestFile:?}"
    
  while true; do
    # Проверяем, если файл с пингом
    if [ -e "$requestFile" ]; then
      continue
    fi

    # Кодируем текст пинга
    local encodedText
    encodedText=$(encodeText "${CPCheckText:?}")

    # Создаем файл пинга
    echo "$encodedText" > "$requestFile"

    # Ждем ответа станций
    sleep 1
    
    # Получаем файлы из директории с ответами
    declare -a files=()
    files=($(ls -lt "$responseDirectory" | awk '{print $9}'))
    
    # Проходимся по каждому файлу
    local file
    for file in "${files[@]}"; do
      if [ -f "$responseDirectory/$file" ]; then
        # Обработка данных
        local responseData
        responseData=$(decodeTextFromFile "$responseDirectory/$file")
        local isDecoded=$?

        # Отправляем сообщение о НСД
        if [ $isDecoded -eq 1 ]; then
          sendMessageToCP "${Messages['ping']}" "$(getTime)" "${Messages['unauthorizedAccess']}"
          continue
        fi        
        
        handleResponseType "$responseData"
#        handlePingAbort # TODO: можно добавить проверку, что пинг не пришел, если станцию криво убили
        
        # Удаляем рассмотренный файл
        rm "$responseDirectory/$file"
      fi
    done
    
    # Удаляем файл пинга
    rm "$requestFile"
    
    sleep 20
  done
}

handlePing() {
  local stationName=$1
  local stationPingPid=${2:-''}
  local stationPid=${3:-''}
  
  local requestFile="${CPRequestFile:?}"
  
  # Флаг
  local isFirst="true"
  
  while true; do
    if [ -e "$requestFile" ]; then
      if [[ $isFirst == "false" ]]; then
        sleep 0.5
        continue
      fi
    else
      isFirst="true"
    fi
    
    # Декодируем текст в файле
    local decodedText
    decodedText=$(decodeTextFromFile "$requestFile")
    local isDecoded=$?
    
    # Если не удалось декодировать 
    if [[ $isDecoded -eq 1 ]]; then
      sleep 0.5
      continue
    fi
    
    # Проверяем, что полученый текст совпал с ожидаемым
    if [[ $decodedText == "${CPCheckText:?}" ]]; then
      # Отправляем данные о станции
      sendPingToCP "$stationName" "$stationPingPid" "$stationPid"
    else
      # Отправляем сообщение о НСД
      sendMessageToCP "$stationName" "$(getTime)" "${Messages['unauthorizedAccess']}"
    fi

    isFirst="false"

    sleep 0.5
  done
}

handleResponseType() {
  local responseData=$1
  
  local stationsFile="${StationsFile:?}"
  
  # Извлекаем данные из JSON
  local type stationName
  type=$(getFieldValue "$responseData" "type")
  stationName=$(getFieldValue "$responseData" "name")
  
  case ${type} in
    "${CPResponseTypes['ping']}" ) # Если тип сообщения ping
      echo "Ping" >> logs/log.log
    
      # Ищем запись о станции в сохраненном файле
      findByName "$stationsFile" "$stationName" true
      local isFind=$?
      
      # Если не нашли запись
      if [[ $isFind -eq 1 ]]; then
        local writeData
        writeData=$(removeField "$responseData" "type")
        
        # Записываем данные в файл
        writeToFileCheckName "$stationsFile" "$writeData"
        
        # Отправляем сообщение на КП о том, что станция активна
        sendMessageToCP "$stationName" "$(getTime)" "${Messages['stationActive']}"
      fi
    ;;
    "${CPResponseTypes['update']}" ) # Если тип сообщения update
      echo "Update" >> logs/log.log
    
      local pingPid pid
      pingPid=$(getFieldValue "$responseData" "pingPid")
      pid=$(getFieldValue "$responseData" "pid")

      updateFieldInFileByName "$stationsFile" "$stationName" "pingPid" "$pingPid"
      updateFieldInFileByName "$stationsFile" "$stationName" "pid" "$pid"
    ;;
    "${CPResponseTypes['delete']}" ) # Если тип сообщения delete
      echo "Delete" >> logs/log.log
    
      # Удаляем информацию о станции из файла
      removeFromFile "$stationsFile" "name" "$stationName"
      
      # Отправляем сообщение на КП о том, что станция не активна
      sendMessageToCP "$stationName" "$(getTime)" "${Messages['stationDisable']}"
  esac
}
