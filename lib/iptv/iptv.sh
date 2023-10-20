#!/bin/ash

DEBUG_OUTOUT=1

. /lib/network/switch.sh

iptv_echo() {
    if [ "$DEBUG_OUTOUT" -gt 0 ]; then
            echo "${1}: ""$2"> /dev/console
        fi
}

__set_brwan_unisolate()
{
    if [ -d "/sys/class/net/br-wan/brif/eth0" ]; then
        echo 0 > /sys/class/net/br-wan/brif/eth0/isolate_mode
    fi

    if [ -d "/sys/class/net/br-wan/brif/eth1" ]; then
        echo 0 > /sys/class/net/br-wan/brif/eth1/isolate_mode
    fi

    ethtool -K "$iface" gro off

}

mv_iface_bridge() {
    local iface="$1"
    local mode="$2"
    if [ "$mode" = "lan2iptv" ]; then

        is_iface_at_lan=`brctl show br-lan | grep $iface | grep -v $iface.`

        [ -n "$is_iface_at_lan" ] && {
            iptv_echo iptv_shell "move $iface from lan to iptv bridge"
            brctl delif br-lan $iface
            brctl addif br-iptv $iface
        }

    elif [ "$mode" = "iptv2lan" ]; then

        is_iface_at_iptv=`brctl show br-iptv | grep $iface | grep -v $iface.`
        [ -n "$is_iface_at_iptv" ] && {
            iptv_echo iptv_shell "move $iface from iptv to lan bridge"
            brctl delif br-iptv $iface
            brctl addif br-lan $iface
        }
    elif [ "$mode" = "wan2lan" ]; then

        is_iface_at_wan=`brctl show br-wan | grep $iface | grep -v $iface.`
        [ -n "$is_iface_at_wan" ] && {
            iptv_echo iptv_shell "move $iface from wan to lan bridge"
            brctl delif br-wan $iface
            brctl addif br-lan $iface
        }
    elif [ "$mode" = "wan2iptv" ]; then

        is_iface_at_wan=`brctl show br-wan | grep $iface | grep -v $iface.`
        [ -n "$is_iface_at_wan" ] && {
            iptv_echo iptv_shell "move $iface from wan to iptv bridge"
            brctl delif br-wan $iface
            brctl addif br-iptv $iface
        }
    elif [ "$mode" = "lan2wan" ]; then

        is_iface_at_lan=`brctl show br-lan | grep $iface | grep -v $iface.`
        [ -n "$is_iface_at_lan" ] && {
            iptv_echo iptv_shell "move $iface from lan to wan bridge"
            brctl delif br-lan $iface
            brctl addif br-wan $iface
        }
    elif [ "$mode" = "iptv2wan" ]; then

        is_iface_at_iptv=`brctl show br-iptv | grep $iface | grep -v $iface.`
        [ -n "$is_iface_at_iptv" ] && {
            iptv_echo iptv_shell "move $iface from iptv to wan bridge"
            brctl delif br-iptv $iface
            brctl addif br-wan $iface
        }
    fi

}

add_iptv_wan_iface() {
    local iface="$1"
    local iptv_vid="$2"
    local iptv_prio="$3"

    local is_port_exist=$(ifconfig -a | grep "$iface\.$iptv_vid")

    if [ -z "$is_port_exist" ]; then
        __add_iptv_wan_iface $iface $iptv_vid $iptv_prio
    else
        iptv_echo iptv_shell "$iface.$iptv_vid exist, do not add iptv wan iface"
        vconfig set_egress_map "$iface.$iptv_vid" 0 $iptv_prio 
    fi

}
__add_iptv_wan_iface() {
    local iface="$1"
    local iptv_vid="$2"
    local iptv_prio="$3"

    if [ -n "$iptv_vid" -a "$iptv_vid" != "0" ]; then
        iptv_echo iptv_shell "add eth if $iface.$iptv_vid, prio: $iptv_prio"
        vconfig add $iface $iptv_vid            
        vconfig set_egress_map "$iface.$iptv_vid" 0 $iptv_prio 
        brctl addif "br-iptv" "$iface.$iptv_vid"
        ifconfig $iface.$iptv_vid mtu 1500
        ifconfig $iface.$iptv_vid up
    fi
}

delete_invalid_iptv_wan_iface() {
    local valid_iface="$1"
    local iptv_vid="$2"

    local ifnames="eth0 eth1"
    local eth_iface

    for iface in $ifnames; do

        local eth_vlan_ifaces=`ifconfig -a| grep "$iface\." | cut -d ' ' -f1`

        for eth_iface in $eth_vlan_ifaces; do
            #check whether ethiface valid
            # ethiface not valid, delete
            [ -d "/sys/class/net/br-iptv/brif/$eth_iface" ] && {

                [ "$valid_iface.$iptv_vid" = "$eth_iface" ] || {

                    iptv_echo iptv_shell "del eth if $eth_iface"
                    ifconfig $eth_iface down
                    brctl delif "br-iptv" $eth_iface
                    vconfig rem $eth_iface                             

                } 

            }
        done

    done

}

# iptv enable change 0->1 or 1->1
set_iptv_interface() {
    local enable=$1
    local vlan_id=$2
    local vlan_prio=$3
    local mode=$4
    local vlan_support=$(uci get profile.switch.switch_vlan -c /etc/profile.d)

    local is_eth0_at_wan=`brctl show br-wan | grep eth0`
    local is_eth1_at_wan=`brctl show br-wan | grep eth1`

    if [ -z "$is_eth0_at_wan" -a -z "$is_eth1_at_wan" ]; then
        iptv_echo iptv_shell "no interface at br-wan"

    elif [ -z "$is_eth0_at_wan" ]; then
        iptv_echo iptv_shell "eth1 at br-wan"

        delete_invalid_iptv_wan_iface "eth1" "$vlan_id"

        if [ "$mode" = "normal" ]; then
            
            add_iptv_wan_iface "eth1" "$vlan_id" "$vlan_prio"
            mv_iface_bridge "eth0" "lan2iptv"
            
            if [ "$vlan_support" == "yes" ]; then
                local switch_device=$(uci -c /etc/vlan.d get vlan.@switch[0].name)
                uci -c /etc/vlan.d set vlan.iptv="switch_vlan"
                uci -c /etc/vlan.d set vlan.iptv.ports="0t 1 2 3 4t"
                uci -c /etc/vlan.d set vlan.iptv.device="$switch_device"
                uci -c /etc/vlan.d set vlan.iptv.vlan="10"
                uci -c /etc/vlan.d set vlan.iptv.vid=$vlan_id
                uci commit -c /etc/vlan.d
                swconfig dev $switch_device load /etc/vlan.d/vlan
            fi

        elif [ "$mode" = "bridge" ]; then
            mv_iface_bridge "eth0" "lan2wan"
            mv_iface_bridge "eth0" "iptv2wan"

            __set_brwan_unisolate

            if [ "$vlan_support" == "yes" ]; then
                local iptv_vlan_info=$(uci -c /etc/vlan.d get vlan.iptv 2>/dev/null)
                local switch_device=$(uci -c /etc/vlan.d get vlan.@switch[0].name)
                if [ -n "$iptv_vlan_info" ]; then
                    uci -c /etc/vlan.d delete vlan.iptv
                    uci commit -c /etc/vlan.d
                    swconfig dev $switch_device load /etc/vlan.d/vlan
                fi
            fi

        fi

    elif [ -z "$is_eth1_at_wan" ]; then
        iptv_echo iptv_shell "eth0 at br-wan"

        delete_invalid_iptv_wan_iface "eth0" "$vlan_id"

        if [ "$mode" = "normal" ]; then
        
            add_iptv_wan_iface "eth0" "$vlan_id" "$vlan_prio"
            mv_iface_bridge "eth1" "lan2iptv"
            if [ "$vlan_support" == "yes" ]; then
                local switch_device=$(uci -c /etc/vlan.d get vlan.@switch[0].name)
                uci -c /etc/vlan.d set vlan.iptv="switch_vlan"
                uci -c /etc/vlan.d set vlan.iptv.ports="0t 5t"
                uci -c /etc/vlan.d set vlan.iptv.device="$switch_device"
                uci -c /etc/vlan.d set vlan.iptv.vlan="10"
                uci -c /etc/vlan.d set vlan.iptv.vid=$vlan_id

                uci commit -c /etc/vlan.d
                swconfig dev $switch_device load /etc/vlan.d/vlan
            fi
        elif [ "$mode" = "bridge" ]; then

            mv_iface_bridge "eth1" "lan2wan"
            mv_iface_bridge "eth1" "iptv2wan"

            __set_brwan_unisolate

            if [ "$vlan_support" == "yes" ]; then
                local iptv_vlan_info=$(uci -c /etc/vlan.d get vlan.iptv 2>/dev/null)
                local switch_device=$(uci -c /etc/vlan.d get vlan.@switch[0].name)
                if [ -n "$iptv_vlan_info" ]; then
                    uci -c /etc/vlan.d delete vlan.iptv
                    uci commit -c /etc/vlan.d
                    swconfig dev $switch_device load /etc/vlan.d/vlan
                fi
            fi
        fi

    else
        iptv_echo iptv_shell "both eth0 and eth1 at br-wan"
        delete_invalid_iptv_wan_iface "none" "$vlan_id"
        local wanstatus=$(cat /tmp/wanDetection) 

        if [ "$mode" = "normal" ]; then
            if [ "$wanstatus" = "0" ]; then
                local eth0_flag=$(isWan eth0)
                local eth1_flag=$(isWan eth1)
                if [ "$eth0_flag" = "true" ] && [ "$eth1_flag" = "false" ]; then

                    add_iptv_wan_iface "eth0" "$vlan_id" "$vlan_prio"
                    mv_iface_bridge "eth1" "wan2iptv"
                    if [ "$vlan_support" == "yes" ]; then
                        local switch_device=$(uci -c /etc/vlan.d get vlan.@switch[0].name)
                        uci -c /etc/vlan.d set vlan.iptv="switch_vlan"
                        uci -c /etc/vlan.d set vlan.iptv.ports="0t 5t"
                        uci -c /etc/vlan.d set vlan.iptv.device="$switch_device"
                        uci -c /etc/vlan.d set vlan.iptv.vlan="10"
                        uci -c /etc/vlan.d set vlan.iptv.vid=$vlan_id
                        uci commit -c /etc/vlan.d
                        swconfig dev $switch_device load /etc/vlan.d/vlan
                    fi

                elif [ "$eth0_flag" = "false" ] && [ "$eth1_flag" = "true" ]; then
                    add_iptv_wan_iface "eth1" "$vlan_id" "$vlan_prio"
                    mv_iface_bridge "eth0" "wan2iptv"
                    if [ "$vlan_support" == "yes" ]; then
                        local switch_device=$(uci -c /etc/vlan.d get vlan.@switch[0].name)
                        uci -c /etc/vlan.d set vlan.iptv="switch_vlan"
                        uci -c /etc/vlan.d set vlan.iptv.ports="0t 1 2 3 4t"
                        uci -c /etc/vlan.d set vlan.iptv.device="$switch_device"
                        uci -c /etc/vlan.d set vlan.iptv.vlan="10"
                        uci -c /etc/vlan.d set vlan.iptv.vid=$vlan_id
                        uci commit -c /etc/vlan.d
                        swconfig dev $switch_device load /etc/vlan.d/vlan
                    fi
                else
                    if [ "$vlan_support" == "yes" ]; then
                        local iptv_vlan_info=$(uci -c /etc/vlan.d get vlan.iptv 2>/dev/null)
                        local switch_device=$(uci -c /etc/vlan.d get vlan.@switch[0].name)
                        if [ -n "$iptv_vlan_info" ]; then
                            uci -c /etc/vlan.d delete vlan.iptv
                            uci commit -c /etc/vlan.d
                            swconfig dev $switch_device load /etc/vlan.d/vlan
                        fi
                    fi
                fi
            fi
        elif [ "$mode" = "bridge" ]; then
            if [ "$wanstatus" = "0" ]; then
                __set_brwan_unisolate
            fi

            if [ "$vlan_support" == "yes" ]; then
                local iptv_vlan_info=$(uci -c /etc/vlan.d get vlan.iptv 2>/dev/null)
                local switch_device=$(uci -c /etc/vlan.d get vlan.@switch[0].name)
                if [ -n "$iptv_vlan_info" ]; then
                    uci -c /etc/vlan.d delete vlan.iptv
                    uci commit -c /etc/vlan.d
                    swconfig dev $switch_device load /etc/vlan.d/vlan
                fi
            fi
        fi

    fi

}

__clear_iptv() {
    local mode="$1"

    delete_invalid_iptv_wan_iface "none" "0"
    delete_invalid_iptv_wan_iface "none" "0"
    mv_iface_bridge "eth0" "iptv2lan"
    mv_iface_bridge "eth1" "iptv2lan"

    local wanstatus=$(cat /tmp/wanDetection) 
    local is_eth0_at_wan=`brctl show br-wan | grep eth0`
    local is_eth1_at_wan=`brctl show br-wan | grep eth1`
    if [ "$wanstatus" = "0" ]; then
        if [ -n "$is_eth0_at_wan" ] && [ -n "$is_eth1_at_wan" ]; then
            local eth0_flag=$(isWan eth0)
            local eth1_flag=$(isWan eth1)
            if [ "$eth0_flag" = "true" ] && [ "$eth1_flag" = "false" ]; then
                mv_iface_bridge "eth1" "wan2lan"
            elif [ "$eth0_flag" = "false" ] && [ "$eth1_flag" = "true" ]; then
                mv_iface_bridge "eth0" "wan2lan"
            fi
        fi
    fi
}

__setup_iptv() {
    local id=$1
    local prio=$2
    local mode=$3
    if [ -n "$id" ]; then
        set_iptv_interface "1" "$id" "$prio" "$mode"
    else
        iptv_echo iptv_shell "id is null, invaild input in setup_iptv function"
    fi
}

__setup_internet_vlan() {
    local vlan_enable
    local vlan_support

    vlan_support=$(uci get profile.switch.switch_vlan -c /etc/profile.d)
	vlan_enable=$(uci get network.vlan.enable)

    if [ "$vlan_support" == "yes" ]; then
        if [ "$vlan_enable" == "1" ]; then 
            __set_wan_vlan
        elif [ "$vlan_enable" == "0" ]; then 
            __reset_wan_vlan
        fi
    fi

}

clear_iptv() {

    local vlan_support=$(uci get profile.switch.switch_vlan -c /etc/profile.d)


    local mode="$1"
    local br=$(brctl show | grep br-iptv)
    if [ -n "$br" ]; then
        __clear_iptv "$mode"
    fi

    lock /var/run/vlan.lock
    trap "" INT TERM ABRT QUIT ALRM 

    if [ "$vlan_support" == "yes" ]; then
        __setup_internet_vlan
        local iptv_vlan_info=$(uci -c /etc/vlan.d get vlan.iptv 2>/dev/null)
        local switch_device=$(uci -c /etc/vlan.d get vlan.@switch[0].name)
        if [ -n "$iptv_vlan_info" ]; then
            uci -c /etc/vlan.d delete vlan.iptv
            uci commit -c /etc/vlan.d
            swconfig dev $switch_device load /etc/vlan.d/vlan
        fi
    fi

    trap - INT TERM ABRT QUIT ALRM 
    lock -u /var/run/vlan.lock
}

setup_iptv() {
    local id="$1"
    local prio="$2"
    local mode="$3"
    
    lock /var/run/vlan.lock
    trap "" INT TERM ABRT QUIT ALRM 

    __setup_internet_vlan
    if [ "$mode" = "bridge" ]; then
        __setup_iptv "$id" "$prio" "bridge" 
    else
        __setup_iptv "$id" "$prio" "normal" 
    fi

    trap - INT TERM ABRT QUIT ALRM 
    lock -u /var/run/vlan.lock
    
}
