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
sleep 1.5





# Запускаем ЗРДН
#bash src/scripts/Zrdn/Zrdn1.sh
#bash src/scripts/Zrdn/Zrdn2.sh
#bash src/scripts/Zrdn/Zrdn3.sh


sleep 0.5


# Запускаем генерацию целей
./GenTargets.sh &
writeToFileCheckName "$PIDsFile" "$(pidToJSON "${GenTargets['name']}" "$!")"
