#!/bin/bash

source src/Credentials.sh

source src/constants/Paths.sh

source src/db/Db.sh

source src/helpers/Random.sh
source src/helpers/Json.sh

sendDataToCP() {
  local jsonData=$1
  
  # Шифруем данные
  local encryptedData
  encryptedData=$(echo "$jsonData" | openssl enc -aes-256-cbc -e -a -pbkdf2 -iter "$ItersCount" -k "$Password")
  
  # Вычисляем контрольную сумму зашифрованных данных
  local checksum
  checksum=$(echo -n "$encryptedData" | md5sum | awk '{print $1}')
  
  # Создаем файл
  local file
  file="$MessagesPath/$(generateRandomSequence)"
    
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

runCP() {
  local directory=$MessagesPath
  
  # Цикл для непрерывного чтения файлов
  while true; do
    # Объявляем массив файлов и считываем их
    declare -a files=()
    files=($(ls "$directory"))
    echo "$files"
  
    # Перебираем файлы
    local file
    for file in "${files[@]}"; do
      if [ -f "$directory/$file" ]; then
        # Обработка данных
        local jsonData
        jsonData=$(decryptDataFromPC "$directory/$file")
        local isDecrypted=$?
        
        if [ $isDecrypted -eq 1 ]; then
          insertInDB "Неизвестно" "Не совпадают контрольные суммы, попытка НСД!"
          continue
        fi
        
        # Извлекаем данные из JSON
        local name message
        name=$(getFieldValue "$jsonData" "name")
        message=$(getFieldValue "$jsonData" "message")
        
        # Добавляем запись в БД
        echo "insertInDB $name" "$message"
        insertInDB "$name" "$message"
        
        # Удаляем файл после обработки
        rm "$directory/$file"
      fi
    done

    # Ждем 0.5 секунды перед повторной проверкой
    sleep 0.5
  done
}
