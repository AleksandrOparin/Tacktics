#!/bin/bash

# Constants
source src/constants/Messages.sh
source src/constants/Paths.sh

# Helpers
source src/helpers/Cp.sh
source src/helpers/Json.sh
source src/helpers/Math.sh
source src/helpers/Other.sh
source src/helpers/Ping.sh
source src/helpers/Target.sh
source src/helpers/Time.sh

# Dtos
source src/dtos/Target.sh


runPowerStation() {
  # Функция для обработки каждой цели
  processTarget() {
    local file=$1
    
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
    if (inCircle "$dx" "$dy" "${StationMap['distance']}"); then
        handleSPROTarget "$id" "$x" "$y"
    fi
  }
  
  # Функция для обработки взаимодействия станции и цели
  handleSPROTarget() {
    local id=$1
    local x=$2
    local y=$3

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
    local id=$1
    local x=$2
    local y=$3

    # Формируем JSON из данных о цели
    local data
    data=$(targetToJSON "$id" "$x" "$y")

    # Записываем сформированный JSON в файл
    writeToFile "${StationMap['jsonFile']}" "$data"
  }
  
  # Функция для обработки существующей цели
  handleExistingTarget() {
    local id=$1
    local x=$2
    local y=$3
    
    # Ищем цель в файле с обнаруженными целями
    local targetData
    targetData=$(findByID "${StationMap['jsonFile']}" "$id")

    # Получаем поля цели
    local speed type prevX prevY
    speed=$(getFieldValue "$targetData" "speed")
    type=$(getFieldValue "$targetData" "type")
    prevX=$(getFieldValue "$targetData" "x")
    prevY=$(getFieldValue "$targetData" "y")

    # Проверяем скорость цели
    if [ -z "$speed" ]; then
        local targetDx targetDy
        targetDx=$(echo "scale=$scale;$x - $prevX" | bc)
        targetDy=$(echo "scale=$scale;$y - $prevY" | bc)

        speed=$(sqrt "$targetDx" "$targetDy") # Считаем скорость цели
        type=$(getTargetType "$speed") # Получаем тип цели в зависимости от скорости

        # Обновляем поля в файле
        updateFieldInFileByID "${StationMap['jsonFile']}" "$id" "speed" "$speed"
        updateFieldInFileByID "${StationMap['jsonFile']}" "$id" "type" "$type"
    fi

    checkTargetType "$id" "$x" "$y" "$type"
  }
  
  # Функция для проверки типа цели
  checkTargetType() {
    local id=$1
    local x=$2
    local y=$3
    local type=$4
    
    # Проверяем, что тип из тех, которые обнаруживает РЛС
    if (checkIn "$type" "${StationMap['targets']}"); then
        handleDetectedTarget "$id" "$x" "$y" "$type"
        handleShootTarget "$id" "$x" "$y" "$type"
    fi
  }
  
  # Функция для обработки обнаруженной цели
  handleDetectedTarget() {
    local id=$1
    local x=$2
    local y=$3
    local type=$4
    
    # Ищем цель в файле с обнаруженными целями
    local targetData
    targetData=$(findByID "${StationMap['jsonFile']}" "$id")

    # Получаем поля цели
    local detected
    detected=$(getFieldValue "$targetData" "detected")

    # Если цель не была обнаружена (не передавали о ней информацию), то передаем
    if [[ "$detected" == "false" ]]; then
        sendDataToCP "${StationMap['name']}" "$(getTime)" "${Messages['targetDetected']}" "$id" "$type" "$x" "$y"

        # Обновляем поле цели, так как теперь она обнаружена
        updateFieldInFileByID "${StationMap['jsonFile']}" "$id" "detected" true
        updateFieldInFileByID "${StationMap['jsonFile']}" "$id" "detectedTime" "$(getTime)"
    fi
  }
  
  handleShootTarget() {
    local id=$1
    local x=$2
    local y=$3
    local type=$4
    
    # Костыль, чтобы отправить всего 1 соообщение о том, что закончились снаряды
    if [ "$amount" -eq 0 ]; then
      sendDataToCP "${StationMap['name']}" "$(getTime)" "${Messages['emptyAmount']}"
      ((amount--)) # Уменьшаем до -1
    fi
    
    # Если снарядов не осталось
    if [ "$amount" -le 0 ]; then
      return
    fi
    
    # Если осталось 5 снарядов
    if [ "$amount" -eq 5 ]; then
      sendDataToCP "${StationMap['name']}" "$(getTime)" "${Messages['getAmount']}$amount"
    fi
    
    # Данные текущей цели
    local currentTargetData
    currentTargetData=$(findByID "${StationMap['jsonFile']}" "$id")
    
    # Получаем флаг о том, стреляли ли мы раньше в эту цель
    checkInArray "$id" "${shootTargetsIDs[@]}"
    local isShootInTarget=$?
    
    # Поверяем выстрел
    if [ "$isShootInTarget" -eq 0 ]; then # Если стреляли ранее
      sendDataToCP "${StationMap['name']}" "$(getTime)" "${Messages['missedTarget']}" "$id" "$type" "$x" "$y"
      
      shootTargetsIDs=($(removeInArray "$id" "${shootTargetsIDs[@]}"))
    fi
    
    # Стреляем в цель
    echo "$id" > "${DestroyDir}/${id}"
    ((amount--))
    writeToFile "${StationMap['shotFile']}" "$currentTargetData"

    sendDataToCP "${StationMap['name']}" "$(getTime)" "${Messages['shotAtTarget']}" "$id" "$type" "$x" "$y"
    
    ((shootsCount++))
  }
  
  # Получаем ассоциативный массив значений станции
  local -n StationMap=$1
  
  # Сохраняем информацию о станции
  writeToFileCheckName "$PIDsFile" "$(processToJSON "${StationMap['name']}")"
  
  # Получаем запись о станции
  local stationData
  stationData=$(findByName "$PIDsFile" "${StationMap['name']}")

  # Получаем поле, активна ли станция
  local active
  active=$(getFieldValue "$stationData" "active")

  # Если активна, то выходим
  if [[ $active == "true" ]]; then
    echo "${StationMap['name']} уже запущена"
    return
  fi
  
  echo "${StationMap['name']} запущена"

  # Активируем отслеживание сообщений
  handlePing "${StationMap['name']}" &
  updateFieldInFileByName "$PIDsFile" "${StationMap['name']}" "workPid" "$!"
  
  local -a shootTargetsIDs=()
  local amount="${StationMap['amount']}"
  
  local shootsCount=0
  
  while true; do
    # Получаем информацию о станции
    local newStationData
    newStationData=$(findByName "$PIDsFile" "${StationMap['name']}")
    
    # Получаем поле, активна ли станция
    local newActive
    newActive=$(getFieldValue "$newStationData" "active")
    
    if [[ $newActive == "false" ]]; then
      sleep 1
      continue
    fi
    
    # Считаем, сколько целей нужно получить
    local targetsCount=$MaxKolTargets
    ((targetsCount-=shootsCount))
    shootsCount=0
    
    # Считываем цели
    declare -a files=()
    files=($(readGeneratedTargets "$targetsCount"))

    # Проверяем существуют ли они
    local filesExists=$?
    if [ $filesExists -eq 1 ]; then
      sleep 1
    fi
    
    # Получаем все ID целей, по которым стреляли в прошлом цикле
    shootTargetsIDs=($(getFieldsFromFile "${StationMap['shotFile']}"))
    true >"${StationMap['shotFile']}" # Очищаем файл

    # Проходимся по каждой цели
    local file
    for file in "${files[@]}"; do
      processTarget "$file"
    done
    
    # Проверяем, какие цели мы уничтожили
    local targetID 
    for targetID in "${shootTargetsIDs[@]}"; do
      # Данные текущей цели
      local targetData
      targetData=$(findByID "${StationMap['jsonFile']}" "$targetID")
      
      # Получаем поля
      local type x y
      type=$(getFieldValue "$targetData" "type")
      x=$(getFieldValue "$targetData" "x")
      y=$(getFieldValue "$targetData" "y")
      
      sendDataToCP "${StationMap['name']}" "$(getTime)" "${Messages['targetDestroyed']}" "$targetID" "$type" "$x" "$y"
    done
    shootTargetsIDs=()
    
    sleep .8
  done
}
