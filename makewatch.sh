#!/bin/bash
# Locate kqwait
# In path?
WAITCMD=kqwait
if ! $(command -v $WAITCMD 2>/dev/null >&2)
then
	WAITCMD=./kqwait
fi

# Local directory?
if ! $(command -v $WAITCMD 2>/dev/null >&2)
then
	# Not found, install it to the directory where makewatch is located
	BASE=`dirname ${BASH_SOURCE[0]}`
	echo Unable to find kqwait, installing to $BASE

	curDir=`pwd`
	cd "$BASE"

	# Download and build it
	echo Pulling kqwait
	git clone https://github.com/sschober/kqwait.git tempbuild
	
	echo Building
	cd tempbuild
	make kqwait

	# Move exe back to where makewach actually is
	echo Saving locally
	mv kqwait ..

	# Remove temp crap and switch back to the original director
	echo Cleaning up
	cd ..
	rm -rf tempbuild

	cd "$curDir"

	echo $0 is ready to run!
fi

if [[ $# == 0 ]]
then
	echo Usage: $0 \<file\> \[\<file\> ...\]
	exit 1
fi

while true
do
	make
	echo Waiting for changes to $@
	sleep 1
	"$WAITCMD" "$@"
done

