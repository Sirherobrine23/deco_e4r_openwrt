# Copyright (C) 2009-2010 OpenWrt.org

MODULE=ipv6_firewall

fw_config_get_rule()
{
        fw_config_get_section "$1" rule { \
                string id          "-1" \
                string name              "" \
                string ip           "" \
                string port                   "" \
                string protocol           "all" \
    } || return
}

get_ifname()
{
        local ifname=""
        local dial_type_v6=$(uci get protocol.wanv6.proto 2>/dev/null)

        case $dial_type_v6 in
                dhcp6c )
                        ifname="br-wan"
                ;;
                6to4 )
                        ifname="6to4-wanv6"
                ;;
                pppoev6 )
                        local dial_type_v4=$(uci get network.wan.wan_type 2>/dev/null)
                        if [ $dial_type_v4 == "pppoeshare" ];then
                                ifname="share-internet"
                        else
                                ifname="pppoev6-wanv6"
                        fi
                ;;
        esac

        echo $ifname
}

fw_load_rule()
{
	fw_config_get_rule $1 rule

	local ifname=$(get_ifname)
	echo "$ifname" > /tmp/ipv6_firewall/ifname

	rule_id=${rule_id}
	rule_ip=${rule_ip}
        rule_port=${rule_port}
	rule_protocol=${rule_protocol}

        [ "$rule_id" == "-1" ] && return

	echo "rule_id:${rule_id}, rule_ip:${rule_ip}, rule_port:${rule_port}, rule_protocol:${rule_protocol}, ifname:$ifname" > /dev/console

        ids=$(uci_get_state ipv6_firewall core ids)
	append ids ${rule_id}
        uci_toggle_state ipv6_firewall core ids "${ids}"

	fw add 6 f ipv6_firewall_${rule_id}
	case $rule_protocol in
		all )
			fw s_add 6 f FORWARD ipv6_firewall_${rule_id} 1 { "-d $rule_ip -i $ifname -p tcp -m tcp --dport $rule_port" }
			fw s_add 6 f FORWARD ipv6_firewall_${rule_id} 1 { "-d $rule_ip -i $ifname -p udp -m udp --dport $rule_port" }
		;;
		tcp )
			fw s_add 6 f FORWARD ipv6_firewall_${rule_id} 1 { "-d $rule_ip -i $ifname -p tcp -m tcp --dport $rule_port" }
		;;
		udp )
			fw s_add 6 f FORWARD ipv6_firewall_${rule_id} 1 { "-d $rule_ip -i $ifname -p udp -m udp --dport $rule_port" }
		;;
	esac

	fw s_add 6 f ipv6_firewall_${rule_id} ACCEPT
}

fw_load_ipv6_firewall()
{
        uci_revert_state ipv6_firewall
        uci_toggle_state ipv6_firewall core "" 1

        config_foreach fw_load_rule rule

        syslog $LOG_INF_FUNCTION_ENABLE
}

fw_exit_ipv6_firewall()
{
        local ifname=$(cat /tmp/ipv6_firewall/ifname 2>/dev/null)

        ids=$(uci_get_state ipv6_firewall core ids)
	for id in $ids
	do
		fw_config_get_rule $id rule
		rule_id=${rule_id}
        	rule_ip=${rule_ip}
        	rule_protocol=${rule_protocol}
        	rule_port=${rule_port}

        	#delete entry
        	case $rule_protocol in
                	all )
                        	fw del 6 f FORWARD ipv6_firewall_${rule_id} { "-d $rule_ip -i $ifname -p tcp -m tcp --dport $rule_port" }
                        	fw del 6 f FORWARD ipv6_firewall_${rule_id} { "-d $rule_ip -i $ifname -p udp -m udp --dport $rule_port" }
                	;;
                	tcp )
                        	fw del 6 f FORWARD ipv6_firewall_${rule_id} { "-d $rule_ip -i $ifname -p tcp -m tcp --dport $rule_port" }
                	;;
                	udp )
                        	fw del 6 f FORWARD ipv6_firewall_${rule_id} { "-d $rule_ip -i $ifname -p udp -m udp --dport $rule_port" }
                	;;
        	esac
		fw flush 6 f ipv6_firewall_${id}
		fw del 6 f ipv6_firewall_${id}
	done

        uci_revert_state ipv6_firewall
        uci_toggle_state ipv6_firewall core "" 0
        syslog $LOG_INF_FUNCTION_ENABLE
}

fw_toggle_rule_info()
{
	local rule_id=$1
	local op_id=$2

	[ "$rule_id" == "$op_id" ] && return

	local ids=$(uci_get_state ipv6_firewall core ids)
	append ids $rule_id
	uci_toggle_state ipv6_firewall core ids "${ids}"
}

fw_reload_ipv6_firewall()
{
	local rule_id=$1
	if [ -z "$rule_id" ];then
		return
	fi

        local ifname=$(get_ifname)

	local rule_ip=$(cat /tmp/ipv6_firewall/rule_ip 2>/dev/null)
	local rule_protocol=$(cat /tmp/ipv6_firewall/rule_protocol 2>/dev/null)
	local rule_port=$(cat /tmp/ipv6_firewall/rule_port 2>/dev/null)

	#delete entry
        case $rule_protocol in
                all )
                        fw del 6 f FORWARD ipv6_firewall_${rule_id} { "-d $rule_ip -i $ifname -p tcp -m tcp --dport $rule_port" }
                        fw del 6 f FORWARD ipv6_firewall_${rule_id} { "-d $rule_ip -i $ifname -p udp -m udp --dport $rule_port" }
                ;;
                tcp )
                        fw del 6 f FORWARD ipv6_firewall_${rule_id} { "-d $rule_ip -i $ifname -p tcp -m tcp --dport $rule_port" }
                ;;
                udp )
                        fw del 6 f FORWARD ipv6_firewall_${rule_id} { "-d $rule_ip -i $ifname -p udp -m udp --dport $rule_port" }
                ;;
        esac
	fw flush 6 f ipv6_firewall_${rule_id}
	fw del 6 f ipv6_firewall_${rule_id}

	#add entry
        uci_revert_state ipv6_firewall
        uci_toggle_state ipv6_firewall core "" 1

	config_foreach fw_toggle_rule_info rule "$rule_id"
	fw_load_rule $rule_id

        ids=$(uci_get_state ipv6_firewall core ids)
	if [ -z "$ids" ];then
        	uci_revert_state ipv6_firewall
        	uci_toggle_state ipv6_firewall core "" 0
	fi
	syslog $LOG_INF_FUNCTION_ENABLE
}
