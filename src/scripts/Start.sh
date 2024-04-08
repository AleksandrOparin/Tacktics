#!/bin/bash

# Constants
source src/constants/GenTargets.sh
source src/constants/Paths.sh

# Dtos
source src/dtos/Process.sh

# Helpers
source src/helpers/Json.sh


# Создаем БД
bash db/CreateDb.sh


# Запускаем РЛС
bash src/scripts/starts/rls/Rls1.sh
sleep 0.2
bash src/scripts/starts/rls/Rls2.sh
sleep 0.2
bash src/scripts/starts/rls/Rls3.sh
sleep 0.2


sleep 0.5


# Запускаем СПРО
bash src/scripts/starts/Spro.sh
sleep 1


# Запускаем КП
bash src/scripts/starts/Cp.sh


#
## Запускаем ЗРДН
#bash src/scripts/starts/zrdn/Zrdn1.sh
#sleep 1.4
#bash src/scripts/starts/zrdn/Zrdn2.sh
#sleep 1.4
#bash src/scripts/starts/zrdn/Zrdn3.sh


sleep 0.5


# Запускаем генерацию целей
./GenTargets.sh &
writeToFileCheckName "$PIDsFile" "$(processToJSON "${GenTargets['name']}" "" "$!" "true")"
