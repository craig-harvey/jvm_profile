#!/bin/bash

# Script to continuously dump stats for a particular Java process
#
# Check out the following subscripts for details on what is captured:
#     - dump_top.sh
#     - dump_threads.sh
#     - dump_jstack.sh
#     - dump_vmstat.sh
#     - dump_app_cpu.sh
#     - dump_app_mem.sh

DUMP_DIR=/tmp/jvmstats_capture
mkdir -p $DUMP_DIR

# Check if a PID and a specified duration to capture the stats is provided
if [ $# -ne 2 ]; then
    echo "Usage: $0 <PID> <DURATION>"
    exit 1
fi

# Check PID is an actual running process


# Capture the sysctl values
sysctl -a > $DUMP_DIR/sysctl.out 2>&1

# Invoke the sub scripts to run in the background
sh dump_top.sh $2 &
sh dump_threads.sh $1 $2 &
sh dump_vmstat.sh $2 &
sh dump_app_cpu.sh $2 &
sh dump_app_mem.sh $2 &
sh dump_jstack.sh $1 $2 &
sh dump_heap.sh $1 $2 &

# Wait for the duration so all sub scripts can complete
# TODO - Progress bar
echo Capturing statistics for $2 seconds
sleep $2
echo Completed, compressing stats directory

# Compress the output directory
HOSTNAME=`hostname -s`
DATE=`date +"%Y-%m-%d_%H-%M-%S"`
cd /tmp/; tar -czf stats_$HOSTNAME_$DATE.tgz jvmstats_capture/

echo Created /tmp/stats_$HOSTNAME_$DATE.tgz

