#!/bin/bash

# Constants
source src/constants/Variables.sh


# Создаем БД
bash db/CreateDb.sh


# Запускаем РЛС
bash src/scripts/starts/rls/Rls1.sh
sleep "${Sleep04:?}"
bash src/scripts/starts/rls/Rls2.sh
sleep "${Sleep04:?}"
bash src/scripts/starts/rls/Rls3.sh
sleep "${Sleep04:?}"


sleep "${Sleep05:?}"


# Запускаем СПРО
bash src/scripts/starts/Spro.sh
sleep "${Sleep09:?}"


# Запускаем ЗРДН
bash src/scripts/starts/zrdn/Zrdn1.sh
sleep "${Sleep09:?}"
bash src/scripts/starts/zrdn/Zrdn2.sh
sleep "${Sleep09:?}"
bash src/scripts/starts/zrdn/Zrdn3.sh
sleep "${Sleep09:?}"


sleep "${Sleep05:?}"


# Запускаем КП
bash src/scripts/starts/Cp.sh


sleep "${Sleep04:?}"


# Запускаем генерацию целей
bash src/scripts/starts/GenTargets.sh
