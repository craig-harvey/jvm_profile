#!/bin/bash

# Check if a PID and a specified duration to capture the stats is provided
if [ $# -ne 2 ]; then
    echo "Usage: $0 <PID> <DURATION>"
    exit 1
fi

PID=$1
DURATION=$2
OUTPUT_DIR=/tmp/jvmstats_capture/jstack_files/

mkdir -p $OUTPUT_DIR

for i in  $( seq 1 $2 )
do
  TIME=`date +%s`
  jstack $PID > $OUTPUT_DIR/jstack.out.$TIME
  sleep 1
done

