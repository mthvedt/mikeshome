#!/bin/bash

# Kills all the process trees of the args,
# children first then parents.
# Works on OS X unlike other pkill, ps, pstree solutions.
# Should also work on POSIX.
# The first arg is the pid of the tree to kill. The second arg is the kill signal
# (term is default).
# If process doesn't exist, terminates with status 0.
# Doesn't work on processes owned by root, and may spin forever if
# process doesn't respond to TERM.

killtree() {
	local _pid=$1
	echo "Preparing to kill: $_pid"
	[[ ! $(ps -o "pid=" | sed 's/^[ \t]*//;s/[ \t]*$//' | grep -x $_pid) ]] && return 0
	local _sig=${2-TERM}
	#echo "Preparing to kill children: " `ps -f -p ${_pid} | tail -n +2`

	# Snag the child and killtree it
	local _regex="[ ]*([0-9]+)[ ]+${_pid}"
	for _child in $(ps ax -o "pid= ppid=" | grep -E "${_regex}" | sed -E "s/${_regex}/\1/g"); do
		killtree ${_child} ${_sig}
	done

	echo "Killing: $_pid"
	kill -${_sig} ${_pid} > /dev/null 2>&1 || true
	# Wait for exit
	while kill -0 ${_pid} > /dev/null 2>&1 ; do sleep 0.1; done
	echo "Killed: $_pid"
}

set -e

if [ $# -eq 0 ]; then
	echo "Usage: $(basename $0) <pid> [signal]"
	exit 1
elif [ $# -gt 2 ]; then
   for foo in $@; do
	   killtree $foo
   done
else
	killtree $@
fi
