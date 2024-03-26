#!/bin/bash

# Helpers
source src/helpers/Json.sh
source src/helpers/Math.sh
source src/helpers/Other.sh
source src/helpers/Target.sh

# Dtos
source src/dtos/Target.sh

runRLS() {
  # Получаем ассоциативный массив значений РЛС
  declare -A RLS

  local rlsKeys=("${!1}")
  local rlsValues=("${!2}")

  for ((i=0; i<${#rlsKeys[@]}; i++)); do
      RLS[${rlsKeys[$i]}]=${rlsValues[$i]}
  done
  
  # Получаем ассоциативный массив значений СПРО
  declare -A SPRO
  
  local sproKeys=("${!3}")
  local sproValues=("${!4}")
  
  for ((i=0; i<${#sproKeys[@]}; i++)); do
    SPRO[${sproKeys[$i]}]=${sproValues[$i]}
  done

  # Основное содержимое запуска
  echo "${RLS['name']} started"
  
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
      dx=$(echo "scale=$scale;$x - ${RLS['x']}" | bc)
      dy=$(echo "scale=$scale;$y - ${RLS['y']}" | bc)
      
      # Если цель в зоне РЛС    
      if (inSector "$dx" "$dy" "${RLS['distance']}" "${RLS['angle']}" "${RLS['deviation']}"); then
        # Ищем цель в файле с обнаруженными целями
        local findedTargetData
        findedTargetData=$(findByID "${RLS['jsonFile']}" "$id")
        
        # Если записи о цели не было, то добавляем ее 
        local findedTargetExists=$?
        if [ "$findedTargetExists" -eq 1 ]; then
          local data
          data=$(targetToJSON "$id" "$x" "$y")
          
          writeToFile "${RLS['jsonFile']}" "$data"
          
          continue # Переходим к следующему файлу
        fi
        
        # Если запись о цели была, то проверяем ее скорость
        local speed prevX prevY discovered
        speed=$(getFieldValue "$findedTargetData" "speed")
        prevX=$(getFieldValue "$findedTargetData" "x")
        prevY=$(getFieldValue "$findedTargetData" "y")
        discovered=$(getFieldValue "$findedTargetData" "discovered")
        
        if [ -z "$speed" ]; then # Если скорости не было, то устанавливаем ее
          echo "У цели с ID - ${id} были координаты X - ${prevX} Y - ${prevY}"
          echo "У цели с ID - ${id} стали координаты X - ${x} Y - ${y}"
        
          local targetDx targetDy
          targetDx=$(echo "scale=$scale;$x - $prevX" | bc)
          targetDy=$(echo "scale=$scale;$y - $prevY" | bc)

          local newSpeed
          newSpeed=$(sqrt "$targetDx" "$targetDy")
        
          echo "Цели с ID - ${id} выставляем скорость ${newSpeed}"
        
          local updatedData
          updatedData=$(setFieldValue "$findedTargetData" "speed" "$newSpeed") # Обновляем поле speed
          updateInFile "${RLS['jsonFile']}" "$updatedData"
        fi
        
        speed=$newSpeed
        
        # Проверяем тип цели
        local type
        type=$(getTargetType "$speed")
        if (checkIn "$type" "${RLS['targets']}"); then
          local findedTargetData1
          findedTargetData1=$(findByID "${RLS['jsonFile']}" "$id")
          
          # Если цель не была обнаружена (не передавали о ней информацию), то передаем
          if [[ "$discovered" == "false" ]]; then
            echo "Обнаружена цель c ID - ${id} и координатами X - ${x} Y - ${y}"
            if (isWillCross "$prevX" "$prevY" "$x" "$y" "${SPRO['x']}" "${SPRO['y']}" "${SPRO['distance']}"); then
              echo "Цель c ID - ${id} движется в направлении СПРО"
            fi
            
            local updatedData1
            updatedData1=$(setFieldValue "$findedTargetData1" "discovered" true) # Обновляем поле discovered
            updateInFile "${RLS['jsonFile']}" "$updatedData1"
          fi
        fi
      fi
    done
    
    sleep 0.4
  done
}
