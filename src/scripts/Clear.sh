#!/bin/bash

# Constants
source src/constants/Paths.sh


rm "${LogsDir:?}"/*.log 2>/dev/null  # Удаляем временные log файлы


rm "${CPMessagesDir:?}"/* 2>/dev/null # Удаляем сообщения для КП


rm "${TempDir:?}"/*.json 2>/dev/null # Удаляем временные json файлы
rm "${TempDir:?}"/*.txt 2>/dev/null  # Удаляем временные txt файлы


rm "${GenTargetsDir:?}"/*.log 2>/dev/null # Удаляем log файл
rm -rf "${TargetsDir:?}"/* 2>/dev/null # Удаляем сгенерированные цели
rm -rf "${DestroyDir:?}"/* 2>/dev/null # Удаляем уничтоженные цели
