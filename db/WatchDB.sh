#!/bin/bash

source src/constants/Paths.sh

sqlite3 "$DBFile" "SELECT * FROM messages;"
