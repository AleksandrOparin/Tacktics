#!/bin/bash

source src/constants/Paths.sh

sqlite3 "$DBFile" ".mode tabs" "SELECT * FROM messages;"
