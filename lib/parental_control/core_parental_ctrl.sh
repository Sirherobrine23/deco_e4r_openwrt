# Copyright (C) 2009-2010 OpenWrt.org

MODULE=parental_ctrl

fw_config_load_mac()
{
	config_get mac $1 mac
	config_get id  $1 owner_id
	
	if [ "$id" == "$2" ]; then
		append $3 $mac
	fi
}

fw_config_get_owner()
{
	fw_config_get_section "$1" owner { \
		string owner_id     	 "-1" \
		string name     	 "" \
		string blocked      	 "0" \
		string workday     		 "31" \
		string weekend      	 "96" \
		string workday_limit     "0" \
		string workday_time      "0" \
		string workday_bedtime   "0" \
		string workday_begin     "0" \
		string workday_end       "0" \
		string weekend_limit     "0" \
		string weekend_time      "0" \
		string weekend_bedtime   "0" \
		string weekend_begin     "0" \
		string weekend_end       "0" \
		string website           "" \
		string category           "" \
		string filter_level        "" \
    } || return	
}

fw_load_device_info()
{
	fw add 4 f parental_ctrl_device_info
	fw s_add 4 f FORWARD parental_ctrl_device_info 3 "{" "-i br-lan -p tcp -m tcp --dport 80" "}"
	fw s_add 4 f parental_ctrl_device_info DROP "{" "-m pctl --id 65535" "}"
}

fw_unload_device_info()
{
	fw s_del 4 f FORWARD parental_ctrl_device_info "{" "-i br-lan -p tcp -m tcp --dport 80" "}"
	fw flush 4 f parental_ctrl_device_info
	fw del 4 f parental_ctrl_device_info
}

# set blocking page language
fw_set_block_page_language() 
{
	local language=`uci get system.@system[0].ui_language 2>/dev/null`
	if [ -z "$language" ];then
		language="EN_US"
	fi
	echo $language>/tmp/parental_control/bp_language.conf
	mount --bind /tmp/parental_control/bp_language.conf /www/bp_language.conf

}

#update br-lan ip to pctl kmod
fw_update_br_lan_ip_to_pctl()
{
	local lan_ip=`uci get network.lan.ipaddr 2>/dev/null`
	if [ -z "$lan_ip" ];then
	{
		echo -e "192.168.0.1\c">/proc/pctl/br_lan_ip
	}
	else
	{
		echo -e "${lan_ip}\c">/proc/pctl/br_lan_ip
	}
	fi
}

#time limit should subtract time before reboot
fw_cacl_time_limit() 
{
	local owner=$1
	local limit_time=$2
	time_before_reboot=$(get_day_time_from_file "$owner")
	if [ "$limit_time" -gt "$time_before_reboot" ];then
		let limit_time=${limit_time}-${time_before_reboot}
	else
		limit_time="0"
	fi
	echo $limit_time

}

fw_load_owner()
{
	fw_config_get_owner $1 owner
	
	local owner_mac=""
	local owner_eigen_key=""
	local owner_website_key=""
	owner_name=${owner_name}
    owner_id=${owner_owner_id}
	[ "$owner_id" == "-1" ] && return
	config_foreach fw_config_load_mac client ${owner_id} owner_mac
	
	owner_mac=${owner_mac//-/:}
	owner_mac=$(echo $owner_mac | tr [a-z] [A-Z])
	
	owner_website=`uci show parental_control.$owner_id.website |awk 'BEGIN{FS="="}{print $2}'`
	owner_website=${owner_website//"' '"/,}
	owner_website=${owner_website//"'"/} # because some strings contain spaces, separate then with comma
	owner_category=${owner_category// /,}
    owner_category=$(echo "$owner_category" | tr [A-Z] [a-z])

	# reload pc_insights and update it
	. $PC_LIBDIR/core_get_history.sh
	if [ -n "$owner_id" ] && [ -n "$owner_name" ]
	then
		load_pc_insights "$owner_id" "$owner_name"
	fi

	. $PC_LIBDIR/url_lib.sh
	# echo $owner_category>/dev/console
	owner_category="$(filter_level_set "$owner_filter_level")$owner_category"
	owner_eigen_key=$(get_a_kind_of_url "${owner_category}")
	#echo $owner_eigen_key>/dev/console
	owner_website_url=$(foreach_url_by_eigenvalue "${owner_website}" "url")
	owner_website_key=$(foreach_url_by_eigenvalue "${owner_website}" "key")
	# echo $owner_website_key>/dev/console
	if [ -n "$owner_website_key" ] && [ -n "$owner_eigen_key" ];then
		rept_owner_key="${owner_website_key},${owner_eigen_key}"
	elif [ -n "$owner_eigen_key" ]  && [ -z "$owner_website_key" ];then
		rept_owner_key="${owner_eigen_key}"
	elif [ -z "$owner_eigen_key" ]  && [ -n "$owner_website_key" ];then
		rept_owner_key="${owner_website_key}"
	else
		rept_owner_key=""
	fi

	#echo $owner_id $owner_name $owner_mac
	
	ids=$(uci_get_state parental_control core ids)
	append ids ${owner_id}
	uci_toggle_state parental_control core ids "${ids}"
	
	fw add 4 f parental_ctrl_${owner_id}
	for mac in $owner_mac
	do
		fw s_add 4 f zone_lan_forward parental_ctrl_${owner_id} 1 "{" "-m mac --mac-source $mac" "}"
	done
	
	uci_toggle_state parental_control core id_${owner_id} "${owner_mac}"
	if  [ -z "$owner_website_url" ]
	then
		host_rule=""
	else
		host_rule="--host $owner_website_url"
	fi

	if [ -z "$rept_owner_key" ]; then
		key_rule=""
	else
		owner_key=$(delete_repeat_url "$rept_owner_key")
		key_rule="--key ${owner_key}"
		
	fi
	# set limit time
	local workday_time=""
	local weekend_time=""
	workday_time=$(fw_cacl_time_limit "$owner_id" "${owner_workday_time}")
	weekend_time=$(fw_cacl_time_limit "$owner_id" "${owner_weekend_time}")

    fw s_add 4 f parental_ctrl_${owner_id} DROP "{" "-m pctl --id ${owner_id} \
--blocked ${owner_blocked} \
--workday ${owner_workday} \
--weekend ${owner_weekend} \
--workday_limit ${owner_workday_limit} \
--workday_time ${workday_time} \
--workday_bedtime ${owner_workday_bedtime} \
--workday_begin ${owner_workday_begin} \
--workday_end ${owner_workday_end} \
--weekend_limit ${owner_weekend_limit} \
--weekend_time ${weekend_time} \
--weekend_bedtime ${owner_weekend_bedtime} \
--weekend_begin ${owner_weekend_begin} \
--weekend_end ${owner_weekend_end} \
$key_rule  \
$host_rule" "}"
  
	fw s_add 4 f parental_ctrl_${owner_id} RETURN
	if [ "1" == "${owner_blocked}" ]
	then
		delete_conntrack_by_ip "$owner_mac" 
	fi
}

fw_load_parental_ctrl(){
	uci_revert_state parental_control
	uci_toggle_state parental_control core "" 1

	config_foreach	fw_load_owner owner
	
#	fw_load_device_info
	
	fw_set_block_page_language
	
	fw_update_br_lan_ip_to_pctl

	ids=$(uci_get_state parental_control core ids)
	[ -z "$ids" ] || {
		fw s_add 4 f FORWARD ACCEPT 1 "{" "-o br-lan -m conntrack --ctstate RELATED,ESTABLISHED" "}"		
		fw s_del 4 f FORWARD ACCEPT "{" "-m conntrack --ctstate RELATED,ESTABLISHED" "}"
		echo "1">/proc/sfe_ipv4/pctl_enable
	}
	syslog $LOG_INF_FUNCTION_ENABLE
}

fw_exit_parental_ctrl(){
	ids=$(uci_get_state parental_control core ids)
	[ -z "$ids" ] || {	
		fw s_add 4 f FORWARD ACCEPT 1 "{" "-m conntrack --ctstate RELATED,ESTABLISHED" "}"		
		fw s_del 4 f FORWARD ACCEPT "{" "-o br-lan -m conntrack --ctstate RELATED,ESTABLISHED" "}"
		echo "0">/proc/sfe_ipv4/pctl_enable		
	}
	
	for id in $ids
	do
		macs=$(uci_get_state parental_control core id_${id})
		for mac in $macs
		do
			fw s_del 4 f zone_lan_forward parental_ctrl_${id} "{" "-m mac --mac-source $mac" "}"
		done
		
		fw flush 4 f parental_ctrl_${id}
		fw del 4 f parental_ctrl_${id}
	done
#	fw_unload_device_info
	
	uci_revert_state parental_control
	uci_toggle_state parental_control core "" 0
	syslog $LOG_INF_FUNCTION_DISABLE
}

fw_set_device_owner()
{
	local owner_id=$1
	local owner_mac=""

	config_foreach fw_config_load_mac client ${owner_id} owner_mac
	owner_mac=${owner_mac//-/:}
	owner_mac=$(echo $owner_mac | tr [a-z] [A-Z])

	local last_pctl_chain=""
	for mac in $owner_mac
	do	
		last_pctl_chain=$(iptables -L zone_lan_forward|grep ${mac}|cut -d " "  -f1 2>/dev/null)
		if [ -n "$last_pctl_chain" ] && [ "$last_pctl_chain" != "parental_ctrl_${owner_id}" ];then
			fw s_del 4 f zone_lan_forward ${last_pctl_chain} "{" "-m mac --mac-source $mac" "}"
			fw s_add 4 f zone_lan_forward parental_ctrl_${owner_id} 1 "{" "-m mac --mac-source $mac" "}"
		elif [ -z "$last_pctl_chain" ];then
			fw s_add 4 f zone_lan_forward parental_ctrl_${owner_id} 1 "{" "-m mac --mac-source $mac" "}"
		fi

	done
	uci_toggle_state parental_control core id_${owner_id} "${owner_mac}"
}

fw_toggle_owner_info()
{
	local owner_id=$1
	local op_id=$2

	[ "$owner_id" == "$op_id" ] && return

	local ids=$(uci_get_state parental_control core ids)
	append ids $owner_id
	uci_toggle_state parental_control core ids "${ids}"

	fw_set_device_owner "$owner_id"
}


fw_reload_parental_ctrl(){
	local owner_id=$1
	#only set device owner by mac
	if [ -z "$owner_id" ];then
		config_foreach fw_set_device_owner owner
		return
	fi
	#delete entry
	local ids=""
	ids=$(uci_get_state parental_control core ids)
	[ -z "$ids" ] || {	
		fw s_add 4 f FORWARD ACCEPT 1 "{" "-m conntrack --ctstate RELATED,ESTABLISHED" "}"
		fw s_del 4 f FORWARD ACCEPT "{" "-o br-lan -m conntrack --ctstate RELATED,ESTABLISHED" "}"
		echo "0">/proc/sfe_ipv4/pctl_enable		
	}
	
	macs=$(uci_get_state parental_control core id_${owner_id})
	for mac in $macs
	do
		fw s_del 4 f zone_lan_forward parental_ctrl_${owner_id} "{" "-m mac --mac-source $mac" "}"
	done
	
	fw flush 4 f parental_ctrl_${owner_id}
	fw del 4 f parental_ctrl_${owner_id}

	#add entry
	uci_revert_state parental_control
	uci_toggle_state parental_control core "" 1
	config_foreach fw_toggle_owner_info  owner "$owner_id"
	fw_load_owner $owner_id

	ids=$(uci_get_state parental_control core ids)
	if [ -z "$ids" ];then
		uci_revert_state parental_control
		uci_toggle_state parental_control core "" 0
		return
	else
		fw s_add 4 f FORWARD ACCEPT 1 "{" "-o br-lan -m conntrack --ctstate RELATED,ESTABLISHED" "}"	
		fw s_del 4 f FORWARD ACCEPT "{" "-m conntrack --ctstate RELATED,ESTABLISHED" "}"
		echo "1">/proc/sfe_ipv4/pctl_enable
	fi

	fw_set_block_page_language
	fw_update_br_lan_ip_to_pctl
	syslog $LOG_INF_FUNCTION_ENABLE
}