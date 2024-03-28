#!/bin/bash

# Helpers
source src/helpers/Json.sh
source src/helpers/Math.sh
source src/helpers/Other.sh
source src/helpers/Target.sh

# Dtos
source src/dtos/Target.sh

runRLS() {
  # Функция для обработки каждой цели
  processTarget() {
    local file="$1"
    
    # Получаем информацию о цели (id x y)
    local targetInfo id x y
    targetInfo=($(getTargetInfo "$file"))
    id="${targetInfo[0]}"
    x="${targetInfo[1]}"
    y="${targetInfo[2]}"

    # Считаем расстояние от цели до РЛС
    local dx dy
    dx=$(echo "scale=$scale;$x - ${RLSMap['x']}" | bc)
    dy=$(echo "scale=$scale;$y - ${RLSMap['y']}" | bc)

    # Проверяем, находится ли цель в секторе обнаружения РЛС
    if (inSector "$dx" "$dy" "${RLSMap['distance']}" "${RLSMap['angle']}" "${RLSMap['deviation']}"); then
        handleRLSTarget "$id" "$x" "$y"
    fi
  }
  
  # Функция для обработки взаимодействия РЛС и цели
  handleRLSTarget() {
    local id="$1"
    local x="$2"
    local y="$3"

    # Ищем цель в файле с обнаруженными целями
    findByID "${RLSMap['jsonFile']}" "$id" true

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
    writeToFile "${RLSMap['jsonFile']}" "$data"
  }
  
  # Функция для обработки существующей цели
  handleExistingTarget() {
    local id="$1"
    local x="$2"
    local y="$3"
    
    # Ищем цель в файле с обнаруженными целями
    local targetData
    targetData=$(findByID "${RLSMap['jsonFile']}" "$id")

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

        updateFieldInFileByID "${RLSMap['jsonFile']}" "$id" "speed" "$speed"
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
    
    # Проверяем, что тип из тех, которые обнаруживает РЛС
    if (checkIn "$type" "${RLSMap['targets']}"); then
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
    targetData=$(findByID "${RLSMap['jsonFile']}" "$id")

    # Получаем поля цели
    local speed prevX prevY discovered
    speed=$(getFieldValue "$targetData" "speed")
    prevX=$(getFieldValue "$targetData" "x")
    prevY=$(getFieldValue "$targetData" "y")
    discovered=$(getFieldValue "$targetData" "discovered")

    # Если цель не была обнаружена (не передавали о ней информацию), то передаем
    if [[ "$discovered" == "false" ]]; then
        echo "Обнаружена цель c ID - ${id} и координатами X - ${x} Y - ${y}"

        # Если цель летит в сторону СПРО, то также сообщаем об этом
        if (isWillCross "$prevX" "$prevY" "$x" "$y" "${SPROMap['x']}" "${SPROMap['y']}" "${SPROMap['distance']}"); then
            echo "Цель c ID - ${id} движется в направлении СПРО"
        fi

        # Обновляем поле цели, так как теперь она обнаружена
        updateFieldInFileByID "${RLSMap['jsonFile']}" "$id" "discovered" true
    fi
  }
  
  # Получаем ассоциативные массивы значений РЛС и СПРО
  local -n RLSMap=$1
  local -n SPROMap=$2
  
  echo "${RLSMap['name']} started"
  
  while true; do
    # Считываем цели
    declare -a files=()
    files=($(readGeneratedTargets))

    # Проверяем существуют ли они
    local filesExists=$?
    if [ $filesExists -eq 1 ]; then 
      echo "Targets not exists"
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
