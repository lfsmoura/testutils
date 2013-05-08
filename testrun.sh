#!/bin/bash

n=1
verbose=""
label_with_n=""
inputs=""
OPTIND=1
while getopts "n:m:lhv" opt
do
  case $opt in
  n)
    n=$OPTARG
    ;;
  m)
    inputs=$OPTARG
  ;;
  l)
    label_with_n="true"
  ;;
  v)
    verbose="true"
  ;;
  :)  
    echo "Option -$OPTARG requires an argument." >&2
    exit
  ;;
  h|[?]|help)
    echo "./testeutil [OPTIONS] 'cmd'"
    echo "-h help"
    echo "-m inputs - instead of using number as inputs, use \$inputs"
    echo "-l     - adds a "label" # to the results with the indices of the calls"
    echo "-n     - same as -m \'seq 1 n\', executes n times"
    echo "ex: ./testutil -lpn 10 echo test:"
    echo "ex: ./testutil -lpm '\`seq 10 10 100\`' echo test:"
    exit
  ;;
  esac
done

if [ $OPTIND > 1 ]; then shift $((OPTIND-1)); fi

if [ -z "$inputs" ]; then  inputs=`seq 1 $n`; fi

for i in $inputs
do
  cmd="$@ $i"
  if [ "$verbose" ]; then echo $cmd; fi

  if [ "$label_with_n" ]; 
  then 
    $cmd | awk -v n=$i ' /:/ { print $0":"n }' 
  else
    $cmd
  fi

  echo ""
done

