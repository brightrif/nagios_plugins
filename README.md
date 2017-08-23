# nagios_plugins
This script will check the virtual servers and return the status with perf data. 

Usage:
./check_f5_connection.sh -H <host name> -C <snmp comunity> -v <virtual server name> -w <warning threshold> -c <critical threshold>

Host name and virtual server name are the mandatory field 

Default community name is public, Default warning threshold is 500 , Default Critical threshold is 750

