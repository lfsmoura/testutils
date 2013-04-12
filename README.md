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
	iter:5
	runningtime:20s
	iter:10
	runningtime:12s
	iter:6

> testutil output is going to be

	runningtime	iter
	10		5
	20		10
	12		6