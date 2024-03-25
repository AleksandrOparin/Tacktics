#!/bin/bash

echoGreen() {
  local message=$1
  echo -e "\e[32m$message\e[0m"
}

echoRed() {
  local message=$1
  echo -e "\e[31m$message\e[0m"
}
