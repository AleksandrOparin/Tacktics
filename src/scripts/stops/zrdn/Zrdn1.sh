#!/bin/bash

# Constants
source src/constants/Zrdn.sh

# Helpers
source src/helpers/Process.sh


stopProcessByName "${ZRDN1['name']}"
