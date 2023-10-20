#!/bin/sh
#
#
#

WIFIMON_STATE_RE_NOT_ASSOCIATED='RE_NotAssociated'
WIFIMON_STATE_RE_MEASURING='RE_Measuring'
WIFIMON_STATE_RE_MOVE_CLOSER='RE_MoveCloser'
WIFIMON_STATE_RE_LOCATION_SUITABLE='RE_LocationSuitable'
WIFIMON_STATE_AP_UP='AP_Up'
WIFIMON_STATE_AP_DOWN='AP_Down'

DEBUG_ENABLE=0

. /lib/functions.sh
. /lib/functions/whc-network.sh

local sta_iface_24g sta_iface_5g
local ap_iface_24g ap_iface_5g
local rssi_2g_num=0 rssi_5g_num=0
local rssi_samples=0 configed_rssi_samples=0
local rssi_far_star_2g=0 rssi_far_daisy_2g=0 rssi_far_star_5g=0 rssi_far_daisy_5g=0
local cur_mode cur_re_submode new_mode new_re_submode
local link_check_delay
local last_ping_gw_ip ping_fail_count=0 ping_fail_threshold=0
local gw_reachable=0 last_gw_reachable_status=2
local boost_flag=0 last_boost_flag=0
local con_suittofar_threshold=0 con_suittofar_count=0
local last_set_status
local associated_24g associated_5g

__wifi_led_info() {
	
    if [ "$DEBUG_ENABLE" -gt 0 ]; then
        echo "$1" > /dev/console
    fi
}

# Determine if PLC is linked.
__wifi_led_is_plc_link() {
    local status='0'
    
    if [ -e /tmp/plc_runtime_info ]; then
        status=$(cat /tmp/plc_runtime_info)
        status=${status#*status\":} && status=${status%%\}*}
        __wifi_led_info "plc status:$status"
        if [ "$status" == "1" ]; then
            return 0
        fi
    fi
   
    # Plc is not linked
    return 1
}

# Determine if ETH is linked.
__wifi_led_is_eth_link() {
    local status='0'
    
    if [ -e /tmp/eth_runtime_info ]; then
        status=$(cat /tmp/eth_runtime_info)
        status=${status#*status\":} && status=${status%%\}*}
        __wifi_led_info "eth status:$status"
        if [ "$status" == "1" ]; then
            return 0
        fi
    fi
   
    # Plc is not linked
    return 1
}

# Determine if the gateway is reachable.
#output - 0 means need to reset the led status
__wifi_led_check_gw_reachable() {
	gw_ip=`route -n | grep ^0.0.0.0 | grep br-lan | awk '{print $2}'`
	
	#case got the gw
	if [ -n "$gw_ip" ]; then
        if [ -n "$last_ping_gw_ip" -a ! "$gw_ip" = "$last_ping_gw_ip" ]; then
            # First need to kill the existing one due to the IP change.
            __wifi_led_stop_ping
            __wifi_led_info "gateway ip changed"
        fi

		__wifi_led_info "Pinging GW IP $gw_ip"

		last_ping_gw_ip=$gw_ip
		
		if ping -c 1 -W 3 ${last_ping_gw_ip} > /dev/null; then
			ping_fail_count=0
			gw_reachable=1
			if [ "$gw_reachable" != "$last_gw_reachable_status" ]; then
				last_gw_reachable_status=$gw_reachable
				return 0
			else
				return 1
			fi
		#case ping fail
		else
			ping_fail_count=$((ping_fail_count + 1))
		fi
	#case no gw
    else
		__wifi_led_info "Failed to get default route"
		ping_fail_count=$((ping_fail_count + 1))
	fi
	
	if [ "$ping_fail_count" -ge "$ping_fail_threshold" ]; then
		__wifi_led_info "ping fail count reach threshold $ping_fail_threshold"
		gw_reachable=0
		ping_fail_count=0
		if [ ! "$gw_reachable" = "$last_gw_reachable_status" ]; then
			last_gw_reachable_status=$gw_reachable
			return 0
		fi
	fi
	
	return 1
}

# Terminate any background ping that may be running.
__wifi_led_stop_ping() {
    #kill $(jobs -p)
	kill $(ps | grep 'ping $last_ping_gw_ip' | grep -v 'grep' | awk '{print $1}' )
    __wifi_led_info "Stopped ping to GW IP $last_ping_gw_ip"
	
	ping_fail_count=0
}

#set location status to /tmp/wifi_location_status
#input: $1 - status
#input: $2 - current mode
__wifi_led_setLocationStatus() {
	if [ -f /tmp/wifi_location_status ]; then
		rm /tmp/wifi_location_status
	fi
	
	if [ "$2" = "RE" ]; then
		if [ "$gw_reachable" = "0" ]; then
			echo "$WIFIMON_STATE_RE_NOT_ASSOCIATED" >> /tmp/wifi_location_status
			last_set_status="$WIFIMON_STATE_RE_NOT_ASSOCIATED"
		else
			echo $1 >> /tmp/wifi_location_status
			last_set_status="$1"
		fi
		
		__wifi_led_info "set last status to $last_set_status"
	fi
}

#set led status 
#input $1 - gw reachable status
#input $2 - current mode
#__wifi_led_setLedStatus() {
#	if [ "$2" = "RE" ]; then
		#alert user only when the gw is unreachable
		#if [ "$1" = "1" ]; then
		#	ubus send leds '{"action":"2", "status":"0"}'
		#else
		#	ubus send leds '{"action":"2", "status":"1"}'
		#fi
#	elif [ "$2" = "AP" ]; then
		#clear led's location status
		#ubus send leds '{"action":"2", "status":"0"}'
#	fi
#}

__wifi_led_wifimon_fini() {
	rm /var/run/wifi_led_run_lock
	__wifi_led_stop_ping
	
	if [ -n "$rssi_5g_filename" ]; then
        # clean up the temporary file
        rm -f $rssi_5g_filename
        rssi_5g_filename=
    fi
	
	if [ -n "$rssi_2g_filename" ]; then
        # clean up the temporary file
        rm -f $rssi_2g_filename
        rssi_2g_filename=
    fi
}

# Measure the RSSI to the serving AP and update the state accordingly.
#input:$1 - sub re mode.
# output: $2 - state: the variable to update with the new state name (if there
#                     was a change)
__wifi_led_wifimon_measure_link() {
	local rssi
	local location_2g_status
	local location_5g_status
	
	#measure 5g rssi if 5g associated.
	if [ "$associated_5g" -gt 0 ]; then	
		rssi=`iwconfig $sta_iface_5g | grep 'Signal level' | awk -F'=' '{print $3}' | awk '{print $1}'`

		if [ "$rssi" -gt -95 ]; then
			if [ "$rssi_5g_num" -lt "$rssi_samples" ]; then
				# Ignore the very first sample since it is taken at the same time
				# the ping is started (and thus the RSSI might not have been
				# updated).
				if [ "$rssi_5g_num" -eq 0 ]; then
					rssi_5g_filename=`mktemp /tmp/location-5g-rssi.XXXXXX`
					rssi_5g_num=$((rssi_5g_num + 1))
				fi
				
				echo $rssi >> $rssi_5g_filename
				
				__wifi_led_info "5G RSSI sample #$rssi_5g_num = $rssi dBm"
					
				rssi_5g_num=$((rssi_5g_num + 1))

			elif [ "$rssi_5g_num" -ge "$rssi_samples" ]; then
				__wifi_led_info "5G RSSI sample #$rssi_5g_num = $rssi dBm"
				
				echo $rssi >> $rssi_5g_filename

				local rssi_median_index=$((($rssi_5g_num + 1) / 2))
				local rssi_median=$(cat $rssi_5g_filename | sort -n |
								head -n $rssi_median_index | tail -n 1)
								
				__wifi_led_info "5G Median RSSI = $rssi_median dBm"

				if [ "$1" == "daisy" ]; then
					__wifi_led_info "5g daisy threshold:$rssi_far_daisy_5g"
					if [ "$rssi_median" -lt "$rssi_far_daisy_5g" ]; then
						location_5g_status=$WIFIMON_STATE_RE_MOVE_CLOSER
					else
						location_5g_status=$WIFIMON_STATE_RE_LOCATION_SUITABLE
					fi
				elif [ "$1" == "star" ]; then
					__wifi_led_info "5g star threshold:$rssi_far_star_5g"
					if [ "$rssi_median" -lt "$rssi_far_star_5g" ]; then
						location_5g_status=$WIFIMON_STATE_RE_MOVE_CLOSER
					else
						location_5g_status=$WIFIMON_STATE_RE_LOCATION_SUITABLE
					fi
				else
					__wifi_led_info "unknow sub mode"
				fi
			fi
		fi
	fi
	
	#measure 2g rssi if 2g associated.
	if [ "$associated_24g" -gt 0 ]; then	
		rssi=`iwconfig $sta_iface_24g | grep 'Signal level' | awk -F'=' '{print $3}' | awk '{print $1}'`

		if [ "$rssi" -gt -95 ]; then
			if [ "$rssi_2g_num" -lt "$rssi_samples" ]; then
				# Ignore the very first sample since it is taken at the same time
				# the ping is started (and thus the RSSI might not have been
				# updated).
				if [ "$rssi_2g_num" -eq 0 ]; then
					rssi_2g_filename=`mktemp /tmp/location-2g-rssi.XXXXXX`
					rssi_2g_num=$((rssi_2g_num + 1))
				fi
				
				echo $rssi >> $rssi_2g_filename
				
				__wifi_led_info "2G RSSI sample #$rssi_2g_num = $rssi dBm"
					
				rssi_2g_num=$((rssi_2g_num + 1))

			elif [ "$rssi_2g_num" -ge "$rssi_samples" ]; then
				__wifi_led_info "2G RSSI sample #$rssi_2g_num = $rssi dBm"
				
				echo $rssi >> $rssi_2g_filename

				local rssi_median_index=$((($rssi_2g_num + 1) / 2))
				local rssi_median=$(cat $rssi_2g_filename | sort -n |
								head -n $rssi_median_index | tail -n 1)
								
				__wifi_led_info "Median RSSI = $rssi_median dBm"

				if [ "$1" == "daisy" ]; then
					__wifi_led_info "2g daisy threshold:$rssi_far_daisy_2g"
					if [ "$rssi_median" -lt "$rssi_far_daisy_2g" ]; then
						location_2g_status=$WIFIMON_STATE_RE_MOVE_CLOSER
					else
						location_2g_status=$WIFIMON_STATE_RE_LOCATION_SUITABLE
					fi
				elif [ "$1" == "star" ]; then
					__wifi_led_info "2g star threshold:$rssi_far_star_2g"
					if [ "$rssi_median" -lt "$rssi_far_star_2g" ]; then
						location_2g_status=$WIFIMON_STATE_RE_MOVE_CLOSER
					else
						location_2g_status=$WIFIMON_STATE_RE_LOCATION_SUITABLE
					fi
				else
					__wifi_led_info "unknow sub mode"
				fi
			fi
		fi
	fi
	
	#any band is suitable
	if [ "$location_2g_status" = "$WIFIMON_STATE_RE_LOCATION_SUITABLE" -o "$location_5g_status" = "$WIFIMON_STATE_RE_LOCATION_SUITABLE" ]; then
		eval "$2=$WIFIMON_STATE_RE_LOCATION_SUITABLE"
		rssi_2g_num=0
		rssi_5g_num=0
		rm /tmp/location-*
		return
	fi
	
	#both band is too far
	if [ "$location_2g_status" = "$WIFIMON_STATE_RE_MOVE_CLOSER" -a "$location_5g_status" = "$WIFIMON_STATE_RE_MOVE_CLOSER" ]; then
		eval "$2=$WIFIMON_STATE_RE_MOVE_CLOSER"
		rssi_2g_num=0
		rssi_5g_num=0
		rm /tmp/location-*
		return
	fi
	
	#just 5g band associated
	if [ "$associated_5g" -gt 0 -a "$associated_24g" -eq 0 -a -n "$location_5g_status" ]; then
		eval "$2=$location_5g_status"
		rssi_5g_num=0
		rm /tmp/location-*
	fi
	
	#just 2g band associated
	if [ "$associated_24g" -gt 0 -a "$associated_5g" -eq 0 -a -n "$location_2g_status" ]; then
		eval "$2=$location_2g_status"
		rssi_2g_num=0
		rm /tmp/location-*
	fi
}

# Determine if interface named is current associated.
#
# Note that for the purposes of this function, an empty interface name is
# considered associated. This is done because in some configurations, only
# one interface is enabled (the 5 GHz one).
#
# input: $1 - iface: the name of the interface (eg. ath01)
# return: 0 if associated , 1 if empty interface ; otherwise 2
__wifi_led_wifimon_is_assoc() {
    local iface=$1
    if [ -n "$iface" ]; then
        local assoc_str=$(iwconfig $iface)

        if $(echo "$assoc_str" | grep 'Access Point: ' | grep -v 'Not-Associated' > /dev/null); then
            return 0
        elif $(echo "$assoc_str" | grep 'No such device' > /dev/null); then
			return 1
		else
            return 2
        fi
    else
        # An unknown interface is considered empty interface.
        return 1
    fi
}

# Check the status of star RE.
#input:$1 - su re mode.
# output: $2 - state: the name of the new state
__wifi_led_wifimon_check_re_status() {
	local empty_iface_24g=0 empty_iface_5g=0
	associated_24g=0
	associated_5g=0

    if __wifi_led_is_eth_link; then
        eval "$2=$WIFIMON_STATE_RE_LOCATION_SUITABLE"
        rssi_2g_num=0
		rssi_5g_num=0
        return
    fi	
	
	if __wifi_led_is_plc_link; then
		eval "$2=$WIFIMON_STATE_RE_LOCATION_SUITABLE"
		rssi_2g_num=0
		rssi_5g_num=0
		return
	fi
	
	__wifi_led_wifimon_is_assoc $sta_iface_24g
	if [ $? -eq 0 ]; then
		associated_24g=1
	elif [ $? -eq 1 ]; then
		empty_iface_24g=1
	fi

	__wifi_led_wifimon_is_assoc $sta_iface_5g
	if [ $? -eq 0 ]; then
		associated_5g=1
	elif [ $? -eq 1 ]; then
		empty_iface_5g=1
	fi

	#if both 2.4G and 5G band is empty, set status to Not-Associated
	if [ $empty_iface_24g -eq 1 -a $empty_iface_5g -eq 1 ]; then
		eval "$2=$WIFIMON_STATE_RE_NOT_ASSOCIATED"
		#mark with not_associated
		rssi_2g_num=0
		rssi_5g_num=0
	fi
	
	if [ "$associated_24g" -eq 0 ]; then
		rssi_2g_num=0
	fi
	
	if [ "$associated_5g" -eq 0 ]; then
		rssi_5g_num=0
	fi
	
	#5g associated or 2g associated
	if [ "$associated_5g" -gt 0 -o "$associated_24g" -gt 0 ]; then
		__wifi_led_wifimon_measure_link $1 $2
	else
		eval "$2=$WIFIMON_STATE_RE_NOT_ASSOCIATED"
		rssi_2g_num=0
		rssi_5g_num=0
	fi
	
	if [ -n "$new_state" ]; then
		__wifi_led_info "newstate $new_state last_set_status $last_set_status"
		#if location changes from suitable to move_closer, need to hold it
	
		if [ "$last_set_status" = "$WIFIMON_STATE_RE_LOCATION_SUITABLE" -a "$new_state" = "$WIFIMON_STATE_RE_MOVE_CLOSER" ]; then
			con_suittofar_count=$((con_suittofar_count + 1))
			__wifi_led_info "need to hold con_suittofar_count:$con_suittofar_count"
			if [ "$con_suittofar_count" -ge "$con_suittofar_threshold" ]; then
				con_suittofar_count=0
			else
				eval "$2=$WIFIMON_STATE_RE_LOCATION_SUITABLE"
			fi
		else
			con_suittofar_count=0
		fi
	fi
}

#check ap mode's status
__wifi_led_wifimon_check_ap_status() {
	if __wifi_led_wifimon_is_assoc $ap_iface_24g ||
       	 __wifi_led_wifimon_is_assoc $ap_iface_5g; then
		eval "$1=$WIFIMON_STATE_AP_UP"
	else
		eval "$1=$WIFIMON_STATE_AP_DOWN"
	fi
}

# Check the status of the Wi-Fi link (RSSI).
# input: $1 - mode: mode we should check
# input: $2 - re-submode: repeater sub mode.
# output: $3 - state: the name of the new state (only set upon a change)
__wifi_led_wifimon_check() {
	if [ "$1" = "AP" -a -n "$ap_iface_5g" -a -n "$ap_iface_24g" ]; then
		__wifi_led_wifimon_check_ap_status $3	
	elif [ "$1" = "RE" -a -n "$sta_iface_5g" -a -n "$sta_iface_24g" ]; then
		__wifi_led_wifimon_check_re_status $2 $3
	else
		__wifi_led_info "Invalid mode"
	fi
}

#check iface is ap or sta
# input: $1 - config
# input: $2 - match mode
# output: $3 - 5g iface
# output: $4 - 24g iface
__wifi_led_wifimon_is_ap_sta_iface() {
	local config="$1"
	local mode vapname

	config_get mode "$config" mode
	config_get vapname "$config" vapname

	if [ "$mode" = "$2" ]; then
		if whc_is_5g_vap $config; then
                	eval "$3=$vapname"
            	else
                	eval "$4=$vapname"
            	fi
	fi
}

#get iface interface
__wifi_led_wifimon_get_iface() {
	config_load wireless
	config_foreach __wifi_led_wifimon_is_ap_sta_iface wifi-iface ap ap_iface_5g ap_iface_24g
	config_foreach __wifi_led_wifimon_is_ap_sta_iface wifi-iface sta sta_iface_5g sta_iface_24g
}

# init 
# input: $1 - mode: mode we should check
# input: $2 - re-submode: repeater sub mode.
# output: $3 - state: the name of the new state (only set upon a change)
__wifi_led_wifimon_init() {
	__wifi_led_wifimon_get_iface

	config_load repacd

	config_get configed_rssi_samples 'WiFiLink' 'RSSINumMeasurements' '5'
	config_get rssi_far_star_2g 'WiFiLink' 'RSSIThresholdFar_star_2g' '-75'
	config_get rssi_far_daisy_2g 'WiFiLink' 'RSSIThresholdFar_daisy_2g' '-75'
	config_get rssi_far_star_5g 'WiFiLink' 'RSSIThresholdFar_star_5g' '-80'
	config_get rssi_far_daisy_5g 'WiFiLink' 'RSSIThresholdFar_daisy_5g' '-80'
	config_get ping_fail_threshold 'WiFiLink' 'PingThreshold' '5'
	config_get con_suittofar_threshold 'WiFiLink' 'ConsecutiveSuiteToFar' '2880'

	rssi_samples=$configed_rssi_samples

	__wifi_led_wifimon_check $1 $2 $3
}

config_load repacd
config_get managed_network repacd 'ManagedNetwork' 'lan'
config_get cur_mode repacd 'DeviceType' 'RE'
config_get cur_re_submode repacd 'AssocDerivedRESubMode' 'star'
config_get link_check_delay repacd 'LinkCheckDelay' '2'

# Clean up the background ping and related logic when being terminated
# by the init system.
trap '__wifi_led_wifimon_fini; __wifi_led_setLocationStatus Reset; exit 0' SIGTERM

local cur_state new_state 

__wifi_led_wifimon_init $cur_mode $cur_re_submode new_state

__wifi_led_info "After init, new_state=$new_state"

if [ ! -n "$new_state" ]; then
	#set new state to RE_NotAssociated
	new_state=RE_NotAssociated
    __wifi_led_info "Failed to resolve interface; will attempt periodically"
fi

__wifi_led_info "Setting initial location status states to $new_state"
__wifi_led_setLocationStatus $new_state $cur_mode

__wifi_led_info "Setting initial led status status to $gw_reachable"
#__wifi_led_setLedStatus $gw_reachable $cur_mode

cur_state=$new_state

# Loop forever (unless we are killed with SIGTERM which is handled above).
while true; do
    config_load repacd
    config_get new_mode repacd 'DeviceType' 'RE'
    config_get new_re_submode repacd 'AssocDerivedRESubMode' 'star'
	config_get DEBUG_ENABLE 'WiFiLink' 'EnableDebug' '0'

    __wifi_led_info "*************loop************* mode $cur_mode $cur_re_submode"
	
	#check boost flag
	if [ -e /tmp/setup_boost ]; then
		boost_flag=1
		rssi_samples=$((($configed_rssi_samples+1)/2))
		
		__wifi_led_info "boost mode:rssi_samples=$rssi_samples"
	else
		rssi_samples=$configed_rssi_samples
		boost_flag=0
		__wifi_led_info "normal mode:rssi_samples=$rssi_samples"
	fi
	
	__wifi_led_info "boost_flag $boost_flag"
	
	if [ "$boost_flag" -ne "$last_boost_flag" ]; then
		rssi_2g_num=0
		rssi_5g_num=0
	fi
	
	last_boost_flag=$boost_flag
	
	#check the gateway is reachable or not when mode is RE
	if [ "$new_mode" = "RE" ]; then
		if __wifi_led_check_gw_reachable; then
			#__wifi_led_setLedStatus $gw_reachable $new_mode
			if "$gw_reachable" != "1" ]; then
				__wifi_led_setLocationStatus $WIFIMON_STATE_RE_NOT_ASSOCIATED $new_mode
				cur_state=$WIFIMON_STATE_RE_NOT_ASSOCIATED
			fi
		fi
	fi
	
    if [ ! "$cur_mode" = "$new_mode" ]; then

		__wifi_led_info "mode changed"

		rssi_2g_num=0
		rssi_5g_num=0
		
		if [ "$new_mode" = "AP" ]; then
			last_gw_reachable_status=2
			ping_fail_count=0
			#__wifi_led_setLedStatus $gw_reachable $new_mode
		fi

		__wifi_led_setLocationStatus Reset $new_mode

		__wifi_led_wifimon_check $new_mode $new_re_submode new_state

		if [ -n "$new_state" ]; then
			__wifi_led_info "Updating LED states to $new_state"
			__wifi_led_setLocationStatus $new_state $new_mode
			cur_state=$new_state
		fi

		cur_mode=$new_mode
		cur_re_submode=$new_re_submode
	elif [ "$cur_mode" = "$new_mode" -a "$new_mode" = "RE" -a ! "$cur_re_submode" = "$new_re_submode" ]; then
		__wifi_led_info "mode is RE and sub mode is changed"
		
		#reset rssi_2g_num and rssi_5g_num
		rssi_2g_num=0
		rssi_5g_num=0

		__wifi_led_wifimon_check $new_mode $new_re_submode new_state

		if [ -n "$new_state" ]; then
			__wifi_led_info "Updating LED states to $new_state"
			__wifi_led_setLocationStatus $new_state $new_mode
			cur_state=$new_state
		fi

        cur_mode=$new_mode
		cur_re_submode=$new_re_submode
     elif [ -n "$cur_state" ]; then
        new_state=''
	
		__wifi_led_wifimon_check $cur_mode $cur_re_submode new_state

        if [ -n "$new_state" -a ! "$new_state" = "$cur_state" ]; then
            __wifi_led_info "Updating LED states to $new_state"
            __wifi_led_setLocationStatus $new_state $cur_mode
            cur_state=$new_state
        fi
    else
		__wifi_led_wifimon_init $new_mode $new_re_submode new_state
	
        if [ -n "$new_state" ]; then
            __wifi_led_info "Setting LED states to $new_state"
            __wifi_led_setLocationStatus $new_state $cur_mode
            cur_state=$new_state
        fi
    fi
	
	#if gw is not reachable, reset cur_state to RE_NotAssociated.
	if [ "$new_mode" = "RE" -a "$gw_reachable" != "1" ]; then
		cur_state=$WIFIMON_STATE_RE_NOT_ASSOCIATED
	fi
	
    # Re-check the link conditions in a few seconds.
    sleep $link_check_delay
done
