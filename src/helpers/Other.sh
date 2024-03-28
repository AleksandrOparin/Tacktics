#!/bin/bash

#
checkIn() {
  local value=$1
  local stringArray=$2
  
  local wordsArray
  read -ra wordsArray <<< "$stringArray"
  
  local word
  for word in "${wordsArray[@]}"; do
    if [[ "$value" == "$word" ]]; then
      return 0
    fi
  done
  
  return 1
}

#
checkInArray() {
  local elementToFind=$1
  
  local element
  for element in "${@:2}"; do
      [[ "$element" == "$elementToFind" ]] && return 0
  done
  
  return 1
}

#
removeInArray() {
    local elementToRemove="$1"
    shift
    
    local newArray=()
    
    local element
    for element in "$@"; do
        [[ "$element" != "$elementToRemove" ]] && newArray+=("$element")
    done
    
    echo "${newArray[@]}"
}
