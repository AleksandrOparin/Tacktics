#!/bin/bash

source "src/colors/Colors.sh"
source "src/helpers/Math.sh"

assert() {
  local expect=$1
  local get=$2
  
  if [ "$expect" == "$get" ]; then
    echoGreen "Тест прошел. Ожидали - ${expect}, получили - ${get}"
  else
    echoRed "Тест не прошел. Ожидали - ${expect}, получили - ${get}"
  fi
}

assertFloat() {
  local expect=$1
  
  local get diff
  get=$(awk -v num="$2" 'BEGIN { printf "%.1f", num }')
  diff=$(bc -l <<< "$expect - $get")

  if [[ $(bc -l <<< "$diff <= 0.1") -eq 1 ]]; then
    echoGreen "Тест прошел. Ожидали - ${expect}, получили - ${get}"
  else
    echoRed "Тест не прошел. Ожидали - ${expect}, получили - ${get}"
  fi
}

arctanTests() {
  echo "arctanTests"
  local arctanCases=(
    # x y expect
    "1 0 0"
    "0 1 90"
    "-1 0 180"
    "0 -1 270"
    "1 1 45"
    "-1 1 135"
    "-1 -1 225"
    "1 -1 315"
    "3 1 18.4"
    "-1 5 101.3"
    "-2 -4 243.4"
    "4 -3 323.1"
  )

  local case
  for case in "${arctanCases[@]}"; do
    local x y expect
    x=$(echo "$case" | cut -d ' ' -f1)
    y=$(echo "$case" | cut -d ' ' -f2)
    expect=$(echo "$case" | cut -d ' ' -f3)
    
    assertFloat "$expect" "$(arctan "$x" "$y")"
  done
  echo ""
}

inCircleTests() {
  echo "inCircleTests"
  local inCircleCases=(
    # dx dy radius expect
    "1 1 2 0"
    "2 2 3 0"
    "3 4 5 0"
    "4 3 5 0"
    "0.5 0.5 1 0"
    "1 1 1 1"
    "3 4 4 1"
    "2 1 2 1"
    "7 8 10 1"
    "0.5 0.8 0.9 1"
  )
    
  local case
  for case in "${inCircleCases[@]}"; do
    local expect
    expect=$(echo "$case" | cut -d ' ' -f4)
    
    inCircle $case
    assert "$expect" "$?"
  done
  echo ""
}

inSectorTests() {
  echo "inSectorTests"
  local inSectorCases=(
    # dx dy radius angle deviation expect
    "4 3 5 30 20 0"
    "-2 2 3 135 20 0"
    "6 -6 8.5 315 10 0"
    "-4 5 6.5 150 60 0"
    "0 -7 7 270 0.05 0"
    "5 5 3 45 10 1"
    "-3 1 5 130 20 1"
    "7 -2 9 0 20 1"
    "-5 -5 4 225 30 1"
    "0 8 7 90 0.05 1"
  )
    
  local case
  for case in "${inSectorCases[@]}"; do
    local expect
    expect=$(echo "$case" | cut -d ' ' -f6)
    
    inSector $case
    assert "$expect" "$?"
  done
  echo ""
}

isWillCrossTests() {
  echo "isWillCrossTests"
  local isWillCrossCases=(
    # x1 y1 x2 y2 xCenter yCenter radius expect
    "0 0 10 10 5 5 3 0"
    "-5 -5 5 5 0 0 7 0"
    "1 1 4 4 3 3 0.5 0"
    "0 10 10 0 5 5 3 0"
    "-6 -6 -3 -3 5 2 2 1"
    "2 2 1 1 2 5 2 1"
    "1 1 2 2 10 5 1 1"
    "0 0 1 1 5 0 0.5 1"
    "-2 3 -1 4 0 0 0.5 1"
    "6 4 7 5 3 3 2 1"
#    "1 1 10 10 3 3 2 1"
  )
  
  local case
  for case in "${isWillCrossCases[@]}"; do
    local expect    
    expect=$(echo "$case" | cut -d ' ' -f8)
    
    isWillCross $case
    assert "$expect" "$?"
  done
  echo ""
}


# Запуск всех тестов
arctanTests
inCircleTests
inSectorTests
isWillCrossTests
