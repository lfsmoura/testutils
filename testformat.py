#!/usr/bin/env python

from collections import defaultdict
import fileinput
import math
import numpy
import sys
from sets import Set
import argparse

parser = argparse.ArgumentParser(description="format test results.")
parser.add_argument('-v', '--version', action='version', version='%(prog)s 1.0.0')
parser.add_argument('--sum', nargs='*', help='named fields are summed')
parser.add_argument('--mean', nargs='*', help='mean of named fields is shown')
parser.add_argument('--meanstddev', nargs='*', help='mean +- std deviation of named fields is shown')
parser.add_argument('--latex', action='store_true', help='prints in latex format')
args = parser.parse_args()

fields = Set()
files = defaultdict(dict)
unlabeled = defaultdict(list)
maxlen = 0

def add_unlabeled_value(field, value):
  global maxlen, unlabeled, fields
  fields.add(field)
  unlabeled[field].append(value)
  maxlen = max(maxlen, len(unlabeled[field]))

def add_value(filename, field, value):
  global files, fields
  fields.add(field)
  if not field in files[filename]:
    files[filename][field] = []

  files[filename][field].append(value)

def get_value(file, field):
  global ML
  values = file.get(field)
  if values:
    if len(values) == 1:
      return values[0]
    elif args.sum and field in args.sum:
      return "{0:.2f}".format(sum(map(float, values)))
    elif args.mean and field in args.mean:
      return "{0:.2f}".format(numpy.mean(map(float, values), axis=0))
    elif args.meanstddev and field in args.meanstddev:
      return '%.2f' % numpy.mean(map(float, values), axis=0) + ML + \
          '%.2f' % numpy.std(map(float, values), axis=0)
    else:
      return '%.2f' % numpy.mean(map(float, values), axis=0) + ML + \
          '%.2f' % numpy.std(map(float, values), axis=0) + \
          '(%d)' % len(values)
  else:
    return '-'

for line in fileinput.input('-'):
  # strips new line
  line = line.split('\n')[0]
  fline = line.rsplit(':')
  if len(fline) == 2:
    add_unlabeled_value(fline[0], fline[1])
  elif len(fline) == 3:
    add_value(fline[2], fline[0], fline[1])

HS = "\n"
FS = "\t"
LS = "\n"
ML = "+-"

if args.latex:
  HS = "\\ \n \\hline \n"
  FS = "\t & "
  LS = "\\\\ \n"
  ML = "$\pm$"

print "#",
for field in fields:
  print FS, field,

print HS,

for id in (range(maxlen) + files.keys()):
  print id,
  file = files.get(id)
  for field in fields:
    if file:
      print FS, get_value(file, field),
    else:
      if field in unlabeled and len(unlabeled[field]) > id:
        print FS, unlabeled[field][id],
      else:
        print FS, "-",
  print LS,

