#!/bin/bash

# DB
export DBFile="db/messages.db"


# Logs
export LogsDir="logs"
export AllLogsFile="${LogsDir}/All.log"


# Messages
export MessagesDir="messages"
export CPMessagesDir="${MessagesDir}/ToCP"


# Temp
export TempDir="temp"


# Tmp
export TmpDir="tmp"


# Targets
export GenTargetsDir="${TmpDir}/GenTargets"
export TargetsDir="${GenTargetsDir}/Targets"
export DestroyDir="${GenTargetsDir}/Destroy"


# PIDs
export PIDsFile="${TempDir}/PIDs.json"
