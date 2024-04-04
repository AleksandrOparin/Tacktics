#!/bin/bash

# Constants
source src/constants/Paths.sh

# Helpers
source src/helpers/Json.sh


stopProcesses() {
  local pids=()
  pids=($(getFieldsFromFile "$PIDsFile" "pid"))
  
  for pid in "${pids[@]}"; do
    kill "$pid"
  done
}

stopProcesses
