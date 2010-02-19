#!/bin/bash
#
# This program is free software. It comes without any warranty, to
# the extent permitted by applicable law. You can redistribute it
# and/or modify it under the terms of the Do What The Fuck You Want
# To Public License, Version 2, as published by Sam Hocevar. See
# http://sam.zoy.org/wtfpl/COPYING for more details.
#

########################### Variables ##################################

VBOX=
HOST=localhost
PORT=

########################### Functions ##################################

#help() {
	#echo "vbox = $VBOX"
#}


######################### Main #########################################

# Parse the command line flags and options
OPTS=$(getopt -o v:h:p: --long vm:,host:,port: -n 'vbox.bash' -- "$@")
if [ $? != 0 ] ; then echo "Terminating..." >&2 ; exit 1 ; fi
eval set -- "$OPTS"

# Print command line arguments
#echo "Printing args"
#for arg in $@
#do
	#echo $arg 
#done
#echo "done printing args"
#echo ""


# Do the real work
while [ "$1" != "" ]
do
	case $1 in
		-v|--vm) 
			echo "Using VM $2"
			VBOX=$2
			shift 2
			;;
		-h|--host)
			echo "Using host $2"
			HOST=$2
			shift 2
			;;
		-p|--port)
			echo "Using VRDP port $2"
			PORT=$2
			shift 2
			;;
		start)
			if [ -n "$VBOX" ]; then
				echo "Starting $VBOX"
				if [ -n "$PORT" ]; then
					echo "VRDP running on port $PORT"
					VBoxHeadless -startvm "$VBOX" --vrdp=on --vrdpport $PORT &
					disown
				else
					echo "Starting VM $VBOX with no vrdp"					
					VBoxHeadless -startvm "$VBOX" --vrdp=off &
					disown
				fi
			else
				echo "No virtual machine specified"
				exit 1
			fi
			shift
			;;
		poweroff)
			VBoxManage controlvm "$VBOX" poweroff
			;;
		reset)
			VBoxManage controlvm "$VBOX" reset
			;;
		pause)
			VBoxManage controlvm "$VBOX" pause
			echo "Use the resume command to unpause the machine"
			;;
		resume)
			if [ -n "$VBOX" ]; then
				echo "Resuming $VBOX"
				VBoxManage controlvm "$VBOX" resume
			else
				echo "Must specify a VM to resume"
				exit 1
			fi
			;;
		save)
			VBoxManage controlvm "$VBOX" savestate
			echo "Use the start command to resume from the saved state"
			exit 0
			;;
		status)
			echo "Host: $VBOX @ $HOST:$PORT"
	    		echo "Status: `VBoxManage showvminfo $VBOX | grep State | cut -d" " -f12-`"
			exit 0
			;;
		help)
			echo "Read the script dummy"
			help
			exit 0
			;;	
		--)
			#echo "Done processing flags"
			shift
			;;
		*)
			echo "usage: $0 [OPTION] COMMAND"
			exit 1
	esac
done

# Finished without errors
exit 0

