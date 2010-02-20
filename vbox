#!/bin/bash
#
# Author: JT Wilkinson
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
VERBOSE=
RAM=

########################### Functions ##################################

# isRunning() - Takes one argument, the name of the Virtual Machine.  If 
# the VM is running it returns 1, else it returns 0.
isRunning() {
	VMNAME=$1
	MATCH=$(VBoxManage -q list runningvms | sed 's/"\(.*\)".*/\1/' | grep ^${VMNAME}$)
	if [ $MATCH ]; then
		return 1
	else
		return 0
	fi
}

# startVM() - takes 3 arguments, VBOX name, HOST name, Port number,
# in that order
startVM() {
	VBOX=$1
	HOST=$2
	PORT=$3
	
	if [ -n "$VBOX" ]; then
		isRunning "$VBOX"
		RUNNING=$?
		if [ $RUNNING -eq 1 ]; then
			echo "$VBOX is already running"
			exit 1
		else
			echo "$VBOX is not running, starting it"
			if [ -n "$PORT" ]; then
				echo "Starting VRDP on ${HOST}:${PORT}"
				VBoxHeadless -startvm "$VBOX" --vrdp=on \
					--vrdpport $PORT --vrdpaddress $HOST  &
				disown
			else
				echo "Starting VM $VBOX with no vrdp"					
				VBoxHeadless -startvm "$VBOX" --vrdp=off &
				disown
			fi
		fi
	else
		echo "No virtual machine specified"
		exit 1
	fi
}

# isValidVM() - Takes one argument, the name of the Virtual Machine.  If 
# the VM is registered with VirtualBox it returns 1, else it returns 0.
isValidVM() {
	VMNAME=$1
	MATCH=$(VBoxManage -q list vms | sed 's/"\(.*\)".*/\1/' | grep ^${VMNAME}$)
	#echo "Match is $MATCH"
	if [ $MATCH ]; then
		return 1
	else
		return 0
	fi
}

# isValidPort() - Takes one argument, a port number.  It returns 1 if the
# port is valid for a VRDP server and 0 otherwise.
isValidPort() {
	PORT=$1
	if [ $PORT -lt 1024 ] || [ $PORT -gt 65535 ]; then
		return 0
	fi
	
	return 1
}

######################### Main #########################################

# Parse the command line flags and options
OPTS=$(getopt -o h:p:vr: --long vm:,host:,port:,verbose,help,ram: -n 'vbox.bash' -- "$@")
if [ $? != 0 ] ; then echo "Terminating..." >&2 ; exit 1 ; fi
eval set -- "$OPTS"


# Process command line flags
while [ "$1" != "--" ]
do
	case $1 in
		--vm) 
			VBOX=$2
			
			# Check if this VM is registered with VirtualBox
			isValidVM $VBOX
			if [ $? -eq 0 ]; then
				echo "$VBOX is not a valid VM on this machine"
				exit 1
			fi
			shift 2
			;;
		-h|--host)
			echo "Using host $2"
			HOST=$2
			shift 2
			;;
		-p|--port)
			PORT=$2
			isValidPort $PORT 
			if [ $? -eq 0 ]; then
				echo "$PORT is not a valid port"
				echo "Choose an unused port between 1024 and 65535"
				exit 1
			fi
			echo "Using VRDP port $2"
			shift 2
			;;
		-v|--verbose)
			#echo "Verbose mode on"
			VERBOSE=1
			shift
			;;
		-r|--ram)
			#echo "RAM variable is $2"
			RAM=$2
			shift 2
			;;
		--help)
			echo "Read the script dummy"
			exit 0
			;;	
		--)
			echo "This shouldn't get printed!!!!"
			shift
			;;
		*)
			echo "usage: $0 [OPTION] COMMAND"
			exit 1
	esac
done

# Move past the -- at the end of the flags
shift

# Process the command
while [ "$1" != "" ]
do
	case $1 in
		start)
			startVM $VBOX $HOST $PORT
			shift
			;;
		poweroff)
			VBoxManage -q controlvm "$VBOX" poweroff
			exit $?
			;;
		reset)
			VBoxManage -q controlvm "$VBOX" reset
			exit $?
			;;
		pause)
			echo "Use the resume command to unpause the machine"
			VBoxManage -q controlvm "$VBOX" pause
			exit $?
			;;
		resume)
			if [ -n "$VBOX" ]; then
				echo "Resuming $VBOX"
				VBoxManage -q controlvm "$VBOX" resume
				exit $?
			else
				echo "Must specify a VM to resume"
				exit 1
			fi
			;;
		save)
			VBoxManage -q controlvm "$VBOX" savestate
			echo "Use the start command to resume from the saved state"
			exit 0
			;;
		status)
			echo "Host: $VBOX @ $HOST:$PORT"
	    	echo "Status: $(VBoxManage showvminfo $VBOX | grep State | cut -d" " -f12-)"
			exit 0
			;;
		list)
			if [ $VERBOSE ]; then
				VBoxManage -q list vms 
			else
				VBoxManage -q list vms | sed 's/"\(.*\)".*/\1/'
			fi
			shift
			;;
		listrunning)
			if [ $VERBOSE ]; then
				VBoxManage -q list runningvms 
			else
				VBoxManage -q list runningvms | sed 's/"\(.*\)".*/\1/'
			fi
			shift
			;;
		show)
			if [ -n "$VBOX" ]; then
				echo "Showing $VBOX"
				VBoxManage -q showvminfo "$VBOX"
			else
				echo "Must specify a VM to show"
				exit 1
			fi
			shift
			;;
		setram)
			if [ "$VBOX" ] && [ "$RAM" ]; then
				isRunning "$VBOX"
				if [ "$?" -eq 0 ]; then
					echo "Setting RAM of $VBOX to $RAM"
					VBoxManage -q modifyvm "$VBOX" --memory "$RAM"
				else
					echo "Cannot modify RAM of a running VM"
				fi
			else
				echo "Must specify a powered down VM to modify and a RAM amount"
				exit 1
			fi
			shift
			;;
		setcpus)
			shift
			;;
		running)
			isRunning "$VBOX"
			if [ "$?" -eq 1 ]; then
				echo "$VBOX is running"
			else
				echo "$VBOX is not running"
			fi
			shift
			;;
		*)
			echo "usage: $0 [OPTION] COMMAND"
			exit 1
	esac
done

# Finished without errors
exit 0

