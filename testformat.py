#!/usr/bin/env python

from collections import defaultdict
import fileinput
import math
import numpy
import sys
from sets import Set
import argparse

parser = argparse.ArgumentParser(description="format test results.")
parser.add_argument('-a', '--all', action='store_true', help='print all fields')
parser.add_argument('-v', '--version', action='version', version='%(prog)s 1.0.0')
parser.add_argument('--sum', nargs='*', help='named fields are summed')
parser.add_argument('--mean', nargs='*', help='mean of named fields is shown')
parser.add_argument('--meanstddev', nargs='*', help='mean +- std deviation of named fields is shown')
parser.add_argument('--latex', action='store_true', help='prints in latex format')
parser.add_argument('--max', action='store_true', help='outline the maximum value')
parser.add_argument('--min', action='store_true', help='outline the minimum value')
args = parser.parse_args()

fields = Set()
labels = defaultdict(dict)
unlabeled = defaultdict(list)
maxlen = 0

def  inargs(field, args):
  return args and field in args

def add_unlabeled_value(field, value):
  global maxlen, unlabeled, fields, args
  if not args.all and not inargs(field, args.sum) and not inargs(field, args.mean) and \
      not inargs(field, args.meanstddev):
    return
  fields.add(field)
  unlabeled[field].append(value)
  maxlen = max(maxlen, len(unlabeled[field]))

def add_value(filename, field, value):
  global labels, fields, args
  if not args.all and not inargs(field, args.sum) and not inargs(field, args.mean) and \
      not inargs(field, args.meanstddev):
    return
  fields.add(field)
  if not field in labels[filename]:
    labels[filename][field] = []

  labels[filename][field].append(value)

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
      return "{0:.2f}".format(numpy.mean(map(float, values), axis=0)) + \
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
NA = "-"
BO = "<"
BE = ">"

if args.latex:
  HS = "\\ \n \\hline \n"
  FS = "\t & "
  LS = "\\\\ \n"
  ML = "$\pm$"
  BO = "{\\bf "
  BE = "}"

# print headers
print "#",
for field in fields:
  print FS, field,

print HS,

# print data
for id in (range(maxlen) + labels.keys()):
  print id,
  label = labels.get(id)
  line = {}

  bestFound = False
  best = -1
  for field in fields:
    if label:
      #print FS, 
      line[field] = get_value(label, field)
      try:
        if args.max and (not bestFound or float(line[field]) > best):
          best, bestFound = float(line[field]), True
        elif args.min and (not bestFound or float(line[field]) < best):
          best, bestFound = float(line[field]), True
      except:
        pass
    else:
      if field in unlabeled and len(unlabeled[field]) > id:
        line[field] = unlabeled[field][id]
      else:
        line[field] = NA
 
  for field in fields:
    try:
      if bestFound and float(line[field]):
        print FS, "%s%s%s" % (BO, line[field], BE), 
      else:
        print FS, line[field],
    except:
      print FS, line[field],
  print LS,

