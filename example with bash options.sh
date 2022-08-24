#! /bin/bash
# convert long word options to short word for ease of use and portability

for argu in "$@"; do
  shift
  #echo "curr arg = $1"
  case "$argu" in
"-start"|"--start")
                   # param=param because no arg is required
                   set -- "$@" "-s"
                   ;;
"-pb"|"--pb"|"-personalbrokers"|"--personalbrokers")
                   # pb +arg required
                   set -- "$@" "-p $1"; #echo "arg=$argu"
                   ;;
"-stop"|"--stop")
                   # param=param because no arg is required 
                   set -- "$@" "-S" 
                   ;;
                #  the catch all option here removes all - symbols from an
                #  argument. if an option is attempted to be passed that is
                #  invalid, getopts knows what to do...
               *)  [[ $(echo $argu | grep -E "^-") ]] && set -- "$@" "${argu//-/}" || echo "no - symbol. not touching $argu" &>/dev/null
                   ;;
esac
done

#echo -e "\n final option conversions = $@\n"
# remove options from positional parameters for getopts parsing
shift $(expr $OPTIND - 1)

declare -i runscript=0
# only p requires an argument hence the p:
while getopts "sSp:" param; do
[[ "$param" == "p" ]] && [[ $(echo $OPTARG | grep -E "^-") ]] && funcUsage "order" 
#echo $param
#echo "OPTIND=$OPTIND"
case $param in
s)
       OPTARG=${OPTARG/ /}
       getoptsRan=1
       echo "$param was passed and this is it's arg $OPTARG"
       arg0=start
       ;;
 p)
       OPTARG=${OPTARG/ /}
       getoptsRan=1
       echo "$param was passed and this is it's arg $OPTARG"
       [[ "$OPTARG" == "all" ]] && echo -e "argument \"$OPTARG\" accepted. continuing." && (( runscript += 1 )) || usage="open"
       [[ $( echo $pbString | grep -w "$OPTARG" ) ]] && echo -e "pb $OPTARG was validated. continuing.\n" && (( runscript += 1 )) || usage="personal"
       [[ "$runscript" -lt "1" ]] && funcUsage "$usage" "$OPTARG"
       arg0=start
       ;;
S)
       OPTARG=${OPTARG/ /}
       getoptsRan=1
       echo "$param was passed and this is it's arg $OPTARG"
       arg0=stop
       ;;
*)
       getoptsRan=1
       funcUsage
       echo -e "Invalid argument\n"
       ;;
esac
done
funcBuildExcludes "$@"
shift $((OPTIND-1))