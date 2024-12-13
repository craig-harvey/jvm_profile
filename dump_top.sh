#!/bin/bash

# Script to continuously monitor TOP dumping output to a file in CSV format
#
# Input - Takes a variable for the number of seconds to record for, otherwise runs top once and exits.

# Output
#
#   top.stats: Capture system level stats from the first 5 lines from `top`, prepending a unix timestamp to each line.
#
#   stats captured:
#       - Load average (for the last minute)
#       - CPU: user, system, idle, wait, hw_interrupts, sw_interrupts, physical_cpu_wait (Note: We omit ni)
#       - MEM: total, free, used, buffered
#       - SWAP: total, free, used, available
#

DURATION=$1

if [ -z $DURATION ]
  then
    DURATION=1
fi

## TOP - Create Header for output file
echo "Timestamp,load_average,cpu_user,cpu_system,cpu_idle,cpu_wait,cpu_hw_interrupts,cpu_sw_interrupts,cpu_physical_cpu_wait,mem_total,mem_free,mem_used,mem_buffered,swap_total,swap_free,swap_used,swap_avail" > /tmp/jvmstats_capture/top.stats

## Print the required fields from top  (See Comment above)
## NB: The below awk column numbers may change depending on distro
PRINT_LOAD='NR==1{printf "%s,%s", timestamp, $12}'
PRINT_CPU='NR==3{printf "%s,%s,%s,%s,%s,%s,%s,",$2,$4,$8,$10,$12,$14,$16}'
PRINT_MEM='NR==4{printf "%s,%s,%s,%s,",$4,$6,$8,$10}'
PRINT_SWP='NR==5{print $3","$5","$7","$9}'

for i in  $( seq 1 $1 )
do
  DATE=`date +%s | tr -d \"\n\"`
  top -b -n 1 | eval "awk -v timestamp=$DATE ' $PRINT_LOAD $PRINT_CPU $PRINT_MEM $PRINT_SWP' >> /tmp/jvmstats_capture/top.stats"
  sleep 1
done


