#!/bin/bash

# Переменные
export MaxKolTargets=30

# Скорости целей
export SpeedPl=(50 249)       # 50 - 249      Самолет
export SpeedCm=(250 1000)     # 250 - 1000    Крылатая ракета
export SpeedBm=(8000 10000)   # 8000 - 10000  Бал.блок

# Все станции
declare -a AllStationNames=("РЛС1" "РЛС2" "РЛС3" "СПРО" "ЗРДН1" "ЗРДН2" "ЗРДН3")
export AllStationNames
