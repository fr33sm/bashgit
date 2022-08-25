#! /bin/bash

function usage() {
	cat <<USAGE

	Usage: $0 [-t tag] [--skip-verification]

	Options:
		-t, --tag:            information about argument
		--skip-verification:  information about argument
USAGE
	exit 1
}

if [ $# -eq 0 ]; then
	usage
	exit 1
fi

SKIP_VERIFICATION=false
TAG=

while [ "$1" != "" ]; do
	case $1 in
	--skip-verification)
		SKIP_VERIFICATION=true
		;;
	-t | --tag)
		TAG=$2
		shift
		;;
	-h | --help)
		usage
		;;
	*)
		usage
		exit 1
		;;
	esac
	shift
done

if [[ $TAG == "" ]]; then
	echo "You must provide a tag";
	exit 1;
fi

if [[ $SKIP_VERIFICATION == false ]]; then
	echo "do not verify"
else
	echo "do verify"
fi

# https://www.banjocode.com/post/bash/flags-bash