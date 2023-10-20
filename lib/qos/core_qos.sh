# Copyright (C) 2014-2015 TP-link
. /lib/config/uci.sh

tc_d(){
    echo "tc $@" > /dev/console
    tc $@
}

crontab_cmd="\* \* \* \* \* \/sbin\/qos_check"
QOS_PROC_PATH="/proc/sfe_ipv4/qos_enable"
uci_p="uci -c /etc/profile.d/"

fw_config_get_global(){
    fw_config_get_section "$1" global { \
        string enable           "off" \
        string up_band          "" \
        string down_band        "" \
        string high             "90" \
        string low              "10" \
        string percent          "100" \
        string up_unit          "mbps" \
        string down_unit        "mbps" \
        string rUpband          "260000" \
        string rDownband        "260000" \
    } || return   
}

fw_config_get_client(){
    fw_config_get_section "$1" client { \
        string mac              "" \
        string prio             "off" \
        string prio_time        "" \
        string time_period      "" \
    } || return
}

fw_load_qos(){
    if [[ x"$(uci_get_state qos_v2 core)" != x"qos_v2" ]]; then
        uci_set_state qos_v2 core "" qos_v2
    fi
    
    fw_config_once fw_load_global global 
}

# start hnat
fw_hnat_start()
{
	
    wanDetect=`cat /tmp/wanDetection 2>/dev/null`
    if [ "$wanDetect" == "0" ] && [ -f "/usr/sbin/qca-hnat" ]; then
        /usr/sbin/qca-hnat start
        sh /usr/lib/wanDetect/cp_dir.sh /tmp/qca_switch/ /proc/qca_switch/
        sleep 2
    fi
}

# stop hnat and clear qca header
fw_hnat_stop()
{
                        
    [ -f "/usr/sbin/qca-hnat" ]&& {
        /usr/sbin/qca-hnat stop
        ssdk_sh debug reg set 0x620 0x4f0 4
        ssdk_sh debug reg set 0x9c 0x0 4
    }
   
}

fw_rule_exit(){

    fw flush 4 m zone_lan_qos
    fw flush 4 m zone_wan_qos

    fw flush 4 m qos_lan_rule

    fw flush 4 m qos_lan_HIGH
    fw flush 4 m qos_lan_LOW

    fw flush 4 m qos_wan_HIGH
    fw flush 4 m qos_wan_LOW

    fw del 4 m qos_lan_rule

    fw del 4 m qos_lan_HIGH
    fw del 4 m qos_lan_LOW

    fw del 4 m qos_wan_HIGH
    fw del 4 m qos_wan_LOW
}

fw_rule_load() {

    
    fw add 4 m qos_lan_HIGH
    fw add 4 m qos_lan_LOW
    fw add 4 m qos_lan_rule

    fw add 4 m qos_wan_HIGH
    fw add 4 m qos_wan_LOW

    local lan_target="MARK --set-xmark 0x1101/0xffff"
    local conn_target="CONNMARK --set-xmark 0x1101/0xffff"
    local wan_target="MARK --set-xmark 0x2101/0xffff"

    fw s_add 4 m qos_lan_HIGH "$lan_target"
    fw s_add 4 m qos_lan_HIGH "$conn_target"
    fw s_add 4 m qos_lan_HIGH ACCEPT
    fw s_add 4 m qos_wan_HIGH "$wan_target"
    fw s_add 4 m qos_wan_HIGH ACCEPT

    lan_target="MARK --set-xmark 0x1103/0xffff"
    conn_target="CONNMARK --set-xmark 0x1103/0xffff"
    wan_target="MARK --set-xmark 0x2103/0xffff"

    fw s_add 4 m qos_lan_LOW "$lan_target"
    fw s_add 4 m qos_lan_LOW "$conn_target"
    fw s_add 4 m qos_lan_LOW ACCEPT
    fw s_add 4 m qos_wan_LOW "$wan_target"
    fw s_add 4 m qos_wan_LOW ACCEPT

    # wan rules, low is default
    fw s_add 4 m zone_wan_qos qos_wan_HIGH { "-m connmark --mark 0x1101/0xffff" }
    fw s_add 4 m zone_wan_qos qos_wan_LOW { "-m connmark --mark 0x1103/0xffff" }

    # lan rules, to avoid second match
    fw s_add 4 m zone_lan_qos qos_lan_HIGH { "-m connmark --mark 0x1101/0xffff" }
    fw s_add 4 m zone_lan_qos qos_lan_LOW { "-m connmark --mark 0x1103/0xffff" }
    fw s_add 4 m zone_lan_qos qos_lan_rule

    # default qos
    fw s_add 4 m zone_lan_qos qos_lan_LOW
    fw s_add 4 m zone_wan_qos qos_wan_LOW
}

fw_exit_qos(){
    if [[ x"$(uci_get_state qos_v2 core)" != x"qos_v2" ]]; then
        uci_set_state qos_v2 core "" qos_v2
    fi
    sed -i "/^${crontab_cmd}/d" /etc/crontabs/root 

    if [[ x"$(uci_get_state qos_v2 core loaded)" == x1 ]]; then
        fw_rule_exit
        fw_tc_stop

        uci_revert_state qos_v2 core loaded
		uci_revert_state qos_v2 core check_time
        uci_set_state qos_v2 core loaded 0
    fi
}

fw_load_global() {

    fw_config_get_global "$1"

    if [[ x"$(uci_get_state qos_v2 core loaded)" != x1 ]]; then
        if [[ "$global_enable" == "on" ]]; then
            syslog $LOG_INF_FUNCTION_ENABLE

            if [[ -n "$global_up_band" -a -n "$global_down_band" ]]; then
                fw_rule_load
                uci_revert_state qos_v2 core check_time
                config_foreach fw_load_client client
                
                local macs=$(uci_get_state qos_v2 core check_time)
                if [ -n "$macs" ]; then
    
                    sed -i "/^${crontab_cmd}/d" /etc/crontabs/root 
                    echo "* * * * * /sbin/qos_check" >> /etc/crontabs/root 
                    /etc/init.d/cron restart &
                    
                    macs=$(echo ${macs}|tr ":" "-")
                    echo "1 ${macs}" > $QOS_PROC_PATH
                    fw_tc_start
                    fw_hnat_stop

                fi
            fi
            # fw_rule_load

            uci_revert_state qos_v2 core loaded
            uci_set_state qos_v2 core loaded 1
        else
            syslog $LOG_INF_FUNCTION_DISABLE
            uci_revert_state qos_v2 core loaded
			uci_revert_state qos_v2 core check_time
            uci_set_state qos_v2 core loaded 0
        fi
    fi    
}

fw_tc_lan_setup()
{
    lan_ifname=$1
    # downlink
    tc_d qdisc add dev $lan_ifname root handle 2: htb default 2100
    tc_d class add dev $lan_ifname parent 2: classid 2:2 htb rate "$downlink" ceil "$downlink" $down_burst quantum 1500
    tc_d class add dev $lan_ifname parent 2: classid 2:2100 htb rate 1000000kbit ceil 1000000kbit $down_iface_burst quantum 1500 prio 3
    tc_d qdisc add dev $lan_ifname parent 2:2100 handle 2100: sfq perturb 10

    tc_d class add dev $lan_ifname parent 2:2 classid 2:2101 htb rate "$down_high" ceil "$downlink" $d_hi_burst quantum 1500 prio 0
    tc_d qdisc add dev $lan_ifname parent 2:2101 handle 2101: sfq perturb 10

    tc_d class add dev $lan_ifname parent 2:2 classid 2:2103 htb rate "$down_low" ceil "$downlink" $d_lo_burst quantum 1500 prio 2
    tc_d qdisc add dev $lan_ifname parent 2:2103 handle 2103: sfq perturb 10

    # filter
    tc_d filter add dev $lan_ifname parent 2:0 protocol all handle 0x2101/0xffff fw classid 2:2101
    tc_d filter add dev $lan_ifname parent 2:0 protocol all handle 0x2103/0xffff fw classid 2:2103
}

fw_tc_wan_setup()
{
    wan_ifname=$1
    # uplink
    tc_d qdisc add dev $wan_ifname root handle 1: htb default 1100
    tc_d class add dev $wan_ifname parent 1: classid 1:1 htb rate "$uplink" ceil "$uplink" $up_burst quantum 1500
    tc_d class add dev $wan_ifname parent 1: classid 1:1100 htb rate 1000000kbit ceil 1000000kbit $up_iface_burst quantum 1500 prio 3
    tc_d qdisc add dev $wan_ifname parent 1:1100 handle 1100: sfq perturb 10

    tc_d class add dev $wan_ifname parent 1:1 classid 1:1101 htb rate "$up_high" ceil "$uplink" $u_hi_burst quantum 1500 prio 0
    tc_d qdisc add dev $wan_ifname parent 1:1101 handle 1101: sfq perturb 10

    tc_d class add dev $wan_ifname parent 1:1 classid 1:1103 htb rate "$up_low" ceil "$uplink" $u_lo_burst quantum 1500 prio 2
    tc_d qdisc add dev $wan_ifname parent 1:1103 handle 1103: sfq perturb 10

    # filter
    tc_d filter add dev $wan_ifname parent 1:0 protocol all handle 0x1101/0xffff fw classid 1:1101
    tc_d filter add dev $wan_ifname parent 1:0 protocol all handle 0x1103/0xffff fw classid 1:1103
}

fw_tc_start() {
   
    # modules

    local all_percent=$((${global_high}+${global_low}))
    global_high=$((${global_high}*100/${all_percent}))
    global_low=$((${global_low}*100/${all_percent}))

    #get port speed
    local portWan_speed=$(get_port_speed "wan")
    if [ "$portWan_speed" == "100" ]
    then
        global_rUpband="92000"
        global_rDownband="92000"
    fi    

    # paras
    if test "$global_up_band" -ge "$global_rUpband" 
    then
        global_up_band=$((global_rUpband))
    fi
    if [[ "$global_up_unit" == "mbps" ]]; then
        global_up_band=$((global_up_band*1000))
    fi
    local uplink=$((${global_percent}*${global_up_band}/100))
    
    if test "$global_down_band" -ge "$global_rDownband" 
    then
        global_down_band=$((global_rDownband))
    fi
    if [[ "$global_down_unit" == "mbps" ]]; then
        global_down_band=$((global_down_band*1000))
    fi
    local downlink=$((${global_percent}*${global_down_band}/100))
    

    local up_high=$((${global_high}*${uplink}/100))
    local up_low=$((${global_low}*${uplink}/100))

    local down_high=$((${global_high}*${downlink}/100))
    local down_low=$((${global_low}*${downlink}/100))

    # Calculate the burst and cburst parameters for HTB 
    # Added by Jason Guo<guodongxian@tp-link.net>, 20140729 
    local hz=$(cat /proc/net/psched|awk -F ' ' '{print $4}')
    local up_iface_burst down_iface_burst
    local up_burst u_hi_burst u_lo_burst
    local down_burst d_hi_burst d_lo_burst 
    [ "$hz" == "3b9aca00" ] && {
        burst__calc() {
            local b=$((${1} * 1000 / 8 / 100))
            b=$((${b} + 1600))
            echo "$b"
        }
        # Uplink, unit bit
        up_burst=$(burst__calc $uplink)
        u_hi_burst=$(burst__calc $up_high)
        u_lo_burst=$(burst__calc $up_low)

        # Downlink, unit bit
        down_burst=$(burst__calc $downlink)
        d_hi_burst=$(burst__calc $down_high)
        d_lo_burst=$(burst__calc $down_low)

        up_iface_burst=$(burst__calc 1000000)
        down_iface_burst=$(burst__calc 1000000)
        param__convert() {
            local p=
            [ -n "$1" -a -n "$2" ] && {
                p="burst $1 cburst $2"
            }
            echo "$p"        
        }
        
        u_hi_burst=$(param__convert $u_hi_burst $up_burst)
        u_lo_burst=$(param__convert $u_lo_burst $up_burst)
        up_burst=$(param__convert $up_burst $up_burst)

        d_hi_burst=$(param__convert $d_hi_burst $down_burst)
        d_lo_burst=$(param__convert $d_lo_burst $down_burst)
        down_burst=$(param__convert $down_burst $down_burst)

        up_iface_burst=$(param__convert $up_iface_burst $up_iface_burst)
        down_iface_burst=$(param__convert $down_iface_burst $down_iface_burst)
    }
    uplink="$uplink""kbit"
    downlink="$downlink""kbit"

    up_high="$up_high""kbit"
    up_low="$up_low""kbit"

    down_high="$down_high""kbit"
    down_low="$down_low""kbit"

    #local ifaces="mobile wan"
	local ifaces=""
    local wan_ifname=""

    ifaces="internet wan"
    for i in $ifaces; do
        if [ "$i" == "internet" ]; then
            wan_ifname=$(uci get network.$i.wan_type)
            if [ "l2tp" == "$wan_ifname" ]; then
            {
                wan_ifname="${wan_ifname}-${i}"
            }
            else
            {
                wan_ifname=""
            }
            fi
        else
            wan_ifname=$(uci get network.$i.ifname)
        fi
        [ -z $wan_ifname ] && {
            continue
        }
       fw_tc_wan_setup $wan_ifname
    done

    fw_tc_lan_setup "br-lan"
}

fw_tc_stop(){
    #local ifaces="mobile wan"
	local ifaces=""
    local wan_ifname=""  
    
    ifaces="internet wan"  
    for i in $ifaces; do
        if [ "$i" == "internet" ]; then
            wan_ifname=$(uci get network.$i.wan_type)
            if [ "l2tp" == "$wan_ifname" ]; then
            {
                wan_ifname="${wan_ifname}-${i}"
            }
            else
            {
                wan_ifname=""
            }
            fi
        else
            wan_ifname=$(uci get network.$i.ifname)
        fi
        [ -z $wan_ifname ] && {
            continue
        }
        tc_d qdisc del dev "$wan_ifname" root
    done

    tc_d qdisc del dev br-lan root
}

fw_rule_reload() {
    echo "do nothing">/dev/console
}

fw_load_client() {
    fw_config_get_client "$1"
	#echo "client_mac=$client_mac client_prio=$client_prio" > /dev/console
	
	local client_mac=${client_mac//-/:}
	client_mac=$(echo $client_mac | tr [a-z] [A-Z])
	
	local lan_target
	if [ "$client_prio" == "on" ]; then
		now=`date '+%s'`
		if [ "$client_prio_time" == "-1" -o "$now" -lt "$client_prio_time" ]; then
            fw s_add 4 m qos_lan_rule qos_lan_HIGH { "-m mac --mac-source $client_mac" }
			macs=$(uci_get_state qos_v2 core check_time)
			append macs ${client_mac}
			uci_toggle_state qos_v2 core check_time "${macs}"
		fi
	fi
}

fw_check_client_is_online() {
    local macs=$1
    local ONLINE_DEV_PATH="/tmp/online_devlist"
    local qos_enable=`cat ${QOS_PROC_PATH}|head -1`
	local is_online=false

    [ -z "$macs" ]&&{
        return true
    } 
    for mac in $macs
	do
        mac=${mac//:/-}
        res=`cat ${ONLINE_DEV_PATH}|grep -i ${mac}`
        if [ -n "$res" ]; then
            is_online=true
        fi
    done
    
    if [ "$qos_enable" == "0" ] && [ "$is_online" == true ]; then
        fw_config_get_global "settings"
        fw_tc_start
        fw_hnat_stop   
        echo "1 ${macs//:/-}">$QOS_PROC_PATH
    elif [ "$qos_enable" == "1" ] && [ "$is_online" == false ]; then
        fw_tc_stop
        fw_hnat_start
        echo "0">$QOS_PROC_PATH
    elif [ "$qos_enable" == "0" ] && [ "$is_online" == false ]; then
        return 0
    fi
    return 1
}

fw_check_clients() {
	local old_macs=$(uci_get_state qos_v2 core check_time)
	local new_macs

	local now=`date '+%s'`
    local is_online=$(fw_check_client_is_online "$old_macs")
    [ "$is_online" == "0" ] && return
	for mac in $old_macs
	do
		key=${mac//:/}
		fw_config_get_client $key
		
		#echo $key "$client_mac" "$now" "$client_prio_time" > /dev/console
		if [ "$client_prio_time" == "-1" ];then
            append new_macs $mac 
        else
            if [ "$now" -gt "$client_prio_time" ]; then
                fw s_del 4 m qos_lan_rule qos_lan_HIGH { "-m mac --mac-source $mac" }
                echo "dev:${mac} high prio timeout">/dev/console
            else
                append new_macs $mac 
            fi
        fi
	done
	
	if [ "${new_macs}" != "${old_macs}" ];then
		
        uci_toggle_state qos_v2 core check_time "${new_macs}"
        
        # write proc file
        new_macs=$(echo ${new_macs}|tr ":" "-")
        [ -n "${new_macs}" ] && echo "1 ${new_macs}">$QOS_PROC_PATH

	fi
	
	if [ -z "${new_macs}" ];then
		uci_revert_state qos_v2 core check_time
		sed -i "/^${crontab_cmd}/d" /etc/crontabs/root 
		/etc/init.d/cron restart &
        uci set qos_v2.settings.enable="off"
        uci commit qos_v2
        /etc/init.d/qos restart    
    fi
}

get_cpu_rgmii_type()
{
    local interface=`$uci_p get interfaces.@interface[0].name 2>/dev/null`
    if [ -n "$interface" ]
    then
        res=`echo $interface|grep "\."` 
        if [ -n "$res" ]
        then
            echo "single"
        else 
            echo "double"
        fi
    fi
    return
}

get_single_rgmii_port_speed()
{

    local port_name="$1"
    local port_phy1
    local port_phy2
    local portWan_vid=`brctl show br-wan|tail -1|awk '{print $4}'|cut -d "." -f2`
    local port_speed="1000"
    local portWan_id=""
    local portLan_id=""
    local port_switch1=""
    local port_switch2=""

    port_phy1=$($uci_p get profile.switch.phy_port_1 2>/dev/null)
    port_phy2=$($uci_p get profile.switch.phy_port_2 2>/dev/null)

    if [ -z "$port_phy1" ] || [ -z "$port_phy2" ]
    then
        echo $port_speed
        return
    fi

    let port_switch1=1+$port_phy1
    let port_switch2=1+$port_phy2

    for i in `seq 1 2`
    do
        vid=`swconfig dev eth0 vlan $i show|grep vid|cut -d " " -f2`
        if [ "$vid" == "$portWan_vid" ] 
        then
            res=`swconfig dev eth0 vlan $i show|grep ports|grep $port_switch1`
            if [ -n "$res" ] 
            then
                portWan_id="$port_switch1"
                portLan_id="$port_switch2"
            else
                portWan_id="$port_switch2"
                portLan_id="$port_switch1"
            fi
            break
        fi
    done
    echo "====portWan=${portWan_id} portLan=${portLan_id} wan_vid=${portWan_vid}">>/dev/console

    if [ -n "$portWan_id" ]
    then
        if [ "$port_name" == "wan" ]
        then
            port_speed=`ssdk_sh port speed get ${portWan_id}|grep speed|cut -d ":" -f 2`
        elif [ "$port_name" == "lan" ]
        then
            port_speed=`ssdk_sh port speed get ${portLan_id}|grep speed|cut -d ":" -f 2`
        fi            
    fi
    echo "${port_speed%%(*}"
}

get_double_rgmii_port_speed()
{
    local port_name="$1"
    local interface_name1=`$uci_p get interfaces.@interface[0].name 2>/dev/null`
    local interface_name2=`$uci_p get interfaces.@interface[1].name 2>/dev/null`
    local port_phy1=`$uci_p get interfaces.@interface[0].phy_port_1 2>/dev/null`
    local port_phy2=`$uci_p get interfaces.@interface[1].phy_port_2 2>/dev/null`
    local port_switch1=""
    local port_switch2=""
    local port_speed="100"

    if [ -z "$port_phy1" ] || [ -z "$port_phy2" ]
    then
        echo $port_speed
        return
    fi
        
    let port_switch1=1+$port_phy1
    let port_switch2=1+$port_phy2
    
    port1_speed=`ssdk_sh port speed get ${port_switch1}|grep speed|cut -d ":" -f 2`
    port2_speed=`ssdk_sh port speed get ${port_switch2}|grep speed|cut -d ":" -f 2`
    echo "=====port 1 speed=${port1_speed}===port 2 speed=${port2_speed}">>/dev/console
    local portWan=`brctl show br-wan|tail -1|awk '{print $4}'`

    if [ "$portWan" == "$interface_name1" ] && [ "$port_name" == "wan" ]
    then
        port_speed=$port1_speed
    elif [ "$portWan" == "$interface_name1" ]&& [ "$port_name" == "lan" ]
    then
        port_speed=$port2_speed
    elif [ "$portWan" == "$interface_name2" ]&& [ "$port_name" == "wan" ]
    then
        port_speed=$port2_speed
    elif [ "$portWan" == "$interface_name2" ]&& [ "$port_name" == "lan" ]
    then
        port_speed=$port1_speed
    fi
    echo "${port_speed%%(*}"
}

get_port_speed()
{
    local RGMII_TYPE=$(get_cpu_rgmii_type)
    local ret="1000"

    case "$RGMII_TYPE" in
    "single")
        ret=$(get_single_rgmii_port_speed "$1")
    ;;
    "double")
        ret=$(get_double_rgmii_port_speed "$1")
    ;;
    esac
    echo "$ret"
}
