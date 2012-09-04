#!/bin/bash 

function scanport {
	for PORT in $(seq $2 65000); do
		echo -ne "\035" | telnet 127.0.0.1 $PORT > /dev/null 2>&1
		if [ $? -eq 1 ]; then
			eval "$1=$PORT"
			return 0
		fi
	done
	return 1
}
