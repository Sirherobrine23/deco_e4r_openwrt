#!/bin/sh

DEBUG_OUTOUT=1
LEVEL=6

local section_name
section_name=$(uci -c /etc/vlan.d get vlan.guest_eth 2>/dev/null)
switch_name=$(uci -c /etc/vlan.d get vlan.@switch[0].name)

config_load sysmode
config_get system_mode sysmode mode "Router"
config_clear

guest_echo() {
    if [ "$DEBUG_OUTOUT" -gt 0 ]; then
            echo "${1}: ""$2"> /dev/console
            logger -p $LEVEL "${1} $2"
        fi
}

touch_section() {
## TODO: Do not use static index number, name it.
    if [ "$section_name" != "switch_vlan" ]; then
        uci -c /etc/vlan.d set vlan.guest_eth="switch_vlan"                              
        uci -c /etc/vlan.d set vlan.guest_eth.device="$switch_device"                           
        uci -c /etc/vlan.d set vlan.guest_eth.vlan="3"                                        

    fi
}


switch_guest_config() {

    local device_type=$1
    local vlan_enable=$2
    local vlan_id=$3
    local vlan_support
    vlan_support=$(uci get profile.switch.switch_vlan -c /etc/profile.d)
    #guest_echo guest-eth "guest-eth start"
    if [ "$vlan_enable" == '0' ]; then
        guest_echo guest-eth "guest vlan not enable, exist"
        return 0;
    fi
    guest_echo guest-eth "Start to set guest vlan"
    #if [ "$sysmode" == "AP" ]; then
    #    return 0;
    #fi
    guest_echo guest-eth "Ignore system signal"
    guest_echo guest-eth "Lock vlan.lock"
    lock /var/run/vlan.lock
    trap "" INT TERM ABRT QUIT ALRM 
    if [ "$device_type" == 'RE' -a -n "$vlan_id" ]; then
        guest_echo guest-eth "RE role, eth0 eth1 set tag port, vlan id is $vlan_id"

        if [ "$vlan_support" == "yes" ]; then
            touch_section
            uci -c /etc/vlan.d set vlan.guest_eth.vid="$vlan_id"
            uci -c /etc/vlan.d set vlan.guest_eth.ports="0t 4t 5t"
            uci commit -c /etc/vlan.d
            swconfig dev $switch_name load /etc/vlan.d/vlan
        fi

        del_invalid_guest_eth "lan" "eth0 eth1"

        if [[ "$system_mode" != "AP" ]]; then
            add_eth_guest "eth0 eth1"
        fi
    elif [ "$device_type" == 'AP' -a -n "$vlan_id" ]; then
        local is_eth0_at_wan=`brctl show br-wan | grep eth0`
        local is_eth1_at_wan=`brctl show br-wan | grep eth1`
        if [ -z "$is_eth0_at_wan" -a -z "$is_eth1_at_wan" ]; then
            guest_echo guest-eth "AP role, eth0 eth1 set tag port, vlan id is $vlan_id"

            if [ "$vlan_support" == "yes" ]; then
                touch_section
                uci -c /etc/vlan.d set vlan.guest_eth.vid="$vlan_id"
                uci -c /etc/vlan.d set vlan.guest_eth.ports="0t 4t 5t"
                uci commit -c /etc/vlan.d
                swconfig dev $switch_name load /etc/vlan.d/vlan
            fi
            del_invalid_guest_eth "lan" "eth0 eth1"
            if [[ "$system_mode" != "AP" ]]; then
                add_eth_guest "eth0 eth1"
            fi
        elif [ -z "$is_eth0_at_wan" ]; then
            guest_echo guest-eth "AP role, eth0 set tag port, vlan id is $vlan_id"

            if [ "$vlan_support" == "yes" ]; then
                touch_section
                uci -c /etc/vlan.d set vlan.guest_eth.vid="$vlan_id"
                uci -c /etc/vlan.d set vlan.guest_eth.ports="0t 5t"
                uci commit -c /etc/vlan.d
                swconfig dev $switch_name load /etc/vlan.d/vlan
            fi
            del_invalid_guest_eth "lan" "eth0"
            if [[ "$system_mode" != "AP" ]]; then
                add_eth_guest "eth0"
            fi

        elif [ -z "$is_eth1_at_wan" ]; then
            guest_echo guest-eth "AP role, eth1 set tag port, vlan id is $vlan_id"

            if [ "$vlan_support" == "yes" ]; then
                touch_section
                uci -c /etc/vlan.d set vlan.guest_eth.vid="$vlan_id"
                uci -c /etc/vlan.d set vlan.guest_eth.ports="0t 4t"
                uci commit -c /etc/vlan.d
                swconfig dev $switch_name load /etc/vlan.d/vlan
            fi
            del_invalid_guest_eth "lan" "eth1"
            if [[ "$system_mode" != "AP" ]]; then
                add_eth_guest "eth1"
            fi
        else
            guest_echo guest-eth "AP role, eth0 and eth1 are on br-wan, clear guest network vlan config"
            if [ "$vlan_support" == "yes" ]; then
                if [ "$section_name" == "switch_vlan" ]; then
                    uci -c /etc/vlan.d delete vlan.guest_eth
                    uci commit -c /etc/vlan.d
                    swconfig dev $switch_name load /etc/vlan.d/vlan
                fi
            fi

            del_invalid_guest_eth "lan" "none"
        fi

    fi
    trap - INT TERM ABRT QUIT ALRM 
    lock -u /var/run/vlan.lock
    
}

switch_guest_clear() {
    
    local vlan_support=$(uci get profile.switch.switch_vlan -c /etc/profile.d)

    lock /var/run/vlan.lock
    trap "" INT TERM ABRT QUIT ALRM 

    if [ "$vlan_support" == "yes" ]; then
        if [ "$section_name" == "switch_vlan" ]; then
            uci -c /etc/vlan.d delete vlan.guest_eth
        fi

        uci commit -c /etc/vlan.d
        swconfig dev $switch_name load /etc/vlan.d/vlan
    fi
    del_invalid_guest_eth "lan" "none"

    trap - INT TERM ABRT QUIT ALRM 
    lock -u /var/run/vlan.lock
}

del_invalid_guest_eth() {
    local network=$1
    local valid_iface=$2
    local wifi_iface
    local ifnames
    local vlan_id
    local eth_vlan_ifaces
    local eth_iface
    local iface
    local tmp_id
    
    config_load wifi
    #config_get ifnames guest ethiface "eth0 eth1"
    config_get vlan_id guest vlan_id
    ifnames="eth0 eth1"
    config_clear


    for iface in $ifnames; do
        #valid_iface: eth0.x or eth1.x
        #eth_vlan_ifaces: eth0.x or eth1.x /  eth0.y or eth0.y

        eth_vlan_ifaces=`ifconfig -a| grep "$iface\." | cut -d ' ' -f1`

        for eth_iface in $eth_vlan_ifaces; do
            #check whether ethiface valid
            [ -d "/sys/class/net/br-$network/brif/$eth_iface" ] && {

                if __is_valid_eth_vlan_interfaces "$valid_iface" "$vlan_id" "$eth_iface"; then  
                    continue;
                else
                    # ethiface not valid, delete

                    tmp_id=`echo $eth_iface | cut -d '.' -f2`
                    guest_echo guest-eth "del eth if id is $tmp_id"

                    if [ "$tmp_id" -ge 3 ] && [ "$tmp_id" -le 1024 ]; then
                        guest_echo guest-eth "del eth if $eth_iface"
                        ifconfig $eth_iface down
                        brctl delif "br-$network" $eth_iface
                        vconfig rem $eth_iface                             
                    fi

                fi

            }
        done

    done
}

__is_valid_eth_vlan_interfaces() {
    local valid_ifaces=$1
    local id=$2
    local iface=$3
    local l_iface

    for l_iface in $valid_ifaces; do
        if [ "$l_iface.$id" = "$iface" ]; then
            return 0
        fi
    done

    return 1
}


add_eth_guest () {
    local ethiface=$1
    local network
    local id
    local interface
    local ifname
    local vlan_support

    config_load wifi
    config_get id guest vlan_id "0" 
    config_clear

    config_load repacd
    config_get network repacd ManagedNetwork 'lan'
    config_clear
    vlan_support=$(uci get profile.switch.switch_vlan -c /etc/profile.d)



    if [ -n "$ethiface" ]; then
        for interface in $ethiface; do
            ifname=`ifconfig 2>&1 | grep "$interface.$id" | cut -d ' ' -f1`
            if [ -z "$ifname" ]; then
                guest_echo guest-eth "add eth if $interface.$id"

                brctl addif "br-$network" "$interface.$id"

                vconfig add $interface $id            
                brctl addif "br-$network" "$interface.$id"
                ifconfig $interface.$id mtu 1500
                ifconfig $interface.$id allmulti
                ifconfig $interface.$id up
            fi
        done
    fi    

}
