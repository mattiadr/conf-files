#!/bin/sh

print_usage() {
	echo "USAGE:"
	echo "  commit_awesome.sh commit \"msg\""
	echo "  commit_awesome.sh push"
	exit 1
}

if [ "$#" -lt 1 ]; then
	print_usage
fi

BLUE='\033[0;34m'
NC='\033[0m'

# exit on first failed command
set -e

if [ "$1" == "commit" ]; then
	if [ "$#" -eq 2 ]; then
		cd awesome
		echo -e "[${BLUE}awesome-config${NC}] git add --all"
		git add --all
		echo -e "[${BLUE}awesome-config${NC}] git commit -m \"$2\""
		git commit -m "$2"
		cd ..
		echo -e "[${BLUE}conf-files${NC}] git add awesome"
		git add awesome
		echo -e "[${BLUE}conf-files${NC}] git commit -m \"awesome: $2\""
		git commit -m "awesome: $2"
		exit 0
	else
		print_usage
	fi
fi

if [ "$1" == "push" ]; then
	echo -e "[${BLUE}conf-files${NC}] git push"
	git push
	cd awesome
	echo -e "[${BLUE}awesome-config${NC}] git push"
	git push
	exit 0
fi

print_usage