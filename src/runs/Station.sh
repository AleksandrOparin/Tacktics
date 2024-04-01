#!/bin/bash

# Helpers
source src/helpers/Json.sh
source src/helpers/Math.sh
source src/helpers/Other.sh
source src/helpers/Target.sh

# Dtos
source src/dtos/Message.sh
source src/dtos/Target.sh

# Runs
source src/runs/Cp.sh


runStation() {
  # Функция для обработки каждой цели
  processTarget() {
    local file="$1"
    
    # Получаем информацию о цели (id x y)
    local targetInfo id x y
    targetInfo=($(getTargetInfo "$file"))
    id="${targetInfo[0]}"
    x="${targetInfo[1]}"
    y="${targetInfo[2]}"

    # Считаем расстояние от цели до станции
    local dx dy
    dx=$(echo "scale=$scale;$x - ${StationMap['x']}" | bc)
    dy=$(echo "scale=$scale;$y - ${StationMap['y']}" | bc)

    # Проверяем, находится ли цель в секторе обнаружения станции
    if (inSector "$dx" "$dy" "${StationMap['distance']}" "${StationMap['angle']}" "${StationMap['deviation']}"); then
        handleRLSTarget "$id" "$x" "$y"
    fi
  }
  
  # Функция для обработки взаимодействия станции и цели
  handleRLSTarget() {
    local id="$1"
    local x="$2"
    local y="$3"

    # Ищем цель в файле с обнаруженными целями
    findByID "${StationMap['jsonFile']}" "$id" true

    # Если записи о цели не было, то это первое обнаружение этой цели
    local findedTargetExists=$?
    if [ "$findedTargetExists" -eq 1 ]; then
        handleNewTarget "$id" "$x" "$y"
        return
    fi
    
    # Если была, то мы уже обнариживали эту цель
    handleExistingTarget "$id" "$x" "$y"
  }
  
  # Функция для обработки новой цели
  handleNewTarget() {
    local id="$1"
    local x="$2"
    local y="$3"

    # Формируем JSON из данных о цели
    local data
    data=$(targetToJSON "$id" "$x" "$y")

    # Записываем сформированный JSON в файл
    writeToFile "${StationMap['jsonFile']}" "$data"
  }
  
  # Функция для обработки существующей цели
  handleExistingTarget() {
    local id="$1"
    local x="$2"
    local y="$3"
    
    # Ищем цель в файле с обнаруженными целями
    local targetData
    targetData=$(findByID "${StationMap['jsonFile']}" "$id")

    # Получаем поля цели
    local speed prevX prevY
    speed=$(getFieldValue "$targetData" "speed")
    prevX=$(getFieldValue "$targetData" "x")
    prevY=$(getFieldValue "$targetData" "y")

    # Проверяем скорость цели
    if [ -z "$speed" ]; then
        local targetDx targetDy
        targetDx=$(echo "scale=$scale;$x - $prevX" | bc)
        targetDy=$(echo "scale=$scale;$y - $prevY" | bc)

        speed=$(sqrt "$targetDx" "$targetDy")

        updateFieldInFileByID "${StationMap['jsonFile']}" "$id" "speed" "$speed"
    fi

    checkTargetType "$id" "$x" "$y" "$speed"
  }
  
  # Функция для проверки типа цели
  checkTargetType() {
    local id="$1"
    local x="$2"
    local y="$3"
    local speed="$4"

    # Получаем тип цели в зависимости от скорости
    local type
    type=$(getTargetType "$speed")
    
    # Проверяем, что тип из тех, которые обнаруживает станция
    if (checkIn "$type" "${StationMap['targets']}"); then
        handleDetectedTarget "$id" "$x" "$y"
    fi
  }
  
  # Функция для обработки обнаруженной цели
  handleDetectedTarget() {
    local id="$1"
    local x="$2"
    local y="$3"
    
    # Ищем цель в файле с обнаруженными целями
    local targetData
    targetData=$(findByID "${StationMap['jsonFile']}" "$id")

    # Получаем поля цели
    local speed prevX prevY discovered
    speed=$(getFieldValue "$targetData" "speed")
    prevX=$(getFieldValue "$targetData" "x")
    prevY=$(getFieldValue "$targetData" "y")
    discovered=$(getFieldValue "$targetData" "discovered")

    # Если цель не была обнаружена (не передавали о ней информацию), то передаем
    local message=""
    if [[ "$discovered" == "false" ]]; then
        message="Обнаружена цель c ID - ${id} и координатами X - ${x} Y - ${y}"
        sendDataToCP "$(messageToJSON "${StationMap['name']}" "$message")"

        # Если цель летит в сторону СПРО, то также сообщаем об этом
        if (isWillCross "$prevX" "$prevY" "$x" "$y" "${SPROMap['x']}" "${SPROMap['y']}" "${SPROMap['distance']}"); then
            message="Цель c ID - ${id} движется в направлении СПРО"
            sendDataToCP "$(messageToJSON "${StationMap['name']}" "$message")"
        fi

        # Обновляем поле цели, так как теперь она обнаружена
        updateFieldInFileByID "${StationMap['jsonFile']}" "$id" "discovered" true
    fi
  }
  
  # Получаем ассоциативные массивы значений станции и СПРО
  local -n StationMap=$1
  local -n SPROMap=$2
  
  echo "${StationMap['name']} запущена"
  
  while true; do
    # Считываем цели
    declare -a files=()
    files=($(readGeneratedTargets))

    # Проверяем существуют ли они
    local filesExists=$?
    if [ $filesExists -eq 1 ]; then
      sleep 1
    fi

    # Проходимся по каждой цели
    local file
    for file in "${files[@]}"; do
      processTarget "$file"
    done
    
    sleep .6
  done
}
