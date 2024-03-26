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

declare -A destroyedTargets

runSPRO() {
  # Получаем ассоциативный массив значений СПРО
  declare -A SPRO
  
  local sproKeys=("${!1}")
  local sproValues=("${!2}")
  
  for ((i=0; i<${#sproKeys[@]}; i++)); do
    SPRO[${sproKeys[$i]}]=${sproValues[$i]}
  done

  # Основное содержимое запуска
  echo "${SPRO['name']} started"
  
  while true; do
    # Считываем цели
    declare -a files=()
    files=($(readGeneratedTargets))
    
    # Проверяем существуют ли они
    local filesExists=$?
    if [ ! $filesExists ]; then 
      echo "Targets not exists"
      sleep 2
    fi
    
    #
    destroyedTargets=()
    
    # Проходимся по каждой цели
    local file
    for file in "${files[@]}"; do
      local targetInfo id x y
      targetInfo=($(getTargetInfo "$file"))
      id="${targetInfo[0]}"
      x="${targetInfo[1]}"
      y="${targetInfo[2]}"
      
      local dx dy
      dx=$(echo "scale=$scale;$x - ${SPRO['x']}" | bc)
      dy=$(echo "scale=$scale;$y - ${SPRO['y']}" | bc)
      
      # Если цель в зоне СПРО    
      if (inCircle "$dx" "$dy" "${SPRO['distance']}"); then
        # Ищем цель в файле с обнаруженными целями
        local findedTargetData
        findedTargetData=$(findByID "${SPRO['jsonFile']}" "$id")
        
        # Если записи о цели не было, то добавляем ее 
        local findedTargetExists=$?
        if [ "$findedTargetExists" -eq 1 ]; then
          local data
          data=$(targetToJSON "$id" "$x" "$y")
          
          writeToFile "${SPRO['jsonFile']}" "$data"
          
          continue # Переходим к следующему файлу
        fi
        
        # Если запись о цели была, то проверяем ее скорость
        local speed=0 prevX prevY discovered
        speed=$(getFieldValue "$findedTargetData" "speed")
        prevX=$(getFieldValue "$findedTargetData" "x")
        prevY=$(getFieldValue "$findedTargetData" "y")
        discovered=$(getFieldValue "$findedTargetData" "discovered")
        
        if [ -z "$speed" ]; then # Если скорости не было, то устанавливаем ее
          local targetDx targetDy
          targetDx=$(echo "scale=$scale;$x - $prevX" | bc)
          targetDy=$(echo "scale=$scale;$y - $prevY" | bc)

          speed=$(sqrt "$targetDx" "$targetDy")
        
          local updatedData
          updatedData=$(setFieldValue "$findedTargetData" "speed" "$speed") # Обновляем поле speed
          updateInFile "${SPRO['jsonFile']}" "$updatedData"
        fi
        
        # Проверяем тип цели
        local type
        type=$(getTargetType "$speed")
        if (checkIn "$type" "${SPRO['targets']}"); then
          local findedTargetData1 findedTargetData2
          findedTargetData1=$(findByID "${SPRO['jsonFile']}" "$id")
          findedTargetData2=$(findByID "${SPRO['shotFile']}" "$id")
          local isShot=$?
          
          # Проверка на снаряды
          if [[ ${SPRO['amount']} -le 0 ]]; then
            echo "Снаряды кончились, стрельба невозможна"
          fi
          
          # Проверяем выстрел
          if [ "$isShot" -eq 1 ]; then # Если выстерла не было
            # Стреляем
            # Уменьшаем число снарядов на 1
            # Записываем в массив destroyedTargets, что выстрелили (записываем findedTargetData1)
            # Удаляем из файла с выстрелами цель
            
            echo "$id" > "tmp/GenTargets/Destroy/$id"
            echo "Выстрел в цель с ID - ${id}"
          
            ((SPRO['amount']--))  # Уменьшаем число снарядов на 1
            destroyedTargets["$id"]=$findedTargetData1  # Записываем в массив destroyedTargets, что выстрелили
            removeFromFile "${SPRO['shotFile']}" "$id"  # Удаляем из файла с выстрелами цель
          else # Если был выстрел, но мы здесь -> мы промахнулись
            # Уменьшаем число снарядов на 1
            # Записываем в массив, что выстрелили
            
            echo "Промах по цели с ID - ${id}"
            echo "$id" > "tmp/GenTargets/Destroy/$id"
            echo "Выстрел в цель с ID - ${id}"
          
            ((SPRO['amount']--))  # Уменьшаем число снарядов на 1
          fi
        fi
      fi
    done
    
    # Смотрим какие id остались в файле - их мы сбили
    # Переносим данные из destroyedTargets в файл
    local ids
    ids=($(getIDsFromFile "${SPRO['shotFile']}"))
    for id in "${ids[@]}"; do
      echo "Цель с ID - ${id} уничтожена"
    done
    
    rm "${SPRO['shotFile']}" 2>/dev/null
    
    for targetID in "${!destroyedTargets[@]}"; do
#      echo "${destroyedTargets[$targetID]}"
      writeToFile "${SPRO['shotFile']}" "${destroyedTargets[$targetID]}"
    done
    
    sleep 0.7
  done
}

runSPRO SPROKeys[@] SPRO1[@]
