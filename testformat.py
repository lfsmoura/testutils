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
parser.add_argument('-v', '--version', action='version', version='%(prog)s 1.1.0')
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
      s = sum(map(float, values))
      if s % 1 == 0:
        return "%d" % int(s)
      else:
        return "{0:.2f}".format(s)
    elif args.mean and field in args.mean:
      return "{0:.2f}".format(numpy.mean(map(float, values), axis=0))
    elif args.meanstddev and field in args.meanstddev:
      return '%.2f' % numpy.mean(map(float, values), axis=0) + ML + \
          '%.2f' % numpy.std(map(float, values), axis=0)
    else:
      return "{0:.2f}".format(numpy.mean(map(float, values), axis=0)) + \
          '(%d)' % len(values)
  else:
    raise Exception("value not found")

for line in fileinput.input('-'):
  # strips new line
  line = line.split('\n')[0]
  fline = line.rsplit(':')
  if len(fline) == 2:
    add_unlabeled_value(fline[0], fline[1])
  elif len(fline) == 3:
    add_value(fline[2].strip(), fline[0].strip(), fline[1].strip())

B_TABLE = None
E_TABLE = None
HS = "\n"
FS = "\t"
LS = "\n"
ML = "+-"
NA = "-"
BO = "<"
BE = ">"

if args.latex:
  B_TABLE = "\\n begin{tabular} { %s }" % \
      ("l " + str.join(" ", ["r" for x in range(len(fields))]))
  E_TABLE = "\\end{tabular}"
  HS = "\t \\\\ \n \\hline \n"
  FS = "\t & "
  LS = "\t \\\\ \n"
  ML = "$\pm$"
  BO = "{\\bf "
  BE = "}"

'''
output is in one of the following forms
1)  field:value:label
2)  field:value

form 1 is labeled, and form 2 is shown by order of output
'''

# print headers
if B_TABLE:
  print B_TABLE

print "#",
for field in fields:
  print FS, field.strip(),

print HS,

# print data
for id in (range(maxlen) + labels.keys()):
  print id,
  label = labels.get(id)
  line = {}

  best = None
  for field in fields:
    if label: #ouput in the first form
      try:
        line[field] = get_value(label, field)
        if args.max and (not best or float(line[field]) > best):
          best = float(line[field])
        elif args.min and (not best or float(line[field]) < best):
          best = float(line[field])
      except:
        line[field] = NA
    else: #output in the second form
      if field in unlabeled and len(unlabeled[field]) > id:
        line[field] = unlabeled[field][id]
      else:
        line[field] = NA

  # actually print values
  for field in fields:
    try:
      if best and float(line[field]) == best:
        print FS, "%s%s%s" % (BO, line[field].strip(), BE), 
      else:
        print FS, line[field].strip(),
    except:
      print FS, line[field].strip(),
  print LS,

if E_TABLE:
  print E_TABLE

