#!/bin/bash

# Constants
source src/constants/Spro.sh

# Helpers
source src/helpers/Json.sh
source src/helpers/Math.sh
source src/helpers/Other.sh
source src/helpers/Target.sh

# Dtos
source src/dtos/Target.sh

runSPRO() {
  # Функция для обработки каждой цели
  processTarget() {
    local file="$1"
    
    # Получаем информацию о цели (id x y)
    local targetInfo id x y
    targetInfo=($(getTargetInfo "$file"))
    id="${targetInfo[0]}"
    x="${targetInfo[1]}"
    y="${targetInfo[2]}"

    # Считаем расстояние от цели до СПРО
    local dx dy
    dx=$(echo "scale=$scale;$x - ${SPROMap['x']}" | bc)
    dy=$(echo "scale=$scale;$y - ${SPROMap['y']}" | bc)

    # Проверяем, находится ли цель в секторе обнаружения СПРО
    if (inCircle "$dx" "$dy" "${SPROMap['distance']}"); then
        handleSPROTarget "$id" "$x" "$y"
    fi
  }
  
  # Функция для обработки взаимодействия СПРО и цели
  handleSPROTarget() {
    local id="$1"
    local x="$2"
    local y="$3"

    # Ищем цель в файле с обнаруженными целями
    findByID "${SPROMap['jsonFile']}" "$id" true

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
    writeToFile "${SPROMap['jsonFile']}" "$data"
  }
  
  # Функция для обработки существующей цели
  handleExistingTarget() {
    local id="$1"
    local x="$2"
    local y="$3"
    
    # Ищем цель в файле с обнаруженными целями
    local targetData
    targetData=$(findByID "${SPROMap['jsonFile']}" "$id")

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

        updateFieldInFileByID "${SPROMap['jsonFile']}" "$id" "speed" "$speed"
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
    if (checkIn "$type" "${SPROMap['targets']}"); then
        handleDetectedTarget "$id" "$x" "$y"
        handleShootTarget "$id"
    fi
  }
  
  # Функция для обработки обнаруженной цели
  handleDetectedTarget() {
    local id="$1"
    local x="$2"
    local y="$3"
    
    # Ищем цель в файле с обнаруженными целями
    local targetData
    targetData=$(findByID "${SPROMap['jsonFile']}" "$id")

    # Получаем поля цели
    local speed prevX prevY discovered
    speed=$(getFieldValue "$targetData" "speed")
    prevX=$(getFieldValue "$targetData" "x")
    prevY=$(getFieldValue "$targetData" "y")
    discovered=$(getFieldValue "$targetData" "discovered")

    # Если цель не была обнаружена (не передавали о ней информацию), то передаем
    if [[ "$discovered" == "false" ]]; then
        echo "Обнаружена цель c ID - ${id} и координатами X - ${x} Y - ${y}"

        # Обновляем поле цели, так как теперь она обнаружена
        updateFieldInFileByID "${SPROMap['jsonFile']}" "$id" "discovered" true
    fi
  }
  
  handleShootTarget() {
    local id="$1"
    
    if [ "$amount" -le 0 ]; then
      echo "У ${SPROMap['name']} закончились снаряды"
      return
    fi
    
    # Данные текущей цели
    local currentTargetData
    currentTargetData=$(findByID "${SPROMap['jsonFile']}" "$id")
    
    # Получаем флаг о том, стреляли ли мы раньше в эту цель
    checkInArray "$id" "${shootTargetsIDs[@]}"
    local isShootInTarget=$?
    
    # Поверяем выстрел
    if [ "$isShootInTarget" -eq 1 ]; then # Если не стреляли ранее
      echo "$id" > "tmp/GenTargets/Destroy/$id"
      ((amount--))
      writeToFile "${SPROMap['shotFile']}" "$currentTargetData"

      echo "Выстрел в цель с ID - ${id}"
    else # Если стреляли ранее
      echo "Промах по цели с ID - ${id}"
#      echo "shootTargetsIDs - ${shootTargetsIDs[@]} до удаления элемента с ID - ${id}"
      shootTargetsIDs=($(removeInArray "$id" "${shootTargetsIDs[@]}"))
#      echo "shootTargetsIDs - ${shootTargetsIDs[@]} после удаления элемента с ID - ${id}"


      echo "$id" > "tmp/GenTargets/Destroy/$id"
      ((amount--))
      writeToFile "${SPROMap['shotFile']}" "$currentTargetData"

      echo "Выстрел в цель с ID - ${id}"
    fi
  }
  
  # Получаем ассоциативный массив значений СПРО
  local -n SPROMap=$1
  
  local -a shootTargetsIDs=()
  local amount="${SPROMap['amount']}"
  
  echo "${SPROMap['name']} запущена"
  
  while true; do
    # Считываем цели
    declare -a files=()
    files=($(readGeneratedTargets))

    # Проверяем существуют ли они
    local filesExists=$?
    if [ $filesExists -eq 1 ]; then 
      echo "Целей не существует"
      sleep 1
    fi
    
    # Получаем все ID целей, по которым стреляли в прошлом цикле
    shootTargetsIDs=($(getIDsFromFile "${SPROMap['shotFile']}"))
    true >"${SPROMap['shotFile']}" # Очищаем файл
    
#    echo "Все ID целей, в которые выстрелил в прошлой итерации - ${shootTargetsIDs[@]}"
#    echo "Полученные 30 целей - ${files[@]}"

    # Проходимся по каждой цели
    local file
    for file in "${files[@]}"; do
      processTarget "$file"
    done
    
    # Проверяем, какие цели мы уничтожили
    local targetID 
    for targetID in "${shootTargetsIDs[@]}"; do
      echo "Цель с ID - ${targetID} уничтожена"
    done
    shootTargetsIDs=()
    
    sleep .9
  done
}

runSPRO SPRO > logs/SPRO.log 2>&1 &
echo $! > temp/pids.txt

sleep .5

./GenTargets.sh &
echo $! >> temp/pids.txt
