#!/bin/bash

generateRandomSequence() {
    local length=${1:-10}  # Параметр длины, по умолчанию 10
    
    local sequence
     sequence=$(mcookie | tr -dc 'a-zA-Z0-9' | head -c$length)
    
    echo "$sequence"
}
