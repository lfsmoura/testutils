#!/bin/bash

latex_mode=""
while getopts "xh" opt
do
  case $opt in
  x)
    latex_mode="true"
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
    echo "-p     - uses the indices as the last paramater of cmd"
    echo "-n     - same as -m \'seq 1 n\', executes n times"
    echo "ex: ./testutil -lpn 10 echo test:"
    echo "ex: ./testutil -lpm '\`seq 10 10 100\`' echo test:"
    exit
  ;;
  esac
done

if [ $OPTIND > 1 ]; then shift $((OPTIND-1)); fi

gawk -F ":" -v latex_mode=$latex_mode '
  BEGIN{ 
    maxcount=0;
    if(latex_mode){
      separator="&";
      lseparator = "\\\\";
    }
  }
  NF>1 {
    gsub(/[ \t]/, "", $2);
    fields[$1] = $1;
    if($3) {
      id = $3
    } else {
      id = ++count[$1];
    }
    ids[id] = id;
    values[$1, id, ++count[$1, id]] = $2;
  }
  function mean(field, id) {
    c = count[field,id]
    sum = 0;
    for(i=1;  i<=c;  i++) {
      sum += values[field, id, i];
    }
    return sum / c;
  }
  function sdev(field, id) {
    c = count[field,id];
    sumsq = 0;
    for(i=1; i<=c; i++){
      val = values[field, id, i];
      sumsq += val*val;
    }
    meanv = mean(field,id);
    return sqrt((sumsq/c) - (meanv * meanv));
  }
  END{
    if(latex_mode){
      #nfields = split(fields, $a);
      nfields = length(fields);
      print "\\begin{tabular}{*{" nfields + 1 "}{c}}"
      print "\\hline"
    }

    printf("#");
    for(field in fields)
      printf("\t %s %s", separator, field); 
    printf(" %s \n", lseparator);

    if(latex_mode)
      print "\\hline"

    for(id in ids) {
      printf("%s \t", id);
      for(field in fields){
        if(!count[field,id])
          printf("%s - ", separator);
        else if(count[field,id] > 1)
          printf("%s %.3f±%.3f(%d) " , separator, mean(field,id), sdev(field, id), count[field,id]);
        else
          printf("%s %s\t", separator, values[field, id, 1]);
      }
      print lseparator
    }

    if(latex_mode){
      print "\\hline";
      print "\\end{tabular}";
    }
  }' |
if [ "true" ]
then
  column -t
fi
