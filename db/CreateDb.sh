#!/bin/bash

source src/constants/Paths.sh

rm -rf "$DBFile"

sqlite3 "$DBFile" <<EOF
CREATE TABLE IF NOT EXISTS messages (
    system TEXT,
    message TEXT
);
EOF

#sqlite3 "$DBFile" <<EOF
#CREATE TABLE IF NOT EXISTS messages (
#    timestamp TEXT,
#    system TEXT,
#    message TEXT,
#    target_type TEXT,
#);
#EOF

isCreated=$?
if [ $isCreated -eq 0 ]; then
    echo "База данных успешно создана"
else
    echo "Проблемы при создании базы данных"
fi
