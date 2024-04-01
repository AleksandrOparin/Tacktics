#!/bin/bash

# Constants
source src/constants/Paths.sh

# Очищаем файл с Pid
true >"$PidsFile"


# Запускаем КП
bash src/scripts/Cp/Cp.sh


# Запускаем РЛС
bash src/scripts/Rls/Rls1.sh
bash src/scripts/Rls/Rls2.sh
bash src/scripts/Rls/Rls3.sh


# Запускаем СПРО
bash src/scripts/Spro/Spro.sh


# Запускаем ЗРДН
bash src/scripts/Zrdn/Zrdn1.sh
bash src/scripts/Zrdn/Zrdn2.sh
bash src/scripts/Zrdn/Zrdn3.sh


# Запускаем генерацию целей
./GenTargets.sh &
echo $! >> "$PidsFile"
