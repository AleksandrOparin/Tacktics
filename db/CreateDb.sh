#!/bin/bash

source src/constants/Paths.sh


rm -rf "$DBFile"


sqlite3 "$DBFile" <<EOF
CREATE TABLE IF NOT EXISTS messages (
    stationName TEXT,
    detectedTime TEXT,
    message TEXT,
    targetId TEXT,
    targetType TEXT,
    targetX TEXT,
    targetY TEXT
);
EOF


isCreated=$?
if [ $isCreated -eq 0 ]; then
    echo "База данных успешно создана"
else
    echo "Проблемы при создании базы данных"
fi
