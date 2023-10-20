#!/bin/sh
#
#
#
PORT_FILENAME='client_mgmt_port'
BR_FILENAME='client_mgmt_fdb'
CLIENT_FILENAME='client_mgmt_clients'


. /lib/functions.sh

local array
__get_assoclists() {
	local config="$1"  
    local type vapname disabled   
    local port_no

    config_get type "$config" type
    config_get vapname "$config" vapname
	config_get_bool disabled "$config" disabled
	
	if [ "$type" = "lan" ]; then
		type="host"
	elif [ "$type" = "guest" ]; then
		type="guest"
	elif [ "$type" = "default" ]; then
		type="host"
	elif [ "$type" = "backhaul" -o "$type" = "config" ]; then
		type="backhaul"
	else
		return
	fi

    if [ "$type" = "backhaul" ]; then
        __generate_port_role "$vapname.1" "host"
        __generate_port_role "$vapname.2" "guest"
    else
        __generate_port_role "$vapname" "$type"
    fi

}

__get_ethlists() {
    local ethiface="eth0 eth1"
    local vlan_id

    config_load wifi
    #config_get ethiface guest ethiface
    config_get vlan_id guest vlan_id

    local iface

    for iface in $ethiface;
    do
        if [ -n "$iface" ]; then
            __generate_port_role "$iface" "host"
            if [ -n "$vlan_id" ]; then
                __generate_port_role "$iface.$vlan_id" "guest"
            fi
        fi
    done
}

__get_plclist() {
    local plciface

    config_load plc
    config_get plciface config PlcIfname "eth2"
    #local plciface=$(uci get plc.config.PlcIfname) or "eth2"

    local iface

    for iface in $plciface;
    do
        if [ -n "$iface" ]; then
            __generate_port_role "$iface.1" "host"
            __generate_port_role "$iface.2" "guest"
        fi
    done
    
}

__generate_port_role() {
    local port=$1
    local role=$2
    if [ -z "$port" -o -z "$role" ]; then
        echo "invalid input" > /dev/console
        return   
    fi
    if [ -f "/sys/class/net/br-lan/brif/$port/port_no" ];then
        port_no=$(cat /sys/class/net/br-lan/brif/$port/port_no)
        if [ -n "$port_no" ]; then
            printf "%d %s %s\n" "$port_no" "$role" "$port" >> /tmp/$PORT_FILENAME 
        fi
    fi

}



if [ -f /tmp/$PORT_FILENAME ]; then
	rm /tmp/$PORT_FILENAME
fi
touch /tmp/$PORT_FILENAME

if [ -f /tmp/$BR_FILENAME ]; then
	rm /tmp/$BR_FILENAME
fi
touch /tmp/$BR_FILENAME

if [ -f /tmp/$CLIENT_FILENAME ]; then
	rm /tmp/$CLIENT_FILENAME
fi
touch /tmp/$CLIENT_FILENAME

# get fdb list
fdb_list=$(brctl showmacs br-lan | grep -v port | cut -f 1,2 )
echo "$fdb_list" >> /tmp/$BR_FILENAME

config_load wireless
config_foreach __get_assoclists wifi-iface 

__get_ethlists
__get_plclist

#merge file


awk 'NR==FNR{a[$1]=$2}NR!=FNR{$1=a[$1]; if($1 == "host" || $1 == "guest"){ print } }' /tmp/$PORT_FILENAME /tmp/$BR_FILENAME  > /tmp/$CLIENT_FILENAME


