#!/bin/bash

# TODO: удалить
source src/constants/Cp.sh
source src/constants/GenTargets.sh
source src/constants/Rls.sh
source src/constants/Spro.sh
source src/constants/Zrdn.sh

# Helpers
source src/helpers/Process.sh


#stopStations


# TODO: удалить
stopStation CP
#stopStation RLS1
#stopStation RLS2
#stopStation RLS3
#stopStation SPRO
stopStation ZRDN1
stopStation ZRDN2
stopStation ZRDN3
stopStation GenTargets
