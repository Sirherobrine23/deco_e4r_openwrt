#!/bin/sh
DLOGIN_HOST_PATH=/etc/hosts
DLOGIN_ALIAS_PATH=/etc/dnsmasq.conf

DLOGIN_LAN_IFACE=lan
DLOGIN_LIB_PATH=/lib/domain_login

DLOGIN_MOD_NAME=domain_login
DLOGIN_MANGLE_CHAIN=domain_login_rule

DLOGIN_DEFAULT_ALIAS="tplinkdeco.net"
. /lib/functions/network.sh

FAP_IP_FILE=/tmp/fap_ip

DEBUG_OUTOUT=1
DEBUG_LEVEL=5
DEBUG_PRINT_COM=1

dlogin_echo() {
    if [ "$DEBUG_OUTOUT" -gt 0 ]; then
            logger -p $DEBUG_LEVEL "$1 $2"
    fi

    if [ "$DEBUG_PRINT_COM" -gt 0 ]; then
            echo "$1 $2" > /dev/console
    fi
}

dlogin_dnsmasq_restart()
{
    killall dnsmasq
    eval "/etc/init.d/dnsmasq start"
}

dlogin_iface_event()
{
    local iface=$1
    local _tp_domain
    local _ipaddr
    local _alias
    
    [ "$iface" != "$DLOGIN_LAN_IFACE" ] && return

    config_load domain_login
    #config_get _tp_domain "tp_domain" domain
    _tp_domain=$(uci get profile.@domain_login[0].domain -c /etc/profile.d)
    #echo "_tp_domain : $_tp_domain" > /dev/console

    network_flush_cache
    network_get_ipaddr _ipaddr "$DLOGIN_LAN_IFACE"

    [ -z "$_ipaddr" -o "$_ipaddr" = "0.0.0.0" ] && {
        config_get _ipaddr "tp_domain" new_addr
    }

    local _domains=
    append _domains $_tp_domain
    config_get _alias "tp_domain" alias
    sed -i "/$_tp_domain/d" $DLOGIN_ALIAS_PATH
    [ -n "$_alias" ] && {
        for cname in $_alias; do
            if [ "$cname" == "tplinklogin.net" ]; then
                cname=$DLOGIN_DEFAULT_ALIAS
            fi
            
            local tmp="cname=$cname,$_tp_domain"
            sed -i "$ a\\$tmp" $DLOGIN_ALIAS_PATH
            append _domains $cname
        done
    }

    # Install the domain-dns for dut login by domain
    local dns_mod=$(lsmod|grep -o "domain_dns")
    [ -n "$dns_mod" ] && rmmod domain_dns
    config_get _def_domain "tp_domain" default_domain
    [ -z $_def_domain ] && _def_domain="default_domain"
    #workmode: 0--router,1--ap; 
    config_get workmode "tp_domain" workmode
    [ -z $workmode ] && workmode=0
    
    local sysmode=$(uci get sysmode.sysmode.mode)
    if [ "$sysmode" == "AP" ]; then
        [ -n "$2" ] && {
            _ipaddr=$2
        }
        workmode=1
    fi

    # echo "_tp_domain: _ipaddr:$_ipaddr" > /dev/console
    local old
    local new
    old=$(grep -m 1 "$_tp_domain" $DLOGIN_HOST_PATH)
    new="$_ipaddr $_tp_domain"

    if [ -n "$old" ]; then
        sed -i "s/$old/$new/g" $DLOGIN_HOST_PATH
    else
        sed -i "$ a\\$new" $DLOGIN_HOST_PATH
    fi

    config_get old_mask "tp_domain" old_mask
    [ -z $old_mask ] && old_mask="255.255.255.0"
    #echo "_tp_domain : _ipaddr:$_ipaddr dut_domain:$_domains mode:$workmode" > /dev/console
    # insmod domain_dns lan_ip=$_ipaddr dut_domain="\"$_domains\"" ignore_me=1 default_domain="\"$_def_domain\"" mode=$workmode
    # insmod domain_dns lan_ip=$_ipaddr dut_domain="\"$_domains\"" ignore_me=1  mode=$workmode mask=$old_mask
    # insmod domain_dns lan_ip=$_ipaddr dut_domain="\"$_domains\"" ignore_me=0  mode=$workmode mask=$old_mask
    insmod domain_dns lan_ip=$_ipaddr dut_domain="\"$_tp_domain\"" ignore_me=0  mode=$workmode mask=$old_mask discover_domain="\"_alexa._tcp.local deco._alexa._tcp.local\""
    #dlogin_dnsmasq_restart

    if [ -f $FAP_IP_FILE ]; then
        tmp_fapip=$(cat $FAP_IP_FILE) 
        echo -n "$tmp_fapip" > /proc/domain_dns_fapip  
    fi

    return
}

dlogin_tip_install()
{
    local old_addr="$1"
    local old_mask="$2"
    local domain="$3"

    [ -z "$old_addr" -o -z "$old_mask" -o -z "$domain" ] && return

    local mod=$(lsmod | grep -o "domain_tip")
    [ -n "$mod" ] && {
        rmmod domain_tip
    }

    local mangle_rule=$(fw list 4 m | grep "$DLOGIN_MANGLE_CHAIN")
    [ -z "$mangle_rule" ] && {
        fw add 4 m "$DLOGIN_MANGLE_CHAIN"
        fw add 4 m PREROUTING "$DLOGIN_MANGLE_CHAIN"
    }

    # Create the firewall rules for NSS(conntrack not passthrough by NSS)
    fw flush 4 m "$DLOGIN_MANGLE_CHAIN"
    fw add 4 m "$DLOGIN_MANGLE_CHAIN" MARK { -d $old_addr -p tcp -m tcp --dport 80 --set-xmark 0xdead0000/0xffff0000 }
    # Install tip of domain kernel module 
    insmod domain_tip conflict_ip=$old_addr conflict_mask=$old_mask tp_domain="\"$domain\""
    
    return
}

dlogin_ip_conflict()
{
    local old_addr="$1"
    local old_mask="$2"
    local new_addr="$3"
    local new_mask="$4"

    [ -z "$old_addr" -o -z "$new_addr" ] && return

    # chmod 777 $DLOGIN_LIB_PATH/domain_login_config.lua

    #lua $DLOGIN_LIB_PATH/domain_login_config.lua $DLOGIN_MOD_NAME tp_domain conflict on
    #lua $DLOGIN_LIB_PATH/domain_login_config.lua $DLOGIN_MOD_NAME tp_domain new_addr $new_addr
    #lua $DLOGIN_LIB_PATH/domain_login_config.lua $DLOGIN_MOD_NAME tp_domain old_addr $old_addr
    #lua $DLOGIN_LIB_PATH/domain_login_config.lua $DLOGIN_MOD_NAME tp_domain old_mask $old_mask

    config_load domain_login
    local _tp_domain
    #config_get _tp_domain "tp_domain" domain
    _tp_domain=$(uci get profile.@domain_login[0].domain -c /etc/profile.d)
    #echo "111_tp_domain : $_tp_domain" > /dev/console

    dlogin_syslog 21

    dlogin_tip_install $old_addr $old_mask "$_tp_domain"

    return
}

dlogin_redirect()
{
    local rdr=
    [ -e /proc/domain_login_dns ] && {
        rdr=$(cat /proc/domain_login_dns)
    }
    echo "$rdr"
}

dlogin_tips_mode()
{
    local mode=
    if [ -e /proc/domain_login ]; then
        local suc=$(cat /proc/domain_login | grep "success")
        if [ -n "$suc" ]
        then
            mode="1"
        else
            mode="0"
        fi
    else
        mode="0"
    fi

    echo "$mode"
}

dlogin_dst_addr()
{
    local _ipaddr
    network_get_ipaddr _ipaddr "$DLOGIN_LAN_IFACE"
    local dst=
    if [ -e /proc/domain_login ]; then
	local ipaddr=$(cat /proc/domain_login | cut -d " " -f1)
        if [ -n "$ipaddr" -a "$ipaddr" != "0.0.0.0" ]; then
            dst="$ipaddr"
        else
            # dst="0.0.0.0"
            dst="$_ipaddr"
        fi
    else
        # dst="0.0.0.0"
        dst="$_ipaddr"
    fi
    
    echo "$dst"
}

dlogin_dst_web_path()
{
    local wpath=
    if [ -e /proc/domain_login ]; then
	local wp=$(cat /proc/domain_login | cut -d " " -f2)
        wpath=${wp:-"/"}
    else
        wpath="/"
    fi

    echo "$wpath"
}

dlogin_conflict_cancel()
{
    # chmod 777 $DLOGIN_LIB_PATH/domain_login_config.lua
    lua $DLOGIN_LIB_PATH/domain_login_config.lua set $DLOGIN_MOD_NAME tp_domain conflict off
    lua $DLOGIN_LIB_PATH/domain_login_config.lua commit $DLOGIN_MOD_NAME tp_domain conflict off

    fw flush 4 m "$DLOGIN_MANGLE_CHAIN"
    fw del 4 m PREROUTING "$DLOGIN_MANGLE_CHAIN"
    fw del 4 m "$DLOGIN_MANGLE_CHAIN"    

    rmmod domain_tip
    
    dlogin_syslog 22
}


dlogin_iface_event_cancel()
{
    
    rmmod domain_dns
    
    dlogin_syslog 22
}

