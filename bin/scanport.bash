#!/bin/bash 

# Scanport: Find an open UNIX port.
# Arg 1: The environment variable to store the port.
# Arg 2: The port with which to begin scanning.

scanport() {
	for PORT in $(seq $2 65000); do
		if [[ ! $(netstat -an | grep "\([0-9]\{1,3\}\.\)\{4\}${PORT}") ]]; then
			eval "$1=$PORT"
			return 0
		fi
	done
	return 1
}
