#!/bin/bash

# Функция добавляет запись в файл формата JSON
# Возвращает 1, если запись уже была в файле (то есть не удалось записать ее)
# Возвращает 0, если записи не было в файле (то есть удалось записать ее)
writeToFile() {
  local file=$1
  local data=$2
  
  local id
  id=$(echo "$data" | jq -r '.id')
  
  # Проверяем, что файл существует и он не пустой
  if [ -s "$file" ]; then
    # Проверяем, что в файле есть запись с таким ID
    if (findByID "$file" "$id" true); then
      return 1 # Если запись уже существует -> выходим из функции
    fi
    
    # Файл существует и записи нет -> добавляем запись в конец массива в файле
    jq --argjson data "$data" '. += [$data]' "$file" > "$file.tmp" && mv "$file.tmp" "$file"
  else
    # Файл не существует -> создаем новый массив и записываем его в новый файл
    echo "[$data]" > "$file"
  fi

  return 0
}

# Функция удаляет запись по ID в файле формата JSON
# Возвращает 1, если файла не существует или не удалось найти запись
# Возвращает 0, если удалось удалить запись
removeFromFile() {
  local file=$1
  local id=$2
  
  # Проверяем, существует и он не пустой
  if [ ! -f "$file" ]; then
    return 1 # Файл не существует -> выходим
  fi
  
  # Проверяем, что в файле есть запись с таким ID
  if (findByID "$file" "$id" true); then
    # Удаляем запись из файла
    jq "del(.[] | select(.id == \"$id\"))" "$file" > "$file.tmp" && mv "$file.tmp" "$file"
    return 0
  else
    return 1
  fi
}

# Функция ищет запись по ID в файле формата JSON
# Возвращает 1, если файла не существует или не удалось найти запись
# Возвращает 0, если запись была найдена
# Дополнительно возвращает запись, если третий параметр = true
findByID() {
  local file=$1
  local id=$2
  local quiet=${3:-false}  # Аргумент для "тихого" режима, по умолчанию всегда не "тихий"
  
  # Проверяем, существует ли файл
  if [ ! -f "$file" ]; then
    return 1 # Файл не существует -> выходим
  fi

  # Ищем запись по ID
  local founded
  founded=$(jq --arg id "$id" '.[] | select(.id == $id)' "$file")
  
  if [[ -z $founded ]]; then
    return 1  # Запись не найдена
  else
    if [[ $quiet == "false" ]]; then
      echo "$founded" # Если не "тихий" режим -> выводим найденную запись
    fi
    
    return 0  # Запись найдена
  fi
}

# Функция возвращает ID всех записей в файле формата JSON (в виде строки)
getIDsFromFile() {
  local file="$1"
  
  # Проверяем, существует ли файл
  if [ ! -f "$file" ]; then
    return 1
  fi

  # Извлекаем значения ключа ID из массива объектов JSON
  local ids
  ids=$(jq -r '.[].id' "$file")

  # Возвращаем значения ID, разделенные пробелом
  echo "$ids"
}

# Функция обновляет значение поля по ID в файле формата JSON
# Возвращает 1, если не удалось обновить поле
# Возвращает 0, если удалось обновить поле
updateFieldInFileByID() {
  local file="$1"
  local id="$2"
  local fieldName="$3"
  local fieldValue="$4"

  # Проверяем, есть ли запись с таким ID
  findByID "$file" "$id" true
  local found=$?
  
  if [ $found -ne 0 ]; then
    return 1
  fi

  # Если запись найдена, обновляем поле
  local updatedData
  updatedData=$(jq --arg id "$id" --arg fieldName "$fieldName" --arg fieldValue "$fieldValue" \
    'map(if .id == $id then .[$fieldName] = $fieldValue else . end)' "$file")
  local updated=$?
  
  if [ $updated -ne 0 ]; then
    return 1
  fi
  
  # Сохраняем обновленные данные обратно в файл
  echo "$updatedData" > "$file"
  
  return 0
}

# Функция возвращает содержимое некоторого поля в строке формата JSON
# Возвращает 1, если были переданы не все поля, поля с таким именем нет или значение пустое
# Возвращает 0, если поле было найдено (также возвращает само значение поля)
getFieldValue() {
  local jsonData="$1"
  local fieldName="$2"

  # Проверяем, переданы ли все параметры
  if [ -z "$jsonData" ] || [ -z "$fieldName" ]; then
    return 1
  fi

  # Извлекаем значение поля
  local fieldValue
  fieldValue=$(jq -r --arg fieldName "$fieldName" '.[$fieldName]' <<<"$jsonData")

  # Проверяем, было ли найдено значение для указанного поля
  if [ -z "$fieldValue" ]; then
    return 1
  fi

  echo "$fieldValue"
  return 0
}
