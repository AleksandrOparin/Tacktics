#!/bin/bash

source src/constants/Paths.sh

#echo -e "id \t is \t a \t tab"
sqlite3 "$DBFile" ".mode tabs" "SELECT * FROM messages;"
