#!/bin/bash

# Kills all the process trees of the args,
# children first then parents.
# Works on OS X unlike other pkill, ps, pstree solutions.
# Should also work on POSIX.
# The first arg is the pid of the tree to kill. The second arg is the kill signal
# (term is default).
# If process doesn't exist, terminates with status 0.

killtree() {
	local _pid=$1
	[[ ! $(ps -o "pid=" | grep -x $_pid) ]] && return 0
	local _sig=${2-TERM}

	# Snag the child and killtree it
	local _regex="[ ]*([0-9]+)[ ]+${_pid}"
	for _child in $(ps ax -o "pid= ppid=" | grep -E "${_regex}" | sed -E "s/${_regex}/\1/g"); do
		killtree ${_child} ${_sig}
	done

	kill -${_sig} ${_pid}
}

if [ $# -eq 0 -o $# -gt 2 ]; then
	echo "Usage: $(basename $0) <pid> [signal]"
	exit 1
fi

killtree $@
