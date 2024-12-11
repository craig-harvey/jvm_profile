#!/bin/bash

#
# Uses `top` to dump % cpu utilisation for all jboss apps
# 
# Due to `top` typically displaying each app on a separate line, some crazy awk was used
# to consolidate the rows of CPU data from top into a single line.
#
# Output format:
#
#    Timestamp,app1,app2,app3
#    t1,0.2,3.5,3.2
#    t2,0.1,3.9,5.2
#

DURATION=$1

if [ -z $DURATION ]
  then
    DURATION=1
fi

# Create the header by getting all the java apps by name and sorting them by PID
ps -ef | grep java | sort -nk2 | grep -o '\[[^]]*\]' | grep -v pcid | awk '{printf ",%s", $0}' | awk '{printf "timestamp%s\n", $0}' > stats_capture/appcpu.stats

# Determine the number of Java apps we will be working with
NUM_APPS=`top -b -n 1 -p $(pgrep -d, java) | grep jboss | wc -l`

# In RHEL, the top command will print the stats since last invocation, which could be a while,
# So we use top -n 2 and delete the first set of rows returned (Which is equal to the number of java apps)
SED_CMD="1,${NUM_APPS}d"

#
# Loop for every second until it reaches the desired execution time
#
for i in $(seq 1 $1 )
do
  DATE=`date +%s | tr -d \"\n\"`
  top -b -n 2 -p $(pgrep -d, java) |  grep jboss | sed $SED_CMD | sort -nk1 | eval "awk 'NR % $NUM_APPS == 1 {printf \"%s\", $DATE} {printf \",%s\", \$9} NR % $NUM_APPS == 0 {printf \"\\n\"}'" >> stats_capture/appcpu.stats
done

