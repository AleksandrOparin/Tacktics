#!/bin/bash

source src/constants/Paths.sh

# Удаляем прошлую БД
rm -rf "${DBFile:?}"


# Создаем новую БД
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


# Выводим сообщение о создании БД
isCreated=$?
if [ $isCreated -eq 0 ]; then
    echo "База данных успешно создана"
else
    echo "Проблемы при создании базы данных"
fi
