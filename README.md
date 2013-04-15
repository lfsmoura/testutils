testutils
=========

Don't repeat yourself

Utils
-----

	. testutil.sh -n 10 "./a.out"

executes the command line "./a.out" ten times, the output of the program must be of the format

	field:value

for example if your program outputs

	runningtime:10s
	iter:5
	runningtime:20s
	iter:10
	runningtime:12s
	iter:6

testutil output is going to be

	runningtime     iter
	10s             5
	20s             10
	2s              6

options:

	-h help

	-m cmd - takes indices from paramter ex. -m "seq 5 10"
	-l     - adds a "label" # to the results with the indices of the calls
	-p     - uses the indices as the last paramater of cmd
	-n     - same as -m "seq 1 n", executes n times
 