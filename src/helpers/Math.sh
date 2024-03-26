#!/bin/bash

export scale=5
export PI=$(echo "scale=10; 4*a(1)" | bc -l)

# Функция вычисляет арктангенс, возвращает значение угла в градусах
arctan() {
  local x=$1
  local y=$2

  # Вычисляем арктангенс с помощью atan2 и преобразуем его в градусы
  local angle
  angle=$(echo "scale=$scale; atan2($y, $x) * 180 / $PI" | bc -l)

  # Нормализуем угол в диапазоне от 0 до 360 градусов
  if (( $(echo "$angle < 0" | bc -l) )); then
    angle=$(echo "$angle + 360" | bc -l)
  fi

  echo "$angle"
}

# Функция возвращает сумму квадратов двух чисел
square() {
  local x=$1
  local y=$2

  echo "scale=$scale;($x^2 + $y^2)" | bc -l
}

# Функция возвращает квадратный корень от суммы квадратов двух чисел
sqrt() {
  local x=$1
  local y=$2

  echo "scale=$scale;sqrt($x^2 + $y^2)" | bc -l
}

# Функция проверяет, лежит ли заданное число в заданном диапазоне
inRange() {
  local value=$1        # Значение
  local leftBorder=$2   # Левая граница
  local rightBorder=$3  # Правая граница

  local greaterThanOrEqual lessThanOrEqual
  greaterThanOrEqual=$(echo "$value >= $leftBorder" | bc -l)
  lessThanOrEqual=$(echo "$value <= $rightBorder" | bc -l)

  if [ "$greaterThanOrEqual" -eq 1 ] && [ "$lessThanOrEqual" -eq 1 ]; then
    return 0
  fi

  return 1
}

# Функция проверяет принадлежность точки окружности
inCircle() {
  local dx=$1     # Дельта по x
  local dy=$2     # Дельта по y
  local radius=$3 # Радиус окружности

  local distanceSquared radiusSquared
  distanceSquared=$(square "$dx" "$dy")
  radiusSquared=$(echo "$radius * $radius" | bc -l)

  if (( $(echo "$distanceSquared <= $radiusSquared" | bc -l) )); then
    return 0
  else
    return 1
  fi
}

inSector() {
  local dx=$1         # Дельта по x
  local dy=$2         # Дельта по y
  local radius=$3     # Радиус окружности
  local angle=$4      # Угол от оси абсцисс (правой границы)
  local deviation=$5  # Отклонение угла от angle (половина в одну сторону, половину в другую)
  
  local leftAngle rightAngle pointAngle
  pointAngle=$(arctan "$dx" "$dy") # Угол между прямой от центра окружности до точки и осью X
  leftAngle=$(echo "scale=$scale;$angle - $deviation / 2" | bc -l)
  rightAngle=$(echo "scale=$scale;$angle + $deviation / 2" | bc -l)
  
  # Проверяем, что угол лежит между углами сектора
  if (inRange "$pointAngle" "$leftAngle" "$rightAngle"); then
    # Проверяем, что точка находится внутри окружности
    if (inCircle "$dx" "$dy" "$radius"); then
      return 0
    fi
  fi
  
  return 1
}

isWillCross() {
  local x1=$1
  local y1=$2
  local x2=$3
  local y2=$4
  local xCenter=$5
  local yCenter=$6
  local radius=$7
  
  # Расчет направления движения и проверка, удаляется ли объект от центра
  local dx dy dxCenter dyCenter dotProduct
  dx=$(bc -l <<< "scale=$scale; $x2 - $x1")
  dy=$(bc -l <<< "scale=$scale; $y2 - $y1")
  dxCenter=$(bc -l <<< "scale=$scale; $xCenter - $x1")
  dyCenter=$(bc -l <<< "scale=$scale; $yCenter - $y1")
  dotProduct=$(bc -l <<< "scale=$scale; $dx * $dxCenter + $dy * $dyCenter")

  # Если dotProduct < 0, объект движется от центра
  if (( $(bc -l <<< "$dotProduct < 0") )); then
    return 1
  fi
  
  # Расчет коэффициентов прямой
  local k b
  k=$(bc -l <<< "scale=$scale; ($dy) / ($dx)")
  b=$(bc -l <<< "scale=$scale; $y1 - $k * $x1")
  
  # Расчет расстояния от центра окружности до прямой
  local distance
  distance=$(bc -l <<< "scale=$scale; ($k * $xCenter - $yCenter + $b) / sqrt($k * $k + 1)")
  distance=${distance#-} # Взять модуль значения
  
  # Проверка, меньше ли расстояние, чем радиус
  if (( $(bc -l <<< "$distance <= $radius") )); then
    return 0
  else
    return 1
  fi
}