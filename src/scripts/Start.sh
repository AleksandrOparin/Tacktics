#!/bin/bash

# Constants
source src/constants/GenTargets.sh
source src/constants/Paths.sh

# Dtos
source src/dtos/Pid.sh

# Helpers
source src/helpers/Json.sh


# Очищаем
true >"$PIDsFile"
true >"$AllLogsFile"


# Создаем БД
bash db/CreateDb.sh


# Запускаем КП
bash src/scripts/starts/Cp.sh


sleep 0.5


# Запускаем РЛС
bash src/scripts/starts/rls/Rls1.sh
sleep 0.5
bash src/scripts/starts/rls/Rls2.sh
sleep 0.5
bash src/scripts/starts/rls/Rls3.sh
sleep 0.5


# Запускаем СПРО
bash src/scripts/starts/Spro.sh
sleep 1.4


# Запускаем ЗРДН
bash src/scripts/starts/zrdn/Zrdn1.sh
sleep 1.4
bash src/scripts/starts/zrdn/Zrdn2.sh
sleep 1.4
bash src/scripts/starts/zrdn/Zrdn3.sh


sleep 0.5


# Запускаем генерацию целей
./GenTargets.sh &
writeToFileCheckName "$PIDsFile" "$(pidToJSON "${GenTargets['name']}" "$!")"
