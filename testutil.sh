#!/bin/bash

n=1

while getopts "n:m:lph" opt
do
  case $opt in
  n)
      n=$OPTARG
    ;;
  p)
      use_n_as_parameter="true"
  ;;
  m)
    fun=$OPTARG
  ;;
  l)
    label_with_n="true"
    echo "label"
  ;;
  :)  
    echo "Option -$OPTARG requires an argument." >&2
    exit 1
  ;;
  h|[?]|help)
    echo "./testeutil [OPTIONS] 'cmd'"
    echo "-h help"
    echo "-m cmd - takes indices from paramter ex. -m 'seq 5 10'"
    echo "-l     - adds a "label" # to the results with the indices of the calls"
    echo "-p     - uses the indices as the last paramater of cmd"
    echo "-n     - same as -m "seq 1 n", executes n times"
    echo "ex: ./testutil -lpn 10 echo test:"
    echo "ex: ./testutil -lpm 'seq 10 10 100' echo test:"
    exit 1
  ;;
  esac
done


shift $((OPTIND-1))
cmd1=$@

if [ -z "$fun" ]; then  fun="seq 1 $n"; fi

touch $$temp
for i in $($fun)
do
  cmd=$cmd1
  if [ "$label_with_n" ]; then echo "#:$i" >> $$temp; fi
  if [ "$use_n_as_parameter" ]; then cmd=$cmd" "$i; fi
  $cmd >> $$temp
done

cat $$temp |
awk -F ":" '
  BEGIN{ fields=0; maxcount=0}
  NF>1 {
    if(count[$1] == 0) {
      maxsize[$1] = length($1);
      count[$1] = 0;
      fieldNames[fields]=$1
      fields += 1;
    }
    gsub(/[ \t]/, "", $2);
    values[$1, count[$1]] = $2;
    count[$1] += 1;
    if(count[$1] > maxcount)
      maxcount = count[$1];
    if(length($2) > maxsize[$1])
      maxsize[$i] = length($2)
  }
  END{
    for(i = 0; i < fields-1; i++)
      printf("%*s \t", -maxsize[fieldNames[i]], fieldNames[i]); 
    printf("%*s \n", -maxsize[fieldNames[fields-1]], fieldNames[fields-1]);

    
    for(i = 0; i < maxcount; i++) {
      for(j = 0; j < fields; j++)
        printf("%*s\t", -maxsize[fieldNames[j]], values[fieldNames[j], i]);
      print ""
    }
  }
'
rm $$temp
