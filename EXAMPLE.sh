#EXAMPLE

script_name=$(basename "$0")
short=u:b:s:
long=user:,branch:,start_time:,help

read -r -d '' usage <<EOF
Manually written help section here
EOF

TEMP=$(getopt -o $short --long $long --name "$script_name" -- "$@")

eval set -- "${TEMP}"

while :; do
    case "${1}" in
        -u | --user       ) user=$2;             shift 2 ;;
        -b | --branch     ) branch=$2;           shift 2 ;;
        -s | --start_time ) start_time=$2;       shift 2 ;;
        --help            ) echo "${usage}" 1>&2;   exit ;;
        --                ) shift;                 break ;;
        *                 ) echo "Error parsing"; exit 1 ;;
    esac
done

# Set your short and long options. A colon implies it needs an option argument. Short options are written with no delimiter, long options are comma delimited.

# The getopt command makes sure items come in an easily parsable order. In this example, we use a case statement to parse each option. All options are parsed first and then removed from $@.

# What's left are the passed arguments that is not part of any defined option.