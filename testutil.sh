#!/bin/bash

n=1

while [ "$1" ]
do
  case $1 in
    "-h"|"--help")
      echo "./testeutil [OPTIONS] 'cmd'"
      echo " -n repeat cmd n times "
      echo "ex: ./testeutil -n 10 'echo test:1'"
      exit
    ;;
  "-n")
      shift
      n=$1
    ;;
    *) 
      cmd1=$1
    ;;
  esac
  shift
done
touch $$temp
for i in $(seq 1 $n)
do
  $cmd1 >> $$temp
done

cat $$temp |
awk -F ":" '
  BEGIN{ fields=0; maxcount=0}
  NF>1 {
    if(count[$1] == 0) {
      count[$1] = 0;
      fieldNames[fields]=$1
      fields += 1;
    }
    values[$1, count[$1]] = $2;
    count[$1] += 1;
    if(count[$1] > maxcount)
      maxcount = count[$1];
  }
  END{
    for(i = 0; i < fields-1; i++)
      printf("%s \t", fieldNames[i]); 
    print fieldNames[fields-1];

    
    for(i = 0; i < maxcount; i++) {
      for(j = 0; j < fields; j++)
        printf("%s\t", values[fieldNames[j], i]);
      print ""
    }
  }
'
rm $$temp
