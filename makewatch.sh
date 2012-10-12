#!/bin/bash
# On OSX we use kqwait, on Linux we use inotify
if [ $(uname) == "Darwin" ]
then
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
else
	# In path?
	WAITCMD="inotifywait -qq"
	if ! $(command -v $WAITCMD 2>/dev/null >&2)
	then
		echo Please install inotifywait \(usually in your distribution\'s inotify-tools package\)
		exit 1
	fi
fi

# Was a special target given for make?
TARGET=""
if [[ "$1" == "-t" ]]
then
	TARGET=$2
	
	echo Using make target $TARGET
	
	shift
	shift
fi

# Files were given to watch, right?
if [[ $# == 0 ]]
then
	echo Usage: $0 '[-t <maketarget>] <file> [<file> ...]'
	exit 1
fi

# Move to directory with files we're watching (assume the first one is where the makefile is)
cd `dirname $1`
echo Running make in `pwd`

# And monitor
while true
do
	make $TARGET

	sleep 2
	echo Waiting for changes to $@
	$WAITCMD "$@" >/dev/null
done

