#!/bin/bash

### dump_vmstat.sh ###

# Script to continuously monitor vmstat dumping output every second to a file in CSV format
#
# Input - Takes a variable for the number of seconds to record for

# Check if a specified duration to capture the stats is provided
if [ $# -ne 1 ]; then
    echo "Usage: $0 <DURATION>"
    exit 1
fi

DURATION=$1
OUTPUT_FILE=/tmp/jvmstats_capture/vmstat.stats
OUTPUT_DIR=`dirname $OUTPUT_FILE`

if [ ! -d $OUTPUT_DIR ]; then
  mkdir -p $OUTPUT_DIR
fi

## Create vmstat Header for output file, using awk to replace whitespace with commas
echo timestamp`vmstat | awk 'NR==2 {gsub(/[[:space:]]+/, ",") ; print}'` > $OUTPUT_FILE

AWK_SCRIPT="awk '!/(procs|cache)/ { gsub(/[[:space:]]+/, \",\") ; cmd = \"date +%s\"; if (cmd | getline var) printf \"%s%s\\n\", var, \$0 ; close (cmd) }' >> $OUTPUT_FILE"

vmstat 1 $DURATION | eval $AWK_SCRIPT

