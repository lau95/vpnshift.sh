#!/bin/bash

echo "$@" | ncat 127.0.0.1 4444
ret=$?
if [ $ret == 1 ]; then 
	$@ &
	exit 1
else
	exit 0
fi
