#!/bin/bash

source src/constants/Paths.sh

insertInDB() {
  local name=$1
  local message=$2
  
  sqlite3 "$DBFile" "INSERT INTO messages VALUES ('$name', '$message');"
}
