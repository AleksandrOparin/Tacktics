#!/bin/bash

source src/constants/Variables.sh

# Функция для чтения информации о целях
readGeneratedTargets() {
  local targetsCount=${1:-$MaxKolTargets}
  
  # Объявляем массив файлов
  declare -a files=()

  # Считываем последние файлы и информацию из них
  files=($(ls -tr "$TargetsDir" | tail -n "$targetsCount"))

  # Проверяем, нашлись ли файлы
  if [ ${#files[@]} -eq 0 ]; then
    return 1
  else
    echo "${files[@]}"
    return 0
  fi
}

# Функция возвращает информацию о цели (id x y)
getTargetInfo() {
  local targetFilename=$1
  local targetFilePath="$TargetsDir/$targetFilename"
  
  local id x y
  id="${targetFilename: -6}"
  x=$(grep -o 'X[0-9]*' "$targetFilePath" | sed 's/X//')
  y=$(grep -o 'Y[0-9]*' "$targetFilePath" | sed 's/Y//')
  
  echo "$id"
  echo "$x"
  echo "$y"
}

# Функция возвращает тип цели по ее скорости
getTargetType() {
  local speed=$1

  if inRange "$speed" "${SpeedPl[0]}" "${SpeedPl[1]}"; then
    echo "К.ракета"
  elif inRange "$speed" "${SpeedCm[0]}" "${SpeedCm[1]}"; then
    echo "Самолет"
  elif inRange "$speed" "${SpeedBm[0]}" "${SpeedBm[1]}"; then
    echo "Бал.блок"
  else
    echo "Неизвестный тип"
  fi
}
