#!/bin/bash

# Script to continuously dump stats for a particular Java process
#
# Check out the following subscripts for details on what is captured:
#     - dump_top.sh
#     - dump_threads.sh
#     - dump_jstack.sh
#     - dump_vmstat.sh

DUMP_DIR=stats_capture/

# Check if a PID and a specified duration to capture the stats is provided
if [ $# -ne 2 ]; then
    echo "Usage: $0 <PID> <DURATION>"
    exit 1
fi

# Do a heap dump of the process every 30s (it is taxing on the system)
COUNT=$(($2 / 30 - 1))
for i in  $( seq 1 $COUNT )
do
  DATE=`date +"%Y-%m-%d_%H:%M:%S"`
  jmap -dump:live,format=b,file=/tmp/jvmstats_capture/heap_$DATE.hprof $1 2>&1
  sleep 30
done

# Do a final heap dump of the java process
rm -f stats_capture/heap_end.hprof
jmap -dump:live,format=b,file=/tmp/jvmstats_capture/heap_end.hprof $1 2>&1

