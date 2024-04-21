#!/bin/bash

# Constants
source src/constants/Messages.sh
source src/constants/Paths.sh
source src/constants/Variables.sh

# Helpers
source src/helpers/Array.sh
source src/helpers/Cp.sh
source src/helpers/Json.sh
source src/helpers/Math.sh
source src/helpers/Ping.sh
source src/helpers/Target.sh
source src/helpers/Time.sh

# Dtos
source src/dtos/Station.sh
source src/dtos/Target.sh


runStation() {
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
    if (inSector "$dx" "$dy" "${StationMap['distance']}" "${StationMap['angle']}" "${StationMap['deviation']}"); then
        handleRLSTarget "$id" "$x" "$y"
    fi
  }
  
  # Функция для обработки взаимодействия станции и цели
  handleRLSTarget() {
    local id=$1
    local x=$2
    local y=$3

    # Ищем цель в файле с обнаруженными целями
    findByID "${StationMap['jsonFile']}" "$id" true

    # Если записи о цели не было, то это первое обнаружение этой цели
    local findedTargetExists=$?
    if [ "$findedTargetExists" -eq 1 ]; then
        handleNewTarget "$id" "$x" "$y"
        return 1
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
    
    # Проверяем, что тип из тех, которые обнаруживает станция
    if (checkIn "$type" "${StationMap['targets']}"); then
        handleDetectedTarget "$id" "$x" "$y" "$type"
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
    local prevX prevY detected
    prevX=$(getFieldValue "$targetData" "x")
    prevY=$(getFieldValue "$targetData" "y")
    detected=$(getFieldValue "$targetData" "detected")

    # Если цель не была обнаружена (не передавали о ней информацию), то передаем
    if [[ "$detected" == "false" ]]; then        
      sendTargetToCP "${StationMap['name']}" "$(getTime)" "${Messages['targetDetected']}" "$id" "$type" "$x" "$y"
        
      # Если цель летит в сторону СПРО, то также сообщаем об этом
      if (isWillCross "$prevX" "$prevY" "$x" "$y" "${SPROMap['x']}" "${SPROMap['y']}" "${SPROMap['distance']}"); then
          sendTargetToCP "${StationMap['name']}" "$(getTime)" "${Messages['targetMovesToSpro']}" "$id" "$type" "$x" "$y"
      fi

      # Обновляем поле цели и время обнаружения
      updateFieldInFileByID "${StationMap['jsonFile']}" "$id" "detected" true
      updateFieldInFileByID "${StationMap['jsonFile']}" "$id" "detectedTime" "$(getTime)"
    fi
  }
  
  # Получаем ассоциативные массивы значений станции и СПРО
  local -n StationMap=$1
  local -n SPROMap=$2
  
  # Активируем отслеживание сообщений и запоминаем PID
  handlePing "${StationMap['name']}" &
  local stationPingPid="$!"

  # Сохраняем информацию о том, что станция запущена
  writeToFileCheckName "${StationMap['stationFile']}" "$(stationToJSON "${StationMap['name']}" "$stationPingPid")"
  
  # Цикл для непрерывного чтения файлов
  while true; do    
    # Проверяем, запущена ли станция
    findByName "${StationsFile:?}" "${StationMap['name']}" true
    local isStationStarted=$?
    if [[ $isStationStarted -eq 1 ]]; then
      sleep "${Sleep05:?}"
      continue
    fi
    
    # Считываем цели
    declare -a files=()
    files=($(readGeneratedTargets))

    # Проверяем существуют ли они
    local filesExists=$?
    if [ $filesExists -eq 1 ]; then
      sleep "${Sleep05:?}"
      continue
    fi

    # Проходимся по каждой цели
    local file
    for file in "${files[@]}"; do
      processTarget "$file"
    done
    
    sleep "${Sleep03:?}"
  done
}

runStationWithRegistration() {
  # Получаем ассоциативные массивы значений станции и СПРО
  local -n StationMapNew=$1
  local -n SPROMapNew=$2
  
  # Проверяем, запущена ли станция
  if [[ -e "${StationMapNew['stationFile']}" ]]; then
    echo "${StationMapNew['name']} уже запущена"
    return
  else
    echo "${StationMapNew['name']} запущена"
  fi
  
  # Запускаем станцию
  runStation StationMapNew SPROMapNew 2>/dev/null &
  
  # Получаем результат запуска
  local stationPid=$!
  
  sleep "${Sleep01:?}"
  
  # Регестрируем станцию (сохраняем информацию о ней)
  updateFieldInFileByName "${StationMapNew['stationFile']}" "${StationMapNew['name']}" "pid" "$stationPid"
  sendUpdateToCP "${StationMapNew['stationFile']}" "${StationMapNew['name']}"
}
