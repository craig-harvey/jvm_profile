#!/usr/bin/bash

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

# Capture the sysctl values
sysctl -a > $DUMP_DIR/sysctl.out 2>&1

# Do an initial heap dump of the java process
rm -f stats_capture/heap_start.hprof
jmap -dump:live,format=b,file=stats_capture/heap_start.hprof $1

# Invoke the sub scripts to run in the background
sh dump_top.sh $2 &
sh dump_threads.sh $1 $2 &
sh dump_jstack.sh $1 $2 &
sh dump_vmstat.sh $2 &

# Do a heap dump of the process every 30s (it is taxing on the system)
COUNT=$(($2 / 30 - 1))
for i in  $( seq 1 $COUNT )
do
  sleep 30
  rm -f stats_capture/heap_$i.hprof
  jmap -dump:live,format=b,file=stats_capture/heap_$i.hprof $1
done

# Do a final heap dump of the java process
rm -f stats_capture/heap_end.hprof
jmap -dump:live,format=b,file=stats_capture/heap_end.hprof $1


