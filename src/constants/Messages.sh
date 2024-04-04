#!/bin/bash

declare -A Messages=(
  ['stationActive']="Станция запущена"
  ['targetDetected']="Цель обнаружена"
  ['targetMovesToSpro']="Цель движется в направлении СПРО"
  ['unknown']="Неизвесто"
  ['unauthorizedAccess']="Не совпадают контрольные суммы, попытка НСД!"
)
  
export Messages
