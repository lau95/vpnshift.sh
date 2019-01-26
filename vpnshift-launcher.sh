#!/bin/bash

quick_die() {
        format="$1"; shift
        >&2 printf "${format}\n" "$@"
        exit 1
}

hush() {
        eval "$@" > /dev/null 2> /dev/null
}

is_running() {
        local pid="$1"
        hush kill -s 0 "${pid}"
}

sig_kill() {
        local pid="$1"
        hush kill -s KILL "${pid}"
}

sig_term1() {
	echo "exit" | ncat 127.0.0.1 4444
	ret=$?
	[ $ret == 1 ] && ( echo "request to stop VPNshift failed, is the system really running?" ; return 1)
	return 0
}

sig_term() {
        local pid="$1"
        hush kill -s TERM "${pid}"
}


clean_exit() {

        if is_running "${vpnshift_pid}"; then
                # Kill openvpn.
		>&2 printf "stopping vpnshift (pid = %d)." "${vpnshift_pid}"
                sig_term1 
		if [ $? == 0 ]; then 
			for i in {1..100}; do 
				if is_running "${vpnshift_pid}"; then 
					sleep 0.1
					printf "." 
				else 
					break 
				fi 
			done 
		fi

		# KO still running (1/2)
        	if is_running "${vpnshift_pid}"; then
        		>&2 echo "try to send TERM signal directly to vpnshift"
        		#sig_term "${vpnshift_pid}"
        	fi

		for i in {1..100}; do
			if is_running "${vpnshift_pid}"; then
				sleep 0.1
				printf "."
			else
				break
			fi
		done

		# KO still running (2/2)
        	if is_running "${vpnshift_pid}"; then
        		>&2 echo "forced to kill vpnshift"
        		#sig_kill "${vpnshift_pid}"
        	fi

        else
        	echo "vpnshift exited"
	fi
	exit 0
}

	

 #####   #######     #     ######   #######  
#     #     #       # #    #     #     #     
#           #      #   #   #     #     #     
 #####      #     #     #  ######      #     
      #     #     #######  #   #       #     
#     #     #     #     #  #    #      #     
 #####      #     #     #  #     #     #     

myself=`basename $0`
usage="
	Start or stop vpnshift server

	${myself} [-a <openvpn_config_file>] [-o <vpnshift_main_pid> ] [-h]
		-a : start service on openvpn_config_file config file
		-o : stop service on vpnshift_main_pid PID (e.g. provided by MAINPID from systemd
		-h : this help

"

while getopts "a:o:h" opt; do
      case "${opt}" in
            h) quick_die "${usage}" ;;
            a) request="start" vpnconfig="${OPTARG}";;
            o) request="stop"; vpnshift_pid="${OPTARG}" ;;
          *) quick_die "unknown option: %s" "${opt}" ;;
      esac
done

if [ "$request" = "start" ]; then

	lpwd="`dirname $0`"
	echo "starting vpnshift procedure on config ${vpnconfig}"
	${lpwd}/vpnshift.sh -c ${vpnconfig}

fi

if [ "$request" = "stop" ]; then

	echo "stopting vpnshift procedure on pid ${vpnshift_pid}"
	clean_exit

fi


exit 0

