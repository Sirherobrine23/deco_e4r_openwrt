#!/bin/sh
. /usr/share/libubox/jshn.sh

[ -n "$INCLUDE_ONLY" ] || {
	. /lib/functions.sh
	. ../netifd-proto.sh
	init_proto "$@"
}

proto_passthrough_init_config() {
	no_device=1
	available=1
}

proto_passthrough_setup() {

    device_id=$(getfirm DEV_ID)
    config_load bind_device_list
    config_get device_type $device_id role "AP"

    if [ "$device_type" == "RE" ];then
        return
    fi
	
    config_load sysmode
    config_get sys_mode sysmode mode 'Router'
    config_clear

    [ "$sys_mode" != "Router" ] && return 0

    sleep 1

        echo "#######################passthrough.sh: proto_passthrough_setup###########################" > /dev/console
	json_init
	json_load "`ubus call network.interface.wan status`"
	json_get_var device device
	#add by wanghao
	#echo 1 > /proc/sys/net/bridge/bridge-nf-call-iptables
	#add end
	insmod ipv6-pass-through wan_eth_name=$device lan_br_name=br-lan lan_eth_name=eth0.1
	/etc/init.d/dhcp6s stop
#	killall dhcp6c
	/etc/init.d/radvd stop
 
    local support_sgmac=$(uci -c /etc/profile.d get profile.switch.sgmac)
    if [ -n "$support_sgmac" -a "$support_sgmac" == "yes" ]; then
	. /usr/lib/wanDetect/disconnect_lan_sgmac.sh
        replug_lan_eth_sgmac
    fi    
}

proto_passthrough_teardown() {
	local interface="$1"
	local ifname=""
	
        echo "#######################passthrough.sh: proto_passthrough_teardown###########################" > /dev/console
	rmmod  ipv6-pass-through
	#add by wanghao
	#echo 0 > /proc/sys/net/bridge/bridge-nf-call-iptables
	#add end
}

[ -n "$INCLUDE_ONLY" ] || {
	add_protocol passthrough
}
