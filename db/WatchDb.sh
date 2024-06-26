#!/bin/bash

# Constants
source src/constants/Paths.sh

# Helpers
source src/helpers/Format.sh


# Подключаемся к базе данных SQLite и выполняем запрос
while IFS='' read -r line; do
  # Разбиваем строку на массив, используя "|" в качестве разделителя
  IFS='|' read -r -a fields <<< "$line"
  
  # Форматируем каждую строку
  formattedRow=$(format "${fields[@]}")
  
  # Выводим каждую строку
  echo "$formattedRow"
done < <(sqlite3 "${DBFile:?}" "SELECT * FROM messages;")
