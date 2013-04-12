testutils
=========

Don't repeat yourself

Utils
-----

	. testutil.sh -n 10 "./a.out"

> executes the command line "./a.out" ten times, the output of the program must be of the format

	field:value

> for example if your program outputs

	runningtime:10s
	runningtime:20s
	runningtime:12s

> testutil output is going to be

	runningtime
	10
	20
	12