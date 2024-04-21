#!/bin/bash

# Constants
source src/constants/Paths.sh

# Messages
mkdir "${CPRequestDir:?}"
mkdir "${CPResponseDir:?}"
mkdir "${CPTargetsDir:?}"


# Tmp
mkdir "${StationInfoDir:?}"
mkdir "${StationTargetsDir:?}"
