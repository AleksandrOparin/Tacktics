#!/bin/bash

# Helpers
source src/helpers/Json.sh
source src/helpers/Math.sh
source src/helpers/Other.sh
source src/helpers/Target.sh

# Dtos
source src/dtos/Target.sh

runRLS() {
  # Получаем ассоциативные массивы значений РЛС и СПРО
  local -n RLSMap=$1
  local -n SPROMap=$2
  
  # Основное содержимое запуска
  echo "${RLSMap['name']} started"
  
  while true; do
    # Считываем цели
    declare -a files=()
    files=($(readGeneratedTargets))

    # Проверяем существуют ли они
    local filesExists=$?
    if [ ! $filesExists ]; then 
      echo "Targets not exists"
      sleep 1
    fi

    # Проходимся по каждой цели
    local file
    for file in "${files[@]}"; do
      local targetInfo id x y
      targetInfo=($(getTargetInfo "$file"))
      id="${targetInfo[0]}"
      x="${targetInfo[1]}"
      y="${targetInfo[2]}"

      local dx dy
      dx=$(echo "scale=$scale;$x - ${RLSMap['x']}" | bc)
      dy=$(echo "scale=$scale;$y - ${RLSMap['y']}" | bc)

      # Если цель в зоне РЛС    
      if (inSector "$dx" "$dy" "${RLSMap['distance']}" "${RLSMap['angle']}" "${RLSMap['deviation']}"); then
        # Ищем цель в файле с обнаруженными целями
        local findedTargetData
        findedTargetData=$(findByID "${RLSMap['jsonFile']}" "$id")

        # Если записи о цели не было, то добавляем ее 
        local findedTargetExists=$?
        if [ "$findedTargetExists" -eq 1 ]; then
          local data
          data=$(targetToJSON "$id" "$x" "$y")

          writeToFile "${RLSMap['jsonFile']}" "$data"

          continue # Переходим к следующему файлу
        fi

        # Если запись о цели была, то проверяем ее скорость
        local speed prevX prevY discovered
        speed=$(getFieldValue "$findedTargetData" "speed")
        prevX=$(getFieldValue "$findedTargetData" "x")
        prevY=$(getFieldValue "$findedTargetData" "y")
        discovered=$(getFieldValue "$findedTargetData" "discovered")

        if [ -z "$speed" ]; then # Если скорости не было, то устанавливаем ее
#          echo "У цели с ID - ${id} были координаты X - ${prevX} Y - ${prevY}" # TODO: Удалить
#          echo "У цели с ID - ${id} стали координаты X - ${x} Y - ${y}" # TODO: Удалить

          local targetDx targetDy
          targetDx=$(echo "scale=$scale;$x - $prevX" | bc)
          targetDy=$(echo "scale=$scale;$y - $prevY" | bc)

          local newSpeed
          newSpeed=$(sqrt "$targetDx" "$targetDy")

#          echo "Цели с ID - ${id} выставляем скорость ${newSpeed}" # TODO: Удалить

          local updatedData
          updatedData=$(setFieldValue "$findedTargetData" "speed" "$newSpeed") # Обновляем поле speed
          updateInFile "${RLSMap['jsonFile']}" "$updatedData"
        fi

        speed=$newSpeed

        # Проверяем тип цели
        local type
        type=$(getTargetType "$speed")
        if (checkIn "$type" "${RLSMap['targets']}"); then
          local findedTargetData1
          findedTargetData1=$(findByID "${RLSMap['jsonFile']}" "$id")

          # Если цель не была обнаружена (не передавали о ней информацию), то передаем
          if [[ "$discovered" == "false" ]]; then
            echo "Обнаружена цель c ID - ${id} и координатами X - ${x} Y - ${y}"
            if (isWillCross "$prevX" "$prevY" "$x" "$y" "${SPROMap['x']}" "${SPROMap['y']}" "${SPROMap['distance']}"); then
              echo "Цель c ID - ${id} движется в направлении СПРО"
            fi

            local updatedData1
            updatedData1=$(setFieldValue "$findedTargetData1" "discovered" true) # Обновляем поле discovered
            updateInFile "${RLSMap['jsonFile']}" "$updatedData1"
          fi
        fi
      fi
    done

    sleep 0.5
  done
}
