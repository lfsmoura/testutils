testutils
=========

Don't repeat yourself

install
-------
	sudo install.sh

testrun.sh
----------

	./testutil.sh -n 10 ./a.out

executes the command line "./a.out" ten times with i \in [1,n] given as a parameter

options:
	
	-n $n			executes n times, feeding i as a parameter
	-m "p1 p2 ..."	executes program for each parameter 
	-l			labels the output of the program with i

example usages:

	./testrun.sh -m "1 2 3" a.out

testformat.sh
-------------
the output of the program must be of the format

	field:value

or optionally

	field:value:label

for example, if your file contains

	runningtime:10s
	iter:5
	runningtime:20s
	iter:10
	runningtime:12s
	iter:6

testformat output is going to be

	cat file | ./testformat.sh 
	# 	runningtime     iter
	1 	10s             5
	2 	20s             10
	3 	2s              6

options:

	-x	latex format
