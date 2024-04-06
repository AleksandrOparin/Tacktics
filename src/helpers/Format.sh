#!/bin/bash

# Определяем ширину полей во внешней переменной
fieldWidths=(10 25 40 15 10 10 10)

# Функция для форматирования строки
format() {
  local fields=("$@")
  
  local formattedRow=""
  local index=0
  
  # Перебираем аргументы функции, представленные в виде массива
  local field
  for field in "${fields[@]}"; do
    # Проверяем, что поле не пустое
    if [ -n "$field" ]; then
      # Обрезаем поле, если его длина превышает заданную ширину
      if (( ${#field} > ${fieldWidths[$index]} )); then
          field="${field:0:${fieldWidths[$index]}}"
      fi
      
      # Дополняем поле пробелами до нужной длины
      while [ "${#field}" -lt "${fieldWidths[$index]}" ]; do
          field+=" "
      done
      
      # Добавляем поле к итоговой строке
      formattedRow+="$field"
    fi
    
    ((index++))
  done
  
  # Возвращаем итоговую строку
  echo "$formattedRow"
}
