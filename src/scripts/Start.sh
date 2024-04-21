#!/bin/bash


# Создаем БД
bash db/CreateDb.sh


# Запускаем РЛС
#bash src/scripts/starts/rls/Rls1.sh
#sleep 0.4
#bash src/scripts/starts/rls/Rls2.sh
#sleep 0.4
#bash src/scripts/starts/rls/Rls3.sh
#sleep 0.4


sleep 0.5


# Запускаем СПРО
#bash src/scripts/starts/Spro.sh
#sleep 0.9


# Запускаем ЗРДН
bash src/scripts/starts/zrdn/Zrdn1.sh
sleep 0.9
bash src/scripts/starts/zrdn/Zrdn2.sh
sleep 0.9
bash src/scripts/starts/zrdn/Zrdn3.sh
sleep 0.9


# Запускаем КП
bash src/scripts/starts/Cp.sh


sleep 0.5


# Запускаем генерацию целей
bash src/scripts/starts/GenTargets.sh
