#!/bin/bash
cp testrun.sh /usr/local/bin/trun
cp testformat.sh /usr/local/bin/tformat
cp suffix.sh /usr/local/bin/suffix

wget http://google-styleguide.googlecode.com/svn/trunk/cpplint/cpplint.py -O /usr/local/bin/cpplint
chmod +x /usr/local/bin/cpplint
