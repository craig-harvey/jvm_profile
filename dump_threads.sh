#!/bin/bash

# Script to continuously dump thread execution information for a specific process
#


# Check if a PID and a specified duration to capture the stats is provided
if [ $# -ne 2 ]; then
    echo "Usage: $0 <PID> <DURATION>"
    exit 1
fi

PID=$1
DURATION=$2
OUTPUT_FILE=stats_capture/thread.stats

## Create Header for output file
echo "timestamp,thread_id,exec_time" > $OUTPUT_FILE

# Awk script to prepend current time to each line of the output of ps
AWK_SCRIPT="awk -v timestamp=\$(date +%s) '{print timestamp, \",\"\$1, \",\"\$2} ' >> $OUTPUT_FILE"

for i in  $( seq 1 $2 )
do
  ps -Lo tid,time $PID | tail -n +2 | eval $AWK_SCRIPT
  sleep 1
done

