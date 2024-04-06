#!/bin/bash

declare -A Messages=(
  ['stationActive']="Станция запущена"
  ['targetDetected']="Цель обнаружена"
  ['targetMovesToSpro']="Цель движется в направлении СПРО"
  
  ['getAmount']="Осталось снарядов - "
  ['emptyAmount']="Закончились снаряды"
  ['missedTarget']="Промах по цели"
  ['shotAtTarget']="Выстрел в цель"
  ['targetDestroyed']="Цель уничтожена"
  
  ['unknown']="Неизвесто"
  ['unauthorizedAccess']="Не совпадают контрольные суммы, попытка НСД!"
)
  
export Messages
