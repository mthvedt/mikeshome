#!/bin/bash

# Starts a task in the background, waits for the task to output
# a start signal,
# then starts a task in the foreground.
# When the foreground task exits the background task is sigtermed.

# Args are:
# 1. a process name for bookkeeping
# 2. the foreground command
# 3. the background command
# 4. the start signal--when outputted by the background command,
# the foreground command is started

set +o verbose

MINPARAMS=4
if [ $# -lt "$MINPARAMS" ]
then
	echo
	echo "This script needs at least $MINPARAMS arguments"
	exit 1
fi 

SCRIPTNAME=$1
FG_COMMAND=$2
BG_COMMAND=$3
BG_START=$4
DONE_MARK="$SCRIPTNAME is done"

#Startup
OUTFILE=`mktemp -t $SCRIPTNAME` || exit 1
trap "rm -f $OUTFILE" EXIT

# Executes bg command, followed by echoing done mark, to our sentinel file
echo "$BG_COMMAND"
{
$BG_COMMAND 2>&1 | tee $OUTFILE;
echo $DONE_MARK >> $OUTFILE;
} &
BG_TASK=$!
trap "killtree.bash $BG_TASK" EXIT

# wait to start
BG_RESULT="unknown"
while true; do
	if [[ $BG_RESULT != "unknown" ]]; then
		break
	fi
	sleep 1
	# look for the lines that tell us what happened
	while read line; do
		if [[ $line =~ $BG_START ]]; then
			BG_RESULT="success"
			break
		elif [[ $line =~ $DONE_MARK ]]; then
			echo "Task failed; aborting"
			for job in `jobs -p`; do kill $job; done
			wait
			exit 1
		fi
	done < <(cat $OUTFILE)
done

# punch line
echo "$FG_COMMAND"
$FG_COMMAND
trap "echo done" EXIT
exit 0
