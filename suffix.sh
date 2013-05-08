#!/bin/bash

suffix=$1
shift

if [ "$1" ] 
then
	while [ "$1" ]
	do
		echo $1 | 
		sed "s/\( \|$\)/"$suffix" /g"
		shift
	done
else
	sed "s/\( \|$\)/"$suffix" /g"
fi
