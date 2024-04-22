#!/bin/bash

generateRandomSequence() {
    local length=${1:-10}  # Параметр длины, по умолчанию 10
    
    local sequence
    sequence=$(openssl rand -base64 48 | tr -dc 'a-zA-Z0-9' | head -c"$length")
    
    echo "$sequence"
}
