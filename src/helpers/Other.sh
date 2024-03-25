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
