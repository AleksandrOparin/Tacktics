#!/bin/bash

declare -A CP=(
  ['name']="КП"
  
  ['stationFile']="temp/StationInfo/CP.json"
)
  
declare -A CPResponseTypes=(
  ['ping']="ping"
  ['update']="update"
  ['delete']="delete"
)

export CP CPResponseTypes
