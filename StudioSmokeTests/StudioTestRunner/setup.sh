#!/bin/bash

#use this to setup test state like appc cli, sdk version etc
#will call this from runner.sh and pass arguments from there like version nos.
#in this will get those and setup
#and also login into appc cli
#
#

APPC_VERSION=$1
SDK_VERSION=$2
APPC_USER=$3
APPC_PWD=$4
APPC_ORGID=$5


################################################################################
# Executes command with a timeout
# Params:
#   $1 timeout in seconds
#   $2 command
# Returns 1 if timed out 0 otherwise
timeout() {

    time=$1

    # start the command in a subshell to avoid problem with pipes
    # (spawn accepts one command)
    command="/bin/sh -c \"$2\""

    expect -c "set echo \"-noecho\"; set timeout $time; spawn -noecho $command; expect timeout { exit 1 } eof { exit 0 }"     

    if [ $? = 1 ] ; then
        echo "Timeout after ${time} seconds"
    fi

}

function useAppcCLIVersion()
{
# Install appc cli to specific version
timeout 5 "appc -v" > setupOutput.txt
if grep -q $APPC_VERSION setupOutput.txt
then
	echo "Appc version already installed. Continue Test...."
else
	timeout 3600 "appc use $APPC_VERSION" | tee setupOutput.txt
	cat setupOutput.txt | grep -qE "${APPC_VERSION}.*is now your active version"
    if [ $? == 0 ]
    then
    	echo "Switched to appc version "$APPC_VERSION ". Continue Test...."
    else
    	cat setupOutput.txt | grep -qE "Installed"
    	if [ $? == 0 ]
    	then
    		echo "Installed and switched to appc version "$APPC_VERSION ". Continue Test...."
    	else
    		(>&2 echo "error using specified Appc Version "$APPC_VERSION)
    		return 1
    	fi
    fi
fi
return 0
}

function useTiSdkVersion()
{
# Install Ti SDK version nd make it selected version
timeout 3600 "appc ti sdk install ${SDK_VERSION}" | tee setupOutput.txt
cat setupOutput.txt | grep -qE "Titanium SDK.*${SDK_VERSION}.*is already installed"
if [ $? == 0 ]
then
	echo "Titanium SDK version already installed"
else
	cat setupOutput.txt | grep -qE "Titanium SDK.*${SDK_VERSION}.*successfully installed"
	if [ $? == 0 ]
	then
		echo "Titanium SDK version successfully installed"
	else
		(>&2 echo "error installing specified SDK Version "$SDK_VERSION)
		return 1
	fi
fi
timeout 60 "appc ti sdk select ${SDK_VERSION}" | tee setupOutput.txt
cat setupOutput.txt | grep -qE "Configuration saved"
if [ $? == 0 ]
then
	echo "Titanium SDK version "$SDK_VERSION "configured as default version. Continue Test...."
else
	(>&2 echo "error using specified SDK Version "$SDK_VERSION)
	return 1
fi
return 0
}


function appcLogin()
{
	# login into appc cli using credentials passed to the script
	timeout 60 "appc login --username $APPC_USER --password $APPC_PWD --org-id $APPC_ORGID" | tee setupOutput.txt
	cat setupOutput.txt | grep -qE "$APPC_USER.*logged into organization.*[$APPC_ORGID]"
	if [ $? == 0 ]
	then
		echo "Successfully logged into Appc CLI. Continue Test...."
	else
		(>&2 echo "Login into Appc CLI not successful")
		return 1
	fi
	return 0
}

useAppcCLIVersion
if [ "$?" = "0" ]
then
	echo ""
	# Do nothing
else
	exit 1
fi

#appcLogin
if [ "$?" = "0" ]
then
	echo ""
else
	exit 1
fi

useTiSdkVersion
if [ "$?" = "0" ]
then
	echo ""
else
	exit 1
fi



#Finally return with exit code 0
exit 0
