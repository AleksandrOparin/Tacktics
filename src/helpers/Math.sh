#!/bin/bash

export scale=5

# Функция вычисляет арктангенс, возвращает значение угла в градусах
arctan() {
  local x=$1
  local y=$2

  # Вычисляем арктангенс с помощью atan2 и преобразуем его в градусы
  local angle
  angle=$(awk -v x="$x" -v y="$y" -v scale="$scale" 'BEGIN { PI=atan2(0, -1); printf "%.*f\n", scale, atan2(y, x) * 180 / PI }')


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
  dx=$(echo "scale=$scale; $x2 - $x1" | bc -l)
  dy=$(echo "scale=$scale; $y2 - $y1" | bc -l)
  dxCenter=$(echo "scale=$scale; $xCenter - $x1" | bc -l)
  dyCenter=$(echo "scale=$scale; $yCenter - $y1" | bc -l)
  dotProduct=$(echo "scale=$scale; $dx * $dxCenter + $dy * $dyCenter" | bc -l)

  # Если dotProduct < 0, объект движется от центра
  if (( $(echo "$dotProduct < 0" | bc -l) )); then
    return 1
  fi
  
  # Расчет коэффициентов прямой
  local k b
  k=$(echo "scale=$scale; ($dy) / ($dx)" | bc -l)
  b=$(echo "scale=$scale; $y1 - $k * $x1" | bc -l)
  
  # Расчет расстояния от центра окружности до прямой
  local distance
  distance=$(echo "scale=$scale; ($k * $xCenter - $yCenter + $b) / sqrt($k * $k + 1)" | bc -l)
  distance=${distance#-} # Взять модуль значения
  
  # Проверка, меньше ли расстояние, чем радиус
  if (( $(echo "$distance <= $radius" | bc -l) )); then
    return 0
  else
    return 1
  fi
}
