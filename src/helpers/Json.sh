#!/bin/bash

# Функция добавляет запись в файл формата JSON
# Возвращает 1, если запись уже была в файле (то есть не удалось записать ее)
# Возвращает 0, если записи не было в файле (то есть удалось записать ее)
# Дополнительно, третий параметр - тот, по которому проверяем уникальность
writeToFile() {
  local file=$1
  local data=$2
  local field=${3:-id} # По умолчанию поле для проверки - id
  
  local value
  value=$(echo "$data" | jq -r --arg field "$field" '.[$field]')
  
  # Проверяем, что файл существует и он не пустой
  if [ -s "$file" ]; then
    # Проверяем, что в файле есть запись с таким значением в указанном поле
    if (findByField "$file" "$field" "$value" true); then
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

# Функция добавляет запись в файл формата JSON
# Проверяет уникальность по полю name
writeToFileCheckName() {
  local file=$1
  local data=$2
  
  writeToFile "$file" "$data" "name"
}


# Функция удаляет запись по некоторому полю в файле формата JSON
# Возвращает 1, если файла не существует или не удалось найти запись
# Возвращает 0, если удалось удалить запись
removeFromFile() {
  local file=$1
  local field=$2
  local value=$3
  
  # Проверяем, существует и он не пустой
  if [ ! -f "$file" ]; then
    return 1 # Файл не существует -> выходим
  fi
  
  # Проверяем, что в файле есть запись с таким значением поля
  if (findByField "$file" "$field" "$value" true); then
    # Удаляем запись из файла
    jq "del(.[] | select(.$field == \"$value\"))" "$file" > "$file.tmp" && mv "$file.tmp" "$file"
    return 0
  else
    return 1
  fi
}


# Функция ищет запись по заданному полю и значению в файле формата JSON
# Возвращает 1, если файла не существует, не удалось найти запись, или произошла ошибка
# Возвращает 0, если запись была найдена
# Дополнительно возвращает запись, если четвертый параметр = true
findByField() {
  local file=$1
  local field=$2
  local value=$3
  local quiet=${4:-false}  # Аргумент для "тихого" режима, по умолчанию всегда не "тихий"
  
  # Проверяем, существует ли файл
  if [ ! -f "$file" ]; then
    return 1 # Файл не существует -> выходим
  fi

  # Ищем запись по заданному полю и значению
  local founded
  founded=$(jq --arg field "$field" --arg value "$value" '.[] | select(.'"$field"' == $value)' "$file")
  
  if [[ -z $founded ]]; then
    return 1  # Запись не найдена
  else
    if [[ $quiet == "false" ]]; then
      echo "$founded" # Если не "тихий" режим -> выводим найденную запись
    fi
    
    return 0  # Запись найдена
  fi
}

# Функция ищет запись по ID в файле формата JSON
# Дополнительно возвращает запись, если третий параметр = true
findByID() {
  local file=$1
  local id=$2
  local quiet=${3:-false}  # Аргумент для "тихого" режима, по умолчанию всегда не "тихий"
  
  findByField "$file" "id" "$id" "$quiet"
}

# Функция ищет запись по имени станции в файле формата JSON
# Дополнительно возвращает запись, если третий параметр = true
findByName() {
  local file=$1
  local name=$2
  local quiet=${3:-false}  # Аргумент для "тихого" режима, по умолчанию всегда не "тихий"
  
  findByField "$file" "name" "$name" "$quiet"
}


# Функция вовзвращает все значения некоторого поля в файле формата JSON (в виде строки)
getFieldsFromFile() {
  local file="$1"
  local field="${2:-id}" # Второй параметр с значением по умолчанию 'id'
  
  # Проверяем, существует ли файл
  if [ ! -f "$file" ]; then
    return 1
  fi

  # Извлекаем значения указанного ключа (по умолчанию ключа ID) из массива объектов JSON
  local fields
  fields=$(jq -r --arg field "$field" '.[] | .[$field]' "$file")

  # Возвращаем значения, разделенные пробелом
  echo "$fields"
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

# Функция обновляет значение поля по name в файле формата JSON
# Возвращает 1, если не удалось обновить поле
# Возвращает 0, если удалось обновить поле
updateFieldInFileByName() {
  local file="$1"
  local name="$2"
  local fieldName="$3"
  local fieldValue="$4"

  # Проверяем, есть ли запись с таким name
  findByName "$file" "$name" true
  local found=$?
  
  if [ $found -ne 0 ]; then
    return 1
  fi

  # Если запись найдена, обновляем поле
  local updatedData
  updatedData=$(jq --arg name "$name" --arg fieldName "$fieldName" --arg fieldValue "$fieldValue" \
    'map(if .name == $name then .[$fieldName] = $fieldValue else . end)' "$file")
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


addField() {
  local jsonData=$1
  local field=$2
  local value=$3
  
  echo "$jsonData" | jq --arg field "$field" --arg value "$value" '. + {($field): $value}'
}

removeField() {
  local jsonData=$1
  local field=$2
  
  echo "$jsonData" | jq "del(.\"$field\")"
}
