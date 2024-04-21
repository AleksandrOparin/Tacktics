#!/bin/bash

# DB
export DBFile="db/messages.db"


# Logs
export LogsDir="logs"
export AllLogsFile="${LogsDir}/All.log"


# Messages
export MessagesDir="messages"
export CPRequestDir="${MessagesDir}/RequestFromCP"
export CPResponseDir="${MessagesDir}/ResponseToCP"
export CPTargetsDir="${MessagesDir}/TargetsToCP"

export CPRequestFile="${CPRequestDir}/Ping.txt"


# Temp
export TempDir="temp"


# Tmp
export TmpDir="tmp"


# Targets
export GenTargetsDir="${TmpDir}/GenTargets"
export TargetsDir="${GenTargetsDir}/Targets"
export DestroyDir="${GenTargetsDir}/Destroy"


# Stations
export StationInfoDir="${TempDir}/StationInfo"
export StationTargetsDir="${TempDir}/StationTargets"

export StationsFile="${TempDir}/Stations.json"

