#!/bin/bash


is_valid_user() {
	local user=$1
	echo "  -- is_valid_user : check request for $user"
	cat ${configfile} | grep "$user;" > /dev/null
	local ret=$?
	[ $ret == 1 ] && (echo "user $user not allowed" ; return 1)
	[ $ret == 0 ] && (echo "  -- user $user allowed" ; return 0)
}

is_valid_app() {
	local global_match=$@
	echo "  -- is_valid_app : check request for $global_match"
	cat ${configfile} | grep "$global_match" > /dev/null
	local ret=$?
	[ $ret == 1 ] && (echo "global config $global_match not allowed" ; return 1)
	[ $ret == 0 ] && (echo "  -- global config $global_config allowed" ; return 0)
}

get_user() {
	local cmd=$@
	echo $cmd | awk '{print $1}'
}

get_app() {
	local cmd=$@
	echo $cmd | awk '{print $2}'
}

nsdo() {
        ip netns exec "${namespace}" "$@"
}

launch_app() {
	local user=$1
	local app=$2
	echo "  -- nsdo sudo -u $user $app"
	nsdo sudo -u $user $app
}

treat_command() {
	local cmd=$@
	local user=$(get_user $cmd)
	local app=$(get_app $cmd)
	echo "$0 => detected request for user $user and app $app"
	is_valid_user "$user" && is_valid_app "$user;$app" && launch_app "$user" "$app"
}


#################################################
#						#
# 	main entry				#
#						#
#################################################

namespace=$1
if [ -z "${namespace}" ]; then
	echo "namespace is mandatory as parameter"
	exit 1
fi

configfile="/usr/local/etc/vpnshift/vpn-client-allowed.conf"
export DISPLAY=:0

while line="`ncat -l 127.0.0.1 4444`"; do

	if [ "$line" = "exit" ]; then
		echo "exiting $0 ..."
		exit 0
	fi

	treat_command "$line"

done

