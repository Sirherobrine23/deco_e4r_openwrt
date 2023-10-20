#!/bin/sh
#
#
#
wan_detect_mode="$(uci get wanDetect.settings.mode)"
if [ "$wan_detect_mode" = "test1" ]; then
	factoryLanMac=$(getfirm MAC)
else
	factoryLanMac="00:0A:EB:AB:25:00"
fi
mainssid=""
guestssid=""
bkssid=""
mainkey=""
guestkey=""
bkkey=""
cfgssid=""
cfgkey=""
dftssid=""
dftkey=""
stassid=""
stakey=""

__wifi_get_defaultmac() {
	rm -f /tmp/default-mac >/dev/null 2>&1
        nvrammanager -r /tmp/default-mac -p default-mac >/dev/null 2>&1
        if [ -s "/tmp/default-mac" ];then
                echo $(grep 'MAC'  /tmp/default-mac | cut -d : -f 2-)
        else
                echo  $factoryLanMac
        fi
}

wifi_get_default_suffix(){
    local mac=""
	mac="$(__wifi_get_defaultmac)"
    echo $(echo $mac | tail -c 6 | sed 's/[- ]//g')
}

wifi_init_wifi_mac() {
	local mac=""

	config_load wifi
	mac="$(__wifi_get_defaultmac)"
	mac=${mac//-/:}
	mac=$(lua /usr/sbin/wifimac $mac)
	mac=$(lua /usr/sbin/wifimac $mac)
	mac="$(echo $mac | tr 'a-f' 'A-F')"
	uci_toggle_state wifi radio_2g bssid $mac

	#generate 5G mac
	mac=$(lua /usr/sbin/wifimac $mac)
	mac="$(echo $mac | tr 'a-f' 'A-F')"
	uci_toggle_state wifi radio_5g bssid $mac

	uci_commit wifi
}

WIFICOMMON_DEBUG=1
WIFICOMMON_DEBUG_LEVEL=6

wificommon_echo() {
    if [ "$WIFICOMMON_DEBUG" -gt 0 ]; then
        logger -p $WIFICOMMON_DEBUG_LEVEL "wificommon(repacd): $1"
    fi
}

__wifi_config_wireless_vap() {
	local section=$1
	local apenable=$2
	local staenable_2g=$3
    local staenable_5g=$4	
	local aphidessid=$5
	local apencry=$6
	local guestenable=$7
	local guestencry=$8
	local rootapbssid_2g=$9
	local rootapbssid_5g=$10
	local bkhaulenable=$11
	local bkhaulencry=$12
	local bkhaulhidessid=$13
    local cfgenable=$14
    local cfgencry=$15
    local cfghidessid=$16
    local dftenable=$17
    local dftencry=$18
    local dfthidessid=$19
    local staencry=$20
    local factory_mode=$21
    local support11r=$22
    local enable11r=$23
    local apenable_2g=$24
    local apenable_5g=$25
    local guestenable_2g=$26
    local guestenable_5g=$27
    local enablebf=$28
    local host_isolate=$29
	local mode vaptype network suffix tmpssid

    config_get mode "$section" mode
    config_get vaptype "$section" type
    
    
    if [ "$vaptype" = "backhaul" -a "$mode" = "ap" ]; then
        uci_set wireless $section rept_spl 0
        if [ "$bkhaulenable" = 1 ] ; then
            uci_set wireless $section disabled 0
        else
            uci_set wireless $section disabled 1
        fi
        
        if [ "$bkssid" = "none" ]; then
            uci_set wireless $section ssid ""        
        else
            uci_set wireless $section ssid "$bkssid"
        fi
        uci_set wireless $section hidden $bkhaulhidessid
        if [ "$bkhaulencry" = "0" ]; then
            uci_set wireless $section encryption "none"
        else
            uci_set wireless $section encryption "psk2+ccmp"
            uci_set wireless $section key "$bkkey"
        fi
        uci_set wireless $section sko_max_xretries "0"
    elif [ "$vaptype" = "backhaul" -a "$mode" = "sta" ]; then
        config_get device $section device
        if [ "$device" = "wifi0" ]; then
            if [ "$staenable_2g" = 1 ]; then
                uci_set wireless $section disabled 0              
            else
                uci_set wireless $section disabled 1
            fi                
            if [ "$rootapbssid_2g" = "none" ]; then
                uci_set wireless $section bssid ""              
            else
                uci_set wireless $section bssid "$rootapbssid_2g"
            fi
        else
            if [ "$staenable_5g" = 1 ]; then
                uci_set wireless $section disabled 0              
            else
                uci_set wireless $section disabled 1
            fi             
            if [ "$rootapbssid_5g" = "none" ]; then
                uci_set wireless $section bssid ""              
            else
                uci_set wireless $section bssid "$rootapbssid_5g"
            fi          
        fi    
        
        if [ "$stassid" = "none" ]; then
            uci_set wireless $section ssid ""        
        else
            uci_set wireless $section ssid "$stassid"
        fi
        if [ "$staencry" = "0" ]; then
            uci_set wireless $section encryption "none"
        else
            uci_set wireless $section encryption "psk2+ccmp"
            uci_set wireless $section key "$stakey"
        fi        
    elif [ "$mode" = "ap" -a "$vaptype" = "lan" ]; then
        config_get device $section device
		if [ "$apenable" = 1 -a "$mode" = "ap" ] ; then
            if [ "$device" = "wifi0" ]; then
                if [ "$apenable_2g" = 0 ]; then
                    wificommon_echo "ap disabled 2g" 
                    uci_set wireless $section disabled 1
                else 
                    wificommon_echo "ap enabled 2g" 
                    uci_set wireless $section disabled 0
                fi
            elif [ "$device" = "wifi1" ]; then
                if [ "$apenable_5g" = 0 ]; then
                    wificommon_echo "ap disabled 5g" 
                    uci_set wireless $section disabled 1
                else 
                    wificommon_echo "ap enabled 5g" 
                    uci_set wireless $section disabled 0
                fi
            fi
		else
            wificommon_echo "ap disabled " 
			uci_set wireless $section disabled 1
		fi
		
		if [ "$factorymode" = 1 ]; then
			if [ "$device" = "wifi0" ]; then 
				suffix="_2G"
			elif [ "$device" = "wifi1" ]; then
				suffix="_5G"
			fi
			tmpssid="$mainssid""$suffix"
			uci_set wireless $section ssid "$tmpssid"
		else
			uci_set wireless $section ssid "$mainssid"
		fi
		uci_set wireless $section hidden $aphidessid
		if [ "$apencry" = "0" ]; then
			uci_set wireless $section encryption "none"
		else
			uci_set wireless $section encryption "psk-mixed/ccmp+tkip"
			uci_set wireless $section key "$mainkey"
		fi
		# if wireless.ap.ieee80211r does not exist, it means that :
        # there is no wireless.ap.ieee80211r in the old version,but it is available in the new version.
        # So, if device supports ieee80211r, we need to configure these below.
        config_get wireless_11r "$section" ieee80211r 
        if [ -z "$wireless_11r" ]; then
            if [ "$support11r" = "yes" ]; then
                uci_set wireless $section mobility_domain "5348"
                uci_set wireless $section nasid "r0kh.tp-link.com"
                uci_set wireless $section r0_key_lifetime "10000"
                uci_set wireless $section reassociation_deadline "1000"
                uci_set wireless $section pmk_r1_push "0"
                uci_set wireless $section ft_over_ds "0"
                uci_set wireless $section ft_resource_req_supp "1"
                uci_set wireless $section ft_psk_generate_local "1"            			
            fi
        fi
        if [ "$support11r" = "yes" ]; then
            uci_set wireless $section ieee80211r $enable11r
        else
            uci_set wifi ap ieee80211r 0
            uci_set wifi guest ieee80211r 0 
            uci_set wireless $section ieee80211r '0'
            uci_commit wifi
        fi

        if [ -n "$enablebf" ]; then
            local bf_toggle="1"
            if [ "$enablebf" = '1' ]; then
                bf_toggle="1"
            else
                bf_toggle="0"
            fi
            config_get device $section device
            if [ "$device" = "wifi1" ]; then 
                uci_set wireless $section vhtsubfer "$bf_toggle"
                uci_set wireless $section vhtmubfer "$bf_toggle"
                uci_set wireless $section vhtsubfee "$bf_toggle"
                uci_set wireless $section vhtmubfee "$bf_toggle"
            fi
        fi

    
	elif [ "$mode" = "ap" -a "$vaptype" = "guest" ]; then
		uci_set wireless $section ssid "$guestssid"
        uci_set wireless $section network "lan"
        config_get device $section device
		if [ "$guestenable" = 1 -a "$apenable" = 1 ]; then
            if [ "$device" = "wifi0" ]; then
                if [ "$guestenable_2g" = 0 ]; then
                    wificommon_echo "guest disabled 2g" 
                    uci_set wireless $section disabled 1
                else 
                    wificommon_echo "guest enabled 2g"
                    uci_set wireless $section disabled 0
                fi
            elif [ "$device" = "wifi1" ]; then
                if [ "$guestenable_5g" = 0 ]; then
                    wificommon_echo "guest disabled 5g"
                    uci_set wireless $section disabled 1
                else 
                    wificommon_echo "guest enabled 5g"
                    uci_set wireless $section disabled 0
                fi
            fi
		else
            wificommon_echo "guest disabled " 
			uci_set wireless $section disabled 1		
		fi
		if [ "$guestencry" = "0" ]; then
			uci_set wireless $section encryption "none"
		else
			uci_set wireless $section encryption "psk-mixed/ccmp+tkip"
			uci_set wireless $section key "$guestkey"
		fi
        config_get wireless_11r "$section" ieee80211r 
        if [ -z "$wireless_11r" ]; then
            if [ "$support11r" = "yes" ]; then
                uci_set wireless $section mobility_domain "5348"
                uci_set wireless $section nasid "r0kh.tp-link.com"
                uci_set wireless $section r0_key_lifetime "10000"
                uci_set wireless $section reassociation_deadline "1000"
                uci_set wireless $section pmk_r1_push "0"
                uci_set wireless $section ft_over_ds "0"
                uci_set wireless $section ft_resource_req_supp "1"
                uci_set wireless $section ft_psk_generate_local "1"                     
            fi
        fi
        if [ "$support11r" = "yes" ]; then
            uci_set wireless $section ieee80211r $enable11r
        else
            uci_set wifi ap ieee80211r 0
            uci_set wifi guest ieee80211r 0 
            uci_set wireless $section ieee80211r '0'
            uci_commit wifi
        fi		

        if [ "$host_isolate" = "1" ]; then
            uci_set wireless $section isolate "1"
        else
            uci_set wireless $section isolate "0"
        fi
		
    elif [ "$mode" = "ap" -a "$vaptype" = "config" ]; then
        uci_set wireless $section rept_spl 0
        if [ "$cfgenable" = 1 ] ; then
            uci_set wireless $section disabled 0
        else
            uci_set wireless $section disabled 1
        fi
        
        if [ "$cfgssid" = "none" ]; then
            uci_set wireless $section ssid ""        
        else
            uci_set wireless $section ssid "$cfgssid"
        fi
        uci_set wireless $section hidden $cfghidessid
        if [ "$cfgencry" = "0" ]; then
            uci_set wireless $section encryption "none"
        else
            uci_set wireless $section encryption "psk2+ccmp"
            uci_set wireless $section key "$cfgkey"
        fi
    elif [ "$mode" = "ap" -a "$vaptype" = "default" ]; then
        if [ "$dftenable" = 1 ] ; then
            uci_set wireless $section disabled 0
        else
            uci_set wireless $section disabled 1
        fi
        
        if [ "$dftssid" = "none" ]; then
            uci_set wireless $section ssid ""        
        else
            suffix="$(wifi_get_default_suffix)"
			tmpssid="$dftssid""_""$suffix"
            uci_set wireless $section ssid "$tmpssid"
        fi
        uci_set wireless $section hidden $dfthidessid
        if [ "$dftencry" = "0" ]; then
            uci_set wireless $section encryption "none"
        else
            uci_set wireless $section encryption "psk2+ccmp"
            uci_set wireless $section key "$dftkey"
        fi       
    fi
}

__wifi_config_wireless_radio() {                                                        
        local section=$1                                                
        local channel=$2                                                                                                         
        local bssid=$3
	local hwmode=$4
	local htmode=$5                                                
	local country=$6 
	local enable=$7                                              
	local enablebf=$8                                              
                                                                                                                                    
    uci_set wireless $section channel $channel                      
    uci_set wireless $section macaddr $bssid
	uci_set wireless $section hwmode $hwmode
	uci_set wireless $section htmode $htmode                        
	uci_set wireless $section country $country
	if [ "$enable" = 1 ]; then
		uci_set wireless $section disabled 0
	else 
		uci_set wireless $section disabled 1
	fi 

    # if [ "$section" = "wifi0" ] && [ -n "$enablebf" ]; then
    #     if [ "$enablebf" = '1' ]; then
    #         uci_set wireless $section TxBFCTL '1'
    #     else
    #         uci_set wireless $section TxBFCTL '0'
    #     fi
    # fi             
}

wifi_config_wireless() {
	local aphidessid apencry apenable
	local guestenable guestencry
	local channel_2g channel_5g bssid_2g bssid_5g country_2g country_5g
	local htmode_2g htmode_5g hwmode_2g hwmode_5g radio_2g_enable radio_5g_enable
	local rootapbssid_2g rootapbssid_5g
	local bkhaulenable bkhaulencry bkhaulhidessid
    local cfgenable cfgencry cfghidessid	
    local dftenable dftencry dfthidessid
    local staencry         
	local factorymode
	local support11r
	


	config_get mainssid ap ssid
	config_get aphidessid ap hidessid
	config_get apencry ap encryption
	config_get mainkey ap password
	config_get apenable ap enable
	config_get apenable_2g ap enable_2g '1'
	config_get apenable_5g ap enable_5g '1'
	config_get guestenable guest enable
	config_get guestenable_2g guest enable_2g '1'
	config_get guestenable_5g guest enable_5g '1'
	config_get guestssid guest ssid
	config_get guestencry guest encryption
	config_get guestkey guest password
	config_get channel_2g radio_2g channel '0'     
	config_get bssid_2g radio_2g bssid 
	config_get hwmode_2g radio_2g hwmode
	config_get htmode_2g radio_2g htmode                   
	config_get country_2g radio_2g country
	config_get radio_2g_enable radio_2g enable '1'
	config_get channel_5g radio_5g channel '0'                                                 
	config_get bssid_5g radio_5g bssid
	config_get hwmode_5g radio_5g hwmode
	config_get htmode_5g radio_5g htmode  
	config_get country_5g radio_5g country
	config_get radio_5g_enable radio_5g enable '1'
	config_get rootapbssid_2g sta_2g bssid 'none'
	config_get rootapbssid_5g sta_5g bssid 'none'
	config_get bkhaulenable backhaul enable '1'
	config_get bkssid backhaul ssid 'none'
	config_get bkhaulencry backhaul encryption
	config_get bkkey backhaul password
	config_get bkhaulhidessid backhaul hidessid
    config_get cfgenable config enable '1'
    config_get cfgssid config ssid 'none'
    config_get cfgencry config encryption
    config_get cfgkey config password
    config_get cfghidessid config hidessid
    config_get dftenable default enable '1'
    config_get dftssid default ssid 'none'
    config_get dftencry default encryption
    config_get dftkey default password
    config_get dfthidessid default hidessid
    config_get stassid sta ssid 'none'
    config_get staencry sta encryption
    config_get stakey sta password    
	config_get factorymode ap factorymode '0'
    config_get staenable_2g sta_2g enable '0'
    config_get staenable_5g sta_5g enable '0'
    config_get enable11r ap ieee80211r
    config_get enablebf ap beamforming '1'
    config_get host_isolate guest host_isolation '1'
    support11r=$(uci get profile.@wireless[0].11r_support -c /etc/profile.d)
    [ -z "$support11r" ] && support11r="no"

	config_load wireless
	
	__wifi_config_wireless_radio wifi0 $channel_2g $bssid_2g $hwmode_2g $htmode_2g $country_2g $radio_2g_enable $enablebf
	__wifi_config_wireless_radio wifi1 $channel_5g $bssid_5g $hwmode_5g $htmode_5g $country_5g $radio_5g_enable $enablebf
	config_foreach __wifi_config_wireless_vap wifi-iface $apenable $staenable_2g $staenable_5g $aphidessid $apencry \
			$guestenable  $guestencry $rootapbssid_2g $rootapbssid_5g $bkhaulenable \
			$bkhaulencry $bkhaulhidessid $cfgenable $cfgencry $cfghidessid $dftenable $dftencry \
			$dfthidessid $staencry $factorymode $support11r $enable11r $apenable_2g $apenable_5g $guestenable_2g $guestenable_5g $enablebf $host_isolate
						

	uci_commit wireless
}


ACT_RE_LOAD=1
ACT_COUNTRY=2
ACT_DEV_CFG=4
ACT_DEVMODE=8
ACT_VAP_CFG=16

CFG_HST_2G=1
CFG_HST_5G=2
CFG_GST_2G=4
CFG_GST_5G=8
CFG_BHL_2G=16
CFG_BHL_5G=32
CFG_STA_2G=64
CFG_STA_5G=128
CFG_CFG_2G=256
CFG_CFG_5G=512
CFG_DFT_2G=1024
CFG_DFT_5G=2048
CFG_DEV_2G=4096
CFG_DEV_5G=8192


CFG_VAP_2G=$((CFG_STA_2G | CFG_GST_2G | CFG_HST_2G | CFG_CFG_2G | CFG_DFT_2G))
CFG_VAP_5G=$((CFG_HST_5G | CFG_GST_5G | CFG_STA_5G | CFG_CFG_5G | CFG_DFT_5G))
CFG_VAP_AL=$((CFG_VAP_2G | CFG_VAP_5G))
CFG_DEV_AL=$((CFG_DEV_2G | CFG_DEV_5G))
CFG_HST_AL=$((CFG_HST_2G | CFG_HST_5G))
CFG_BHL_AL=$((CFG_BHL_2G | CFG_BHL_5G))
CFG_GST_AL=$((CFG_GST_2G | CFG_GST_5G))
CFG_STA_AL=$((CFG_STA_2G | CFG_STA_5G))
CFG_CFG_AL=$((CFG_CFG_2G | CFG_CFG_5G))
CFG_DFT_AL=$((CFG_DFT_2G | CFG_DFT_5G))
CFG_USR_AL=$((CFG_HST_AL | CFG_GST_AL))


wifi_config_list="ap.ssid:$CFG_HST_AL,$ACT_VAP_CFG \
             ap.ieee80211r:$CFG_USR_AL,$ACT_VAP_CFG\
             ap.beamforming:$CFG_HST_AL,$ACT_VAP_CFG\
             ap.encryption:$CFG_HST_AL,$ACT_VAP_CFG \
             ap.password:$CFG_HST_AL,$ACT_VAP_CFG \
             ap.hidessid:$CFG_HST_AL,$ACT_VAP_CFG \
             ap.enable:$CFG_HST_AL,$ACT_VAP_CFG \
             ap.enable_2g:$CFG_HST_2G,$ACT_VAP_CFG \
             ap.enable_5g:$CFG_HST_5G,$ACT_VAP_CFG \
             guest.ssid:$CFG_GST_AL,$ACT_VAP_CFG \
             guest.ieee80211r:$CFG_GST_AL,$ACT_VAP_CFG\
             guest.encryption:$CFG_GST_AL,$ACT_VAP_CFG \
             guest.password:$CFG_GST_AL,$ACT_VAP_CFG \
             guest.enable:$CFG_GST_AL,$ACT_VAP_CFG \
             guest.enable_2g:$CFG_GST_2G,$ACT_VAP_CFG \
             guest.enable_5g:$CFG_GST_5G,$ACT_VAP_CFG \
             guest.host_isolation:$CFG_GST_AL,$ACT_VAP_CFG \
             backhaul.ssid:$CFG_BHL_AL,$ACT_VAP_CFG \
             backhaul.encryption:$CFG_BHL_AL,$ACT_VAP_CFG \
             backhaul.password:$CFG_BHL_AL,$ACT_VAP_CFG \
             backhaul.hidessid:$CFG_BHL_AL,$ACT_VAP_CFG \
             backhaul.enable:$CFG_BHL_AL,$ACT_VAP_CFG \
             config.ssid:$CFG_CFG_AL,$ACT_VAP_CFG \
             config.encryption:$CFG_CFG_AL,$ACT_VAP_CFG \
             config.password:$CFG_CFG_AL,$ACT_VAP_CFG \
             config.hidessid:$CFG_CFG_AL,$ACT_VAP_CFG \
             config.enable:$CFG_CFG_AL,$ACT_VAP_CFG \
             default.ssid:$CFG_DFT_AL,$ACT_VAP_CFG \
             default.encryption:$CFG_DFT_AL,$ACT_VAP_CFG \
             default.password:$CFG_DFT_AL,$ACT_VAP_CFG \
             default.hidessid:$CFG_DFT_AL,$ACT_VAP_CFG \
             default.enable:$CFG_DFT_AL,$ACT_VAP_CFG \
             sta.ssid:$CFG_STA_AL,$ACT_VAP_CFG \
             sta.encryption:$CFG_STA_AL,$ACT_VAP_CFG \
             sta.password:$CFG_STA_AL,$ACT_VAP_CFG \
             sta_2g.enable:$CFG_STA_2G,$ACT_VAP_CFG \
             sta_2g.bssid:$CFG_STA_2G,$ACT_VAP_CFG \
             sta_5g.enable:$CFG_STA_5G,$ACT_VAP_CFG \
             sta_5g.bssid:$CFG_STA_5G,$ACT_VAP_CFG \
             radio_2g.enable:$CFG_DEV_2G,$ACT_RE_LOAD \
             radio_2g.hwmode:$CFG_DEV_2G,$ACT_DEVMODE \
             radio_2g.htmode:$CFG_DEV_2G,$ACT_DEVMODE \
             radio_2g.channel:$CFG_DEV_2G,$ACT_DEVMODE \
             radio_2g.bssid:$CFG_DEV_2G,$ACT_RE_LOAD \
             radio_2g.country:$CFG_DEV_AL,$ACT_RE_LOAD \
             radio_5g.enable:$CFG_DEV_5G,$ACT_RE_LOAD \
             radio_5g.hwmode:$CFG_DEV_5G,$ACT_DEVMODE \
             radio_5g.htmode:$CFG_DEV_5G,$ACT_DEVMODE \
             radio_5g.channel:$CFG_DEV_5G,$ACT_DEVMODE \
             radio_5g.bssid:$CFG_DEV_5G,$ACT_RE_LOAD \
             radio_5g.country:$CFG_DEV_AL,$ACT_RE_LOAD"

wifi_act_list="reload country dev mode vap"
wifi_device_list="wifi0 wifi1"
wifi_vap_list="ath0 ath1 ath01 ath11 ath02 ath12 ath03 ath13 ath04 ath14 ath05 ath15"

WIFI_CFG='/etc/config/wifi'             
WIFI_BACK_CFG='/tmp/etc/config/wifi'
TMP_CFG_DIR='/tmp/etc/config' 


wifi_config_inspect() { 
    local key val cfg act
    local section option new_value old_value 
    local vapcfg devcfg vaplist devlist
    local wificfg= 
    local wifiact=
    local cmd=
    
    config_load wifi
    if [ ! -f $WIFI_BACK_CFG ]; then
        mkdir -p $TMP_CFG_DIR
        uci -P /var/state export wifi > $WIFI_BACK_CFG
        wificfg=$CFG_DEV_AL
        wifiact=$ACT_RE_LOAD

    else
        for param in $wifi_config_list; do
            key=${param%%:*}
            val=${param#*:}
            section=${key%%.*}
            option=${key#*.}
            cfg=${val%%,*}
            act=${val#*,}
            #echo "section:$section, option:$option, cfg:$cfg, act:$act" >/dev/console
            
            config_get new_value $section "$option"           
            old_value=$(uci get wifi.$section.$option -c $TMP_CFG_DIR)
            if [ ! "$new_value" = "$old_value" ]; then
                uci set wifi.$section.$option="$new_value" -c $TMP_CFG_DIR
                if [ -z $wificfg ]; then
                    wificfg=$cfg
                else
                    wificfg=$((wificfg | cfg))
                fi
                
                if [ -z $wifiact ]; then
                    wifiact=$act
                else
                    wifiact=$((wifiact | act))                
                fi
                wificommon_echo "new_value:$new_value, old_value:$old_value"
                wificommon_echo "change:$wificfg, action:$wifiact"
            fi
        done

        uci commit -c $TMP_CFG_DIR

    fi
    
    vapcfg=$((wificfg % CFG_DEV_2G))
    devcfg=$((wificfg / CFG_DEV_2G))
    index=1
    for vap in $wifi_vap_list; do
        tmp1=$((vapcfg & index))
        if [ "$tmp1" != "0" ]; then
             vaplist="$vaplist$vap,"
        fi
        index=$((index * 2))
        
    done
    vaplist=${vaplist%,*}
    wificommon_echo "vaplist:$vaplist"
    
    index=1
    for dev in $wifi_device_list; do
        tmp1=$((devcfg & index))
        if [ "$tmp1" != "0" ]; then
             devlist="$devlist$dev,"
        fi
        index=$((index * 2))
    done
    devlist=${devlist%,*}
    wificommon_echo "devlist:$devlist"
    
    index=1
    for item in $wifi_act_list; do
        tmp1=$((wifiact & index))
        if [ "$tmp1" != "0" ]; then
             cmd="$cmd$item,"
        fi
        index=$((index * 2))
    done
    cmd=${cmd%,*}  
    cmd="$cmd $devlist"
    cmd="$cmd $vaplist"
    [ -n "$(echo $cmd | sed s/[[:space:]]//g)" ] && wifi_config_wireless
    echo $cmd
    
}




