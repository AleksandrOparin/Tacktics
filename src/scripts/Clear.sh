#!/bin/bash

rm logs/*.log 2>/dev/null  # Удаляем временные log файлы

rm temp/*.json 2>/dev/null # Удаляем временные json файлы
rm temp/*.txt 2>/dev/null  # Удаляем временные txt файлы

rm -rf tmp/GenTargets/Destroy/* 2>/dev/null # Удаляем
rm -rf tmp/GenTargets/Targets/* 2>/dev/null # Удаляем сгенерированные цели
rm tmp/GenTargets/*.log 2>/dev/null # Удаляем log файл