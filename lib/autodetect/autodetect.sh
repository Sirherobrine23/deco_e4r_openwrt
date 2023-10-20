#!/bin/sh
# Copyright(c) 2008-2014 Shenzhen TP-LINK Technologies Co.Ltd.
#
# Details : The real auto detection script.
# Author  : Ye Qianchuan <yeqianchuan@tp-link.net>
# Version : 1.0
# Date    : 25 Mar, 2014
# History : 
#   The script will not do dhcp detection at Router Mode.
#   If wan connetction type isn't Dynamic IP, the dhcp detection will consume an IP of front-end network. 
#   The netifd will do dhcp detection when wan connection is Dynamic IP
#   By humin, 24Sep2017

. /lib/functions/network.sh

# Get wan interface.
network_get_physdev IFC wan

DNS_FILE=/tmp/autodetect-dns
DHCP_SCRIPT="/lib/autodetect/dhcp.script"
DHCP_PIDFILE="/var/run/udhcpc-${IFC}:${DHCP_ALIAS}.pid"
SYS_MODE_DB=/tmp/sys_mode

DHCP_IFC=${IFC}:${DHCP_ALIAS}
PPPOE_IFC=${IFC}:${PPPOE_ALIAS}

internet_ok=1
dhcp_ok=1
pppoe_ok=1

record() {
    echo $@ >$RESULT_FILE
}

record_clean_and_exit() {
    record $@
    cat $RESULT_FILE > $RESULT_FILE_SAVE 
    rm -f $DNS_FILE
    [ -f "$DHCP_PIDFILE" ] && kill $(cat "$DHCP_PIDFILE")
    exit 0
}

sysmode_get_db() {
    local sys_mode="Router"
    if [ -f $SYS_MODE_DB ]; then
        sys_mode="$(cat $SYS_MODE_DB)"
    fi
    echo $sys_mode
}

wan_get_proto() {
    local ifc=wan
    ubus list | grep -q network.interface.internet && ifc=internet

    local proto
    network_get_proto proto $ifc && echo $proto || echo none
}

# Check physical connection.
network_get_link physlink $IFC
[ -z "$physlink" ] && record_clean_and_exit "none"
[ "$physlink" = 0 ] && record_clean_and_exit "unplugged"

# Check the internet status. 
#deleted by wanghao
#online-test "$CHECK_URL" "$DNS_FIRST_TIMEOUT" && \
#    record_clean_and_exit "$(wan_get_proto)"

# Update estimated time
record time $(((EST_TIME-INTERNET_TIMEOUT)*1000))

# Check DHCP.
#add by wanghao
#if [ "$(wan_get_proto)" != "dhcp" -o "$(sysmode_get_db)" = "AP" ]; then
#For Router mode, if wan protol isn't dhcp, we don't need to do dhcp detection that consume an IP of front-end network
if [ "$(sysmode_get_db)" = "AP" ]; then
host_name=deco_$(getfirm MODEL)
#broadcast=""
#if [ "$(sysmode_get_db)" = "AP" ];then
broadcast="-B"
#fi
udhcpc \
    -p "$DHCP_PIDFILE" \
    -s "$DHCP_SCRIPT" \
    -i $DHCP_IFC \
    -t $DHCP_TIMEOUT -T $DHCP_RETRIES \
    -n -R -h "$host_name" "$broadcast" >/dev/null &
# This is the foreground udhcpc pid.
DHCP_PID=$!
else 
    if [ "$(wan_get_proto)" = "dhcp" ]; then
    	#add by wanghao for wanDetection
    	ifconfig br-wan down
    	sleep 1
    	ifconfig br-wan up
    fi
fi

if [ "$(sysmode_get_db)" != "AP" ]; then
# Check PPPOE.
pppoe-discovery \
    -U \
    -I $PPPOE_IFC \
    -t $PPPOE_TIMEOUT -T $PPPOE_RETRIES >/dev/null &
PPPOE_PID=$!
fi

# Check the DHCP status and
# check the internet status with DNS server set.
#add by wanghao
if [ -n "$DHCP_PID" ]; then
    if wait $DHCP_PID; then
        # Update estimated time
        record time $((DNS_TIMEOUT*1000))

        dnslookup -t $DNS_TIMEOUT "$CHECK_URL" $(cat "$DNS_FILE") >/dev/null && \
        record_clean_and_exit "dhcp"
    fi
fi

# Check the PPPOE status.
[ -n "$PPPOE_PID" ] && wait $PPPOE_PID && \
    record_clean_and_exit "pppoe" || record_clean_and_exit "dhcp"
