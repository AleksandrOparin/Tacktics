#!/bin/bash

# Credentials
source src/Credentials.sh

# Constants
source src/constants/Paths.sh

# Dtos
source src/dtos/Message.sh

# Helpers
source src/helpers/Random.sh


sendDataToCP() {
  local stationName=$1
  local detectedTime=$2
  local messageText=$3
  local targetId=${4:-''}
  local targetType=${5:-''}
  local targetX=${6:-''}
  local targetY=${7:-''}
  
  local jsonData
  jsonData=$(messageToJSON "$stationName" "$detectedTime" "$messageText" "$targetId" "$targetType" "$targetX" "$targetY")
  
  # Шифруем данные
  local encryptedData
  encryptedData=$(echo "$jsonData" | openssl enc -aes-256-cbc -e -a -pbkdf2 -iter "$ItersCount" -k "$Password")
  
  # Вычисляем контрольную сумму зашифрованных данных
  local checksum
  checksum=$(echo -n "$encryptedData" | md5sum | awk '{print $1}')
  
  # Создаем файл
  local file
  file="$MessagesDir/$(generateRandomSequence)"
    
  # Записываем в него зашифрованные данные и контрольную сумму
  echo "$encryptedData$checksum" > "$file"
}

decryptDataFromPC() {
  local file=$1
  
  local encryptedDataWithChecksum
  encryptedDataWithChecksum=$(cat "$file")
  
  # Читаем зашифрованные данные и контрольную сумму
  local checksum encryptedData
  checksum=${encryptedDataWithChecksum: -32}
  encryptedData=${encryptedDataWithChecksum%"$checksum"}
  
  # Проверяем контрольную сумму
  local calculatedChecksum
  calculatedChecksum=$(echo -n "$encryptedData" | md5sum | awk '{print $1}')
  if [[ "$calculatedChecksum" != "$checksum" ]]; then
      return 1
  fi
  
  # Декодируем данные
  local jsonData
  jsonData=$(echo "$encryptedData" | openssl enc -aes-256-cbc -d -a -pbkdf2 -iter "$ItersCount" -k "$Password")

  # Возвращаем данные
  echo "$jsonData"
}