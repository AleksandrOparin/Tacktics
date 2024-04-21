#!/bin/bash

# Constants
source src/constants/Paths.sh


# Logs
rm "${LogsDir:?}"/*.log 2>/dev/null  # Удаляем временные log файлы


# Messages
rm "${CPRequestDir:?}"/* 2>/dev/null  #
rm "${CPResponseDir:?}"/* 2>/dev/null #
rm "${CPTargetsDir:?}"/* 2>/dev/null  #


# Temp
rm "${StationInfoDir:?}"/* 2>/dev/null
rm "${StationTargetsDir:?}"/* 2>/dev/null


# Tmp
rm "${GenTargetsDir:?}"/GenTargets.log 2>/dev/null # Удаляем log файл
rm -rf "${TargetsDir:?}"/* 2>/dev/null # Удаляем сгенерированные цели
rm -rf "${DestroyDir:?}"/* 2>/dev/null # Удаляем уничтоженные цели
