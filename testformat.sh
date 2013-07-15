#!/bin/bash

latex_mode=""
tformat_index_label=""
while getopts "i:xh" opt
do
  case $opt in
  i)
    tformat_index_label=$OPTARG
  ;;
  x)
    latex_mode="true"
  ;;
  :)  
    echo "Option -$OPTARG requires an argument." >&2
    exit
  ;;
  h|[?]|help)
    echo "tformat [OPTIONS] 'cmd'"
    echo -e "option\tparam\t\teffect"
    echo -e "-h\t\t\thelp"
    echo -e "-x\t\t\tlatex mode" 
    echo -e "-i\tindex_label\tlabel for the index"
    exit
  ;;
  esac
done

if [ $OPTIND -gt "1" ]; then shift $(( OPTIND - 1 )); fi

gawk -F ":" -v label=$tformat_index_label -v latex_mode=$latex_mode '
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

    printf("%s", label);
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
