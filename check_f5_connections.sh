#!/bin/bash

# ========================================================================================
# F5 Monitoring plugin
# 
# Written by         	: Bright Antony (brightantony.g@gmail.com)
# Release               : 
# Creation date			: 
# Revision date         : 
# Description           : Nagios plugin (script) will check the F5 LTM and monitor the virtual server statistics and send alert in case any issues. 
#			 
#			  
#			  This script has been designed and written on Linux plateform. 
#						
# Usage                 : ./f5_statistics.sh -H <host name> -C <snmp comunity> -v <vitual server name> -w <warning thrushold> -c <critical thrushold>
#		
#
# -----------------------------------------------------------------------------------------
#
#		 
#
# =========================================================================================
#
# HISTORY :
#     Release	|     Date	|    Authors		| 	Description
# --------------+---------------+-----------------------+----------------------------------
# =========================================================================================

# Paths to commands used in this script
PATH=$PATH:/usr/sbin:/usr/bin

# Nagios return codes
state_ok="0"
state_warning="1"
state_critical="2"
state_unknown="3"

#Basis declarion

program=`basename $0`
programpath=`echo $0 | sed -e 's,[\\/][^\\/][^\\/]*$,,'`
revision="rev 1.1"	
author="Bright Antony (brightantony.g@gmail.com)"

#usgae and help 

program_info() {
	echo "$program $programpath $revision $author"
}

function_usage() {
	echo "usage: $program -H <host name> -C <snmp comunity> -s <vitual server name> -w <warning thrushold> -c <critical thrushold>"
	echo ""
	echo "-H host name or ip address for the F5 device"
	echo "-C community string"
	echo "-v virtaul server name"
	echo "-w warning thrushold"
	echo "-c critical thrushold"
	echo ""
}
function_help() {
	program_info
	echo ""
	function_usage
	echo ""
	exit $state_ok;	
}

# -----------------------------------------------------------------------------------------
# Default variable if not define in script command parameter
# -----------------------------------------------------------------------------------------
snmp_comunity="public"
check="virtual_server"
warning="3000"
critical="3750"

# -------------------------------------------------------------------------------------
# Grab the command line arguments
# --------------------------------------------------------------------------------------

while [ $# -gt 0 ]; do
	case "$1" in
		-h | --help)
            	function_help
            	exit $state_ok
            	;;
        -v | --version)
                program_info
                exit $state_ok
                ;;
        -H | --host)
                shift
                host=$1
                ;;
        -C | --comunity)
              	shift
              	snmp_comunity=$1
                ;;
		-s | --virtual_server)
			shift
			vsname=$1
			;;
		-w | --warning )
			shift
			warning=$1
			;;
		-c | --critical )
			shift
            critical=$1
            ;;
		*)  echo "Unknown argument: $1"
            	function_usage
            	exit $STATE_UNKNOWN
            	;;
		esac
	shift
done

if [ -z "$host" ]; then
	echo "Error: host is required"
	function_usage
	exit $STATE_UNKNOWN
fi

if [ -z "$vsname" ]; then
	echo "Error: Virtual server name is required"
	function_usage
	exit $STATE_UNKNOWN
fi

#fi 
base=.1.3.6.1.4.1.3375.2.2.10.2.3.1
connectiontype=12
vsfullname=/Common/$vsname
#count number of charecter in the virtual server 
vslength=${#vsfullname}

#converting virtual server name to decimal
vsdec=()
idx=0
for ((i=0;i<$vslength;i++)); do
vsdec[idx]=`printf "%d" \'${vsfullname:i}`
idx=$((idx+1))
done
bar=$(IFS=. ; echo "${vsdec[*]}")
oid=$base"."$connectiontype"."$vslength"."$bar
#echo $host
#echo $snmp_comunity
#echo $oid 
#echo $vsfullname
#oput=`/usr/bin/snmpget -v 2c -c $snmp_comunity $host $oid | awk ' {print $4} '`
oput=759
if [ "$?" != "0" ]; then
		echo "UNKNOWN: snmpget returned an error"
		exit 3
fi
echo $warning
main () {
#[ $oput -eq 0 ] && 
if [ $oput -lt $warning ]; then 
	echo "Ok | $oput"
	exit $state_ok
elif
	[ $oput -ge $warning ] && [ $oput -lt $critical ]; then
	echo "Warning | $oput"
	exit $state_warning
elif
	[ $oput -ge $critical ]; then
	echo "Critical | $oput"
	exit $state_critical

else
	echo "Unknown"
	exit $state_unknown
fi
}

main 

