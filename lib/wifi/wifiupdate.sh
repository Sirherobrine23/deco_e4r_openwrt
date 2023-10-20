#!/bin/sh
#
# Copyright (c) 2014 TP-LINK Technologies Co., Ltd.
#
# All Rights Reserved.
#


brchanged=0

maclist_sec=""


DBG=1
STDOUT="/dev/null"

if [ "$DBG" = "1" ];then
    DEBUG=echo
    STDOUT="/dev/console"
fi

tpdbg () {
    ${DEBUG:-:} "$*" >$STDOUT
}

kill_process() {
    [ -f "/var/run/hostapd-$1.lock" ] && { \
        wpa_cli -g /var/run/hostapd/global raw REMOVE $1
        rm /var/run/hostapd-$1.lock
    }
    [ -f "/var/run/wpa_supplicant-$1.lock" ] && { \
        wpa_cli -g /var/run/wpa_supplicantglobal  interface_remove  $1
        rm /var/run/wpa_supplicant-$1.lock
    }
    [ -f "/var/run/wapid-$1.conf" ] && { \
        kill "$(cat "/var/run/wifi-$1.pid")"
    }        
}

down_vap() {
    tpdbg "down_vap" 
    [ ! -d /sys/class/net/$1 ] && return

    kill_process "$1"    
    
    [ "$(cat /sys/class/net/$1/carrier)" == "1" ] && ifconfig "$1" down 
    
    uci_revert_state wireless $1 up 

}

create_process(){
    local vif="$1" mode="$2" brname="$3" start_hostapd="$4" start_wapid="$5"
    
    tpdbg "[create_process]vif:$vif" >/dev/console
    uci_set_state wireless "$vif" up 1    
    
    [ ! -d /sys/class/net/$vif/master ] && [ -n "$brname" ] &&{
        brctl addif "$brname" "$vif"
        [ "$?" = "0" ] && brchanged=1
        ubus send apsd.configure '{}'
        #ubus call network.interface.lan add_device "{\"name\":\"$vif\"}"
    }     
    
    case "$mode" in
        ap|ap_guest)
            if [ -n "$start_wapid" ]; then
                wapid_setup_vif "$vif" || {
                    echo "enable_qcawifi($device): Failed to set up wapid for interface $vif" >&2
                    uci_revert_state wireless $vif up 
                    ifconfig "$vif" down
                    wlanconfig "$vif" destroy
                    return
                }
            fi

            if [ -n "$start_hostapd" ] && [ ! -f "/var/run/hostapd-$vif.lock" ] && eval "type hostapd_setup_vif" 2>/dev/null >/dev/null; then  
                hostapd_setup_vif "$vif" atheros no_nconfig || {
                    echo "enable_qcawifi($device): Failed to set up hostapd for interface $vif" >&2
                    # make sure this wifi interface won't accidentally stay open without encryption
                    uci_revert_state wireless $vif up 
                    ifconfig "$vif" down
                    wlanconfig "$vif" destroy
                    return
                }
            fi
         ;;
        wds|sta)
            if [ ! -f "/var/run/wpa_supplicant-$vif.lock" ] && eval "type wpa_supplicant_setup_vif" 2>/dev/null >/dev/null; then
                if [ ! -f "/var/run/wpa_supplicant-update-$vif.lock" ]; then
                    touch /var/run/wpa_supplicant-update-$vif.lock
                    wpa_supplicant_setup_vif "$vif" athr || {
                        echo "enable_qcawifi($device): Failed to set up wpa_supplicant for interface $vif" >&2
                        uci_revert_state wireless $vif up 
                        ifconfig "$vif" down
                        wlanconfig "$vif" destroy
                        rm /var/run/wpa_supplicant-update-$vif.lock
                        return
                    }
                    rm /var/run/wpa_supplicant-update-$vif.lock
                fi
            fi
        ;; 
    esac
     
}

config_disablecoext() {
    local vif="$1" disablecoext="$2"
    local config_info="g_disablecoext:$disablecoext"
    same_config=$(iwpriv "$vif" g_disablecoext | grep "$config_info")
    [ -n "$same_config" ] && return
    [ -n "$disablecoext" ] && iwpriv "$vif" disablecoext "${disablecoext}"
}

config_channel() {
    local vif="$1" chan="$2"
    local channel_info="(Channel $chan)"
    same_channel=$(iwlist "$vif" channel | grep "Current" | grep "$channel_info")
    [ -n "$same_channel" ] && return
    [ -n "$chan" ] && iwconfig "$vif" channel "$chan"
}

getmaclist_sec() {
	local section="$1"
	config_get mac "$section" mac
	mac=${mac//-/:}
	append maclist_sec "$mac "
}

create_vap() {
    tpdbg "create vap :$1" 
    local vif="$1" device="$2"    
    local start_hostapd= vif_txpower= nosbeacon= wlanaddr=""
    local wlanmode disabled vaptype
    local country
    
    config_get channel "$device" channel
    config_get txpower "$device" txpower
    config_get country "$device" country

    [ auto = "$channel" ] && channel=0    
    
    config_get enc "$vif" encryption "none"
    config_get eap_type "$vif" eap_type
    config_get mode "$vif" mode
    config_get ifname "$vif" vapname
    config_get disabled "$vif" disabled
    config_get vaptype "$vif" type
    wlanmode=$mode

    [ "$wlanmode" = "ap_monitor" ] && wlanmode="specialvap"
    [ "$wlanmode" = "ap_smart_monitor" ] && wlanmode="smart_monitor"
    [ "$wlanmode" = "ap_lp_iot" ] && wlanmode="lp_iot_mode"
    [ "$wlanmode" = "ap_guest" ] && wlanmode="ap"

    case "$mode" in
    sta)
        config_get_bool nosbeacon "$device" nosbeacon
        config_get qwrap_enable "$device" qwrap_enable 0
        [ $qwrap_enable -gt 0 ] && wlanaddr="00:00:00:00:00:00"
        ;;
            adhoc)
        config_get_bool nosbeacon "$vif" sw_merge 1
        ;;
    esac
    

    [ "$nosbeacon" = 1 ] || nosbeacon=""
    #[ -n "${DEBUG}" ] && echo wlanconfig "$ifname" create wlandev "$phy" wlanmode "$wlanmode" ${wlanaddr:+wlanaddr "$wlanaddr"} ${nosbeacon:+nosbeacon}
    #ifname=$(/usr/sbin/wlanconfig "$ifname" create wlandev "$phy" wlanmode "$wlanmode" ${wlanaddr:+wlanaddr "$wlanaddr"} ${nosbeacon:+nosbeacon})
    
    if [ ! -d /sys/class/net/${ifname} ]; then
        ifname=$(/usr/sbin/wlanconfig "$ifname" create wlandev "$device" wlanmode "$wlanmode" ${wlanaddr:+wlanaddr "$wlanaddr"} ${nosbeacon:+nosbeacon})
    else
        return 0
    fi

    [ $? -ne 0 ] && {
            echo "Failed to set up $mode vif $ifname" >&2
            return 
    }

    [ "$disabled" = 1 ] && return
    config_set "$vif" ifname "$ifname"

    config_get hwmode "$device" hwmode auto
    config_get htmode "$device" htmode auto

    local band
    case "$hwmode" in
            *ac) band="5g";;
            *) band="2g";;
    esac

    pureg=0
    case "$hwmode:$htmode" in
    # The parsing stops at the first match so we need to make sure
    # these are in the right orders (most generic at the end)
            *ng:HT20) hwmode=11NGHT20;;
            *ng:HT40-) hwmode=11NGHT40MINUS;;
            *ng:HT40+) hwmode=11NGHT40PLUS;;
            *ng:HT40) hwmode=11NGHT40;;
            *ng:*) hwmode=11NGHT20;;
            *na:HT20) hwmode=11NAHT20;;
            *na:HT40-) hwmode=11NAHT40MINUS;;
            *na:HT40+) hwmode=11NAHT40PLUS;;
            *na:HT40) hwmode=11NAHT40;;
            *na:*) hwmode=11NAHT40;;
            *ac:HT20) hwmode=11ACVHT20;;
            *ac:HT40+) hwmode=11ACVHT40PLUS;;
            *ac:HT40-) hwmode=11ACVHT40MINUS;;
            *ac:HT40) hwmode=11ACVHT40;;
            *ac:HT80) hwmode=11ACVHT80;;
            *ac:HT160) hwmode=11ACVHT160;;
            *ac:HT80_80) hwmode=11ACVHT80_80;;
            *ac:*) hwmode=11ACVHT80
                if [ -f /sys/class/net/$device/5g_maxchwidth ]; then
                       maxchwidth="$(cat /sys/class/net/$device/5g_maxchwidth)"
                       [ -n "$maxchwidth" ] && hwmode=11ACVHT$maxchwidth
                fi
                if [ "$mode" == "sta" ]; then
                       cat /sys/class/net/$device/hwmodes | grep  "11AC_VHT80_80"
                       if [ $? -eq 0 ]; then
                           hwmode=11ACVHT80_80
                       fi
                fi;;
                
            *b:*) hwmode=11B;;
            *bg:*) hwmode=11G;;
            *g:*) hwmode=11G; pureg=1;;
            *a:*) hwmode=11A;;
            *) hwmode=AUTO;;
    esac
    iwpriv "$ifname" mode "$hwmode"
    [ $pureg -gt 0 ] && iwpriv "$ifname" pureg "$pureg"

    config_get cfreq2 "$vif" cfreq2
    [ -n "$cfreq2" -a "$htmode" = "HT80_80" ] && iwpriv "$ifname" cfreq2 "$cfreq2"

    config_get puren "$vif" puren
    [ -n "$puren" ] && iwpriv "$ifname" puren "$puren"

    [ "$vaptype" != "guest" -a "$vaptype" != "config" ] && config_channel "$ifname" "$channel"  && tpdbg "XXXX Update Config channel : $ifname"

    config_get_bool hidden "$vif" hidden 0
    iwpriv "$ifname" hide_ssid "$hidden"

    config_get_bool dynamicbeacon "$vif" dynamicbeacon 0
    [ $hidden = 1 ] && iwpriv "$ifname" dynamicbeacon "$dynamicbeacon"

    config_get db_rssi_thr "$vif" db_rssi_thr
    [ -n "$db_rssi_thr" ] && iwpriv "$ifname" db_rssi_thr "$db_rssi_thr"

    config_get db_timeout "$vif" db_timeout
    [ -n "$db_timeout" ] && iwpriv "$ifname" db_timeout "$db_timeout"

    config_get nrshareflag "$vif" nrshareflag
    [ -n "$nrshareflag" ] && iwpriv "$ifname" nrshareflag "$nrshareflag"

    config_get_bool shortgi "$vif" shortgi 1
    [ -n "$shortgi" ] && iwpriv "$ifname" shortgi "${shortgi}"

    config_get_bool disablecoext "$vif" disablecoext
    [ -n "$disablecoext" ] && config_disablecoext "$ifname" "${disablecoext}"

    config_get chwidth "$vif" chwidth
    [ -n "$chwidth" ] && iwpriv "$ifname" chwidth "${chwidth}"

    config_get wds "$vif" wds
    case "$wds" in
            1|on|enabled) wds=1;;
            *) wds=0;;
    esac
    iwpriv "$ifname" wds "$wds" >/dev/null 2>&1

    config_get  backhaul "$vif" backhaul 0
    iwpriv "$ifname" backhaul "$backhaul" >/dev/null 2>&1

    config_get bintval "$vif" bintval
    [ -n "$bintval" ] && iwpriv "$ifname" bintval "$bintval"

    config_get_bool countryie "$vif" countryie
    [ -n "$countryie" ] && iwpriv "$ifname" countryie "$countryie"

    case "$enc" in
            none)
                # We start hostapd in open mode also
                start_hostapd=1
            ;;
            wep*)
                case "$enc" in
                    *mixed*)  iwpriv "$ifname" authmode 4;;
                    *shared*) iwpriv "$ifname" authmode 2;;
                    *)        iwpriv "$ifname" authmode 1;;
                esac
                for idx in 1 2 3 4; do
                    config_get key "$vif" "key${idx}"
                    [ -n "$key" ] && iwconfig "$ifname"  enc "[$idx]" "$key"
                done
                config_get key "$vif" key
                key="${key:-1}"
                case "$key" in
                    [1234]) iwconfig "$ifname" enc "[$key]";;
                    *) iwconfig "$ifname" enc "$key";;
                esac
            ;;
            mixed*|psk*|wpa*|8021x)
                start_hostapd=1
                config_get key "$vif" key
            ;;
            wapi*)
                start_wapid=1
                config_get key "$vif" key
            ;;
    esac

    case "$mode" in
            sta|adhoc)
                config_get addr "$vif" bssid
                [ -z "$addr" ] || {
                    iwconfig "$ifname" ap "$addr"
                }
            ;;
    esac

    config_get_bool uapsd "$vif" uapsd 1
    iwpriv "$ifname" uapsd "$uapsd"

    config_get mcast_rate "$vif" mcast_rate
    [ -n "$mcast_rate" ] && iwpriv "$ifname" mcast_rate "${mcast_rate%%.*}"

    config_get powersave "$vif" powersave
    [ -n "$powersave" ] && iwpriv "$ifname" powersave "${powersave}"

    config_get_bool ant_ps_on "$vif" ant_ps_on
    [ -n "$ant_ps_on" ] && iwpriv "$ifname" ant_ps_on "${ant_ps_on}"

    config_get ps_timeout "$vif" ps_timeout
    [ -n "$ps_timeout" ] && iwpriv "$ifname" ps_timeout "${ps_timeout}"

    config_get mcastenhance "$vif" mcastenhance
    [ -n "$mcastenhance" ] && iwpriv "$ifname" mcastenhance "${mcastenhance}"

    config_get disable11nmcs "$vif" disable11nmcs
    [ -n "$disable11nmcs" ] && iwpriv "$ifname" disable11nmcs "${disable11nmcs}"

    config_get conf_11acmcs "$vif" conf_11acmcs
    [ -n "$conf_11acmcs" ] && iwpriv "$ifname" conf_11acmcs "${conf_11acmcs}"

    config_get metimer "$vif" metimer
    [ -n "$metimer" ] && iwpriv "$ifname" metimer "${metimer}"

    config_get metimeout "$vif" metimeout
    [ -n "$metimeout" ] && iwpriv "$ifname" metimeout "${metimeout}"

    config_get_bool medropmcast "$vif" medropmcast
    [ -n "$medropmcast" ] && iwpriv "$ifname" medropmcast "${medropmcast}"

    config_get me_adddeny "$vif" me_adddeny
    [ -n "$me_adddeny" ] && iwpriv "$ifname" me_adddeny ${me_adddeny}

    #support independent repeater mode
    config_get vap_ind "$vif" vap_ind
    [ -n "$vap_ind" ] && iwpriv "$ifname" vap_ind "${vap_ind}"

    #support extender ap & STA
    config_get extap "$vif" extap
    [ -n "$extap" ] && iwpriv "$ifname" extap "${extap}"
	
	config_get beeliner_fw_test "$vif" beeliner_fw_test
	[ -n "$beeliner_fw_test" ] && wifitool "$ifname" beeliner_fw_test "${beeliner_fw_test}" 0

    config_get scanband "$vif" scanband
    [ -n "$scanband" ] && iwpriv "$ifname" scanband "${scanband}"

    config_get periodicScan "$vif" periodicScan
    [ -n "$periodicScan" ] && iwpriv "$ifname" periodicScan "${periodicScan}"

    config_get frag "$vif" frag
    [ -n "$frag" ] && iwconfig "$ifname" frag "${frag%%.*}"

#    config_get rts "$vif" rts
#    [ -n "$rts" ] && iwconfig "$ifname" rts "${rts%%.*}"

    config_get cwmin "$vif" cwmin
    [ -n "$cwmin" ] && iwpriv "$ifname" cwmin ${cwmin}

    config_get cwmax "$vif" cwmax
    [ -n "$cwmax" ] && iwpriv "$ifname" cwmax ${cwmax}

    config_get aifs "$vif" aifs
    [ -n "$aifs" ] && iwpriv "$ifname" aifs ${aifs}

    config_get txoplimit "$vif" txoplimit
    [ -n "$txoplimit" ] && iwpriv "$ifname" txoplimit ${txoplimit}

    config_get noackpolicy "$vif" noackpolicy
    [ -n "$noackpolicy" ] && iwpriv "$ifname" noackpolicy ${noackpolicy}

    config_get_bool wmm "$vif" wmm
    [ -n "$wmm" ] && iwpriv "$ifname" wmm "$wmm"

    config_get_bool doth "$vif" doth
    [ -n "$doth" ] && iwpriv "$ifname" doth "$doth"

    config_get doth_chanswitch "$vif" doth_chanswitch
    [ -n "$doth_chanswitch" ] && iwpriv "$ifname" doth_chanswitch ${doth_chanswitch}

    config_get quiet "$vif" quiet
    [ -n "$quiet" ] && iwpriv "$ifname" quiet "$quiet"

    config_get mfptest "$vif" mfptest
    [ -n "$mfptest" ] && iwpriv "$ifname" mfptest "$mfptest"

    config_get dtim_period "$vif" dtim_period
    [ -n "$dtim_period" ] && iwpriv "$ifname" dtim_period "$dtim_period"

    config_get noedgech "$vif" noedgech
    [ -n "$noedgech" ] && iwpriv "$ifname" noedgech "$noedgech"

    config_get ps_on_time "$vif" ps_on_time
    [ -n "$ps_on_time" ] && iwpriv "$ifname" ps_on_time "$ps_on_time"

    config_get inact "$vif" inact
    [ -n "$inact" ] && iwpriv "$ifname" inact "$inact"

    config_get wnm "$vif" wnm
    [ -n "$wnm" ] && iwpriv "$ifname" wnm "$wnm"

    config_get mbo "$vif" mbo
    [ -n "$mbo" ] && iwpriv "$ifname" mbo "$mbo"

    config_get enable_fils  "$vif" ieee80211ai
    config_get fils_discovery_period  "$vif" fils_fd_period 0
    [ -n "$enable_fils" ] && iwpriv "$ifname" enable_fils "$enable_fils" "$fils_discovery_period"

    config_get bpr_enable  "$vif" bpr_enable
    [ -n "$bpr_enable" ] && iwpriv "$ifname" set_bpr_enable "$bpr_enable"

    config_get oce "$vif" oce
     [ -n "$oce" ] && iwpriv "$ifname" oce "$oce"
    [ "$oce" -gt 0 ] && {
            case "$hwmode" in
                11B*|11G*|11NG*)
                    iwpriv "$ifname" set_bcn_rate 5500
                    iwpriv "$ifname" prb_rate 5500
                    ;;
                *)
                    ;;
            esac

            [ -z "$enable_fils" ] && iwpriv "$ifname" enable_fils 1 20
    }

    config_get ampdu "$vif" ampdu
    [ -n "$ampdu" ] && iwpriv "$ifname" ampdu "$ampdu"

    config_get amsdu "$vif" amsdu
    [ -n "$amsdu" ] && iwpriv "$ifname" amsdu "$amsdu"

    config_get maxampdu "$vif" maxampdu
    [ -n "$maxampdu" ] && iwpriv "$ifname" maxampdu "$maxampdu"

    config_get vhtmaxampdu "$vif" vhtmaxampdu
    [ -n "$vhtmaxampdu" ] && iwpriv "$ifname" vhtmaxampdu "$vhtmaxampdu"

    config_get setaddbaoper "$vif" setaddbaoper
    [ -n "$setaddbaoper" ] && iwpriv "$ifname" setaddbaoper "$setaddbaoper"

    config_get addbaresp "$vif" addbaresp
    [ -n "$addbaresp" ] && iwpriv "$ifname" $addbaresp

    config_get addba "$vif" addba
    [ -n "$addba" ] && iwpriv "$ifname" addba $addba

    config_get delba "$vif" delba
    [ -n "$delba" ] && iwpriv "$ifname" delba $delba

    config_get_bool stafwd "$vif" stafwd 0
    [ -n "$stafwd" ] && iwpriv "$ifname" stafwd "$stafwd"

    config_get maclist "$vif" maclist
    [ -n "$maclist" ] && {
            # flush MAC list
            iwpriv "$ifname" maccmd 3
            for mac in $maclist; do
            iwpriv "$ifname" addmac "$mac"
            done
    }

    config_get macfilter "$vif" macfilter
    case "$macfilter" in
            allow)
                iwpriv "$ifname" maccmd 1
                ;;
            deny)
                iwpriv "$ifname" maccmd 2
                ;;
            *)
                # default deny policy if mac list exists
                 [ -n "$maclist" ] && iwpriv "$ifname" maccmd 2
                ;;
    esac
    
    #add to support macfilter_sec
    config_get macfilter_sec "$vif" macfilter_sec
    case "$macfilter_sec" in
        allow)
            iwpriv "$ifname" maccmd_sec 1
        ;;
        deny)
            [ -n "$maclist_sec" ] && {
                # flush MAC list
                iwpriv "$ifname" maccmd_sec 3
                for mac in $maclist_sec; do
                    iwpriv "$ifname" addmac_sec "$mac"
                done
            }
            iwpriv "$ifname" maccmd_sec 2
        ;;
    esac

    config_get nss "$vif" nss
    [ -n "$nss" ] && iwpriv "$ifname" nss "$nss"

    config_get vht_mcsmap "$vif" vht_mcsmap
    [ -n "$vht_mcsmap" ] && iwpriv "$ifname" vht_mcsmap "$vht_mcsmap"

    config_get chwidth "$vif" chwidth
    [ -n "$chwidth" ] && iwpriv "$ifname" chwidth "$chwidth"

    config_get chbwmode "$vif" chbwmode
    [ -n "$chbwmode" ] && iwpriv "$ifname" chbwmode "$chbwmode"

    config_get ldpc "$vif" ldpc
    [ -n "$ldpc" ] && iwpriv "$ifname" ldpc "$ldpc"

    config_get rx_stbc "$vif" rx_stbc
    [ -n "$rx_stbc" ] && iwpriv "$ifname" rx_stbc "$rx_stbc"

    config_get tx_stbc "$vif" tx_stbc
    [ -n "$tx_stbc" ] && iwpriv "$ifname" tx_stbc "$tx_stbc"

    config_get cca_thresh "$vif" cca_thresh
    [ -n "$cca_thresh" ] && iwpriv "$ifname" cca_thresh "$cca_thresh"

    config_get set11NRetries "$vif" set11NRetries
    [ -n "$set11NRetries" ] && iwpriv "$ifname" set11NRetries "$set11NRetries"

    config_get chanbw "$vif" chanbw
    [ -n "$chanbw" ] && iwpriv "$ifname" chanbw "$chanbw"

    local maxsta
    #config_get maxsta "$vif" maxsta
    [ "$band" = "5g" -o "$band" = "2g" ] && {
            maxsta=$(uci get profile.@wireless[0].max_sta_number_$band -c /etc/profile.d)
    }
    [ -n "$maxsta" ] && iwpriv "$ifname" maxsta "$maxsta"

    config_get sko_max_xretries "$vif" sko_max_xretries
    if [ -n "$sko_max_xretries" ]; then
        iwpriv "$ifname" wnm 0
        iwpriv "$ifname" sko "$sko_max_xretries"
    	iwpriv "$ifname" wnm 1
    fi

    config_get extprotmode "$vif" extprotmode
    [ -n "$extprotmode" ] && iwpriv "$ifname" extprotmode "$extprotmode"

    config_get extprotspac "$vif" extprotspac
    [ -n "$extprotspac" ] && iwpriv "$ifname" extprotspac "$extprotspac"

    config_get_bool cwmenable "$vif" cwmenable
    [ -n "$cwmenable" ] && iwpriv "$ifname" cwmenable "$cwmenable"

    config_get_bool protmode "$vif" protmode
    [ -n "$protmode" ] && iwpriv "$ifname" protmode "$protmode"

    config_get enablertscts "$vif" enablertscts
    [ -n "$enablertscts" ] && iwpriv "$ifname" enablertscts "$enablertscts"

    config_get txcorrection "$vif" txcorrection
    [ -n "$txcorrection" ] && iwpriv "$ifname" txcorrection "$txcorrection"

    config_get rxcorrection "$vif" rxcorrection
    [ -n "$rxcorrection" ] && iwpriv "$ifname" rxcorrection "$rxcorrection"

    config_get vsp_enable "$vif" vsp_enable
    [ -n "$vsp_enable" ] && iwpriv "$ifname" vsp_enable "$vsp_enable"    
    
    config_get ssid "$vif" ssid
    [ -n "$ssid" ] && {
        iwconfig "$ifname" essid on
        iwconfig "$ifname" essid ${ssid:+-- }"$ssid"
    }

    config_get txqueuelen "$vif" txqueuelen
    [ -n "$txqueuelen" ] && ifconfig "$ifname" txqueuelen "$txqueuelen"

    net_cfg="$(find_net_config "$vif")"

    config_get mtu $net_cfg mtu

    [ -n "$mtu" ] && {
        config_set "$vif" mtu $mtu
        ifconfig "$ifname" mtu $mtu
    }

    config_get tdls "$vif" tdls
    [ -n "$tdls" ] && iwpriv "$ifname" tdls "$tdls"

    config_get set_tdls_rmac "$vif" set_tdls_rmac
    [ -n "$set_tdls_rmac" ] && iwpriv "$ifname" set_tdls_rmac "$set_tdls_rmac"

    config_get tdls_qosnull "$vif" tdls_qosnull
    [ -n "$tdls_qosnull" ] && iwpriv "$ifname" tdls_qosnull "$tdls_qosnull"

    config_get tdls_uapsd "$vif" tdls_uapsd
    [ -n "$tdls_uapsd" ] && iwpriv "$ifname" tdls_uapsd "$tdls_uapsd"

    config_get tdls_set_rcpi "$vif" tdls_set_rcpi
    [ -n "$tdls_set_rcpi" ] && iwpriv "$ifname" set_rcpi "$tdls_set_rcpi"

    config_get tdls_set_rcpi_hi "$vif" tdls_set_rcpi_hi
    [ -n "$tdls_set_rcpi_hi" ] && iwpriv "$ifname" set_rcpihi "$tdls_set_rcpi_hi"

    config_get tdls_set_rcpi_lo "$vif" tdls_set_rcpi_lo
    [ -n "$tdls_set_rcpi_lo" ] && iwpriv "$ifname" set_rcpilo "$tdls_set_rcpi_lo"

    config_get tdls_set_rcpi_margin "$vif" tdls_set_rcpi_margin
    [ -n "$tdls_set_rcpi_margin" ] && iwpriv "$ifname" set_rcpimargin "$tdls_set_rcpi_margin"

    config_get tdls_dtoken "$vif" tdls_dtoken
    [ -n "$tdls_dtoken" ] && iwpriv "$ifname" tdls_dtoken "$tdls_dtoken"

    config_get do_tdls_dc_req "$vif" do_tdls_dc_req
    [ -n "$do_tdls_dc_req" ] && iwpriv "$ifname" do_tdls_dc_req "$do_tdls_dc_req"

    config_get tdls_auto "$vif" tdls_auto
    [ -n "$tdls_auto" ] && iwpriv "$ifname" tdls_auto "$tdls_auto"

    config_get tdls_off_timeout "$vif" tdls_off_timeout
    [ -n "$tdls_off_timeout" ] && iwpriv "$ifname" off_timeout "$tdls_off_timeout"

    config_get tdls_tdb_timeout "$vif" tdls_tdb_timeout
    [ -n "$tdls_tdb_timeout" ] && iwpriv "$ifname" tdb_timeout "$tdls_tdb_timeout"

    config_get tdls_weak_timeout "$vif" tdls_weak_timeout
    [ -n "$tdls_weak_timeout" ] && iwpriv "$ifname" weak_timeout "$tdls_weak_timeout"

    config_get tdls_margin "$vif" tdls_margin
    [ -n "$tdls_margin" ] && iwpriv "$ifname" tdls_margin "$tdls_margin"

    config_get tdls_rssi_ub "$vif" tdls_rssi_ub
    [ -n "$tdls_rssi_ub" ] && iwpriv "$ifname" tdls_rssi_ub "$tdls_rssi_ub"

    config_get tdls_rssi_lb "$vif" tdls_rssi_lb
    [ -n "$tdls_rssi_lb" ] && iwpriv "$ifname" tdls_rssi_lb "$tdls_rssi_lb"

    config_get tdls_path_sel "$vif" tdls_path_sel
    [ -n "$tdls_path_sel" ] && iwpriv "$ifname" tdls_pathSel "$tdls_path_sel"

    config_get tdls_rssi_offset "$vif" tdls_rssi_offset
    [ -n "$tdls_rssi_offset" ] && iwpriv "$ifname" tdls_rssi_o "$tdls_rssi_offset"

    config_get tdls_path_sel_period "$vif" tdls_path_sel_period
    [ -n "$tdls_path_sel_period" ] && iwpriv "$ifname" tdls_pathSel_p "$tdls_path_sel_period"

    config_get tdlsmacaddr1 "$vif" tdlsmacaddr1
    [ -n "$tdlsmacaddr1" ] && iwpriv "$ifname" tdlsmacaddr1 "$tdlsmacaddr1"

    config_get tdlsmacaddr2 "$vif" tdlsmacaddr2
    [ -n "$tdlsmacaddr2" ] && iwpriv "$ifname" tdlsmacaddr2 "$tdlsmacaddr2"

    config_get tdlsaction "$vif" tdlsaction
    [ -n "$tdlsaction" ] && iwpriv "$ifname" tdlsaction "$tdlsaction"

    config_get tdlsoffchan "$vif" tdlsoffchan
    [ -n "$tdlsoffchan" ] && iwpriv "$ifname" tdlsoffchan "$tdlsoffchan"

    config_get tdlsswitchtime "$vif" tdlsswitchtime
    [ -n "$tdlsswitchtime" ] && iwpriv "$ifname" tdlsswitchtime "$tdlsswitchtime"

    config_get tdlstimeout "$vif" tdlstimeout
    [ -n "$tdlstimeout" ] && iwpriv "$ifname" tdlstimeout "$tdlstimeout"

    config_get tdlsecchnoffst "$vif" tdlsecchnoffst
    [ -n "$tdlsecchnoffst" ] && iwpriv "$ifname" tdlsecchnoffst "$tdlsecchnoffst"

    config_get tdlsoffchnmode "$vif" tdlsoffchnmode
    [ -n "$tdlsoffchnmode" ] && iwpriv "$ifname" tdlsoffchnmode "$tdlsoffchnmode"

    config_get_bool blockdfschan "$vif" blockdfschan
    [ -n "$blockdfschan" ] && iwpriv "$ifname" blockdfschan "$blockdfschan"

    config_get dbgLVL "$vif" dbgLVL
    [ -n "$dbgLVL" ] && iwpriv "$ifname" dbgLVL "$dbgLVL"

    config_get acsmindwell "$vif" acsmindwell
    [ -n "$acsmindwell" ] && iwpriv "$ifname" acsmindwell "$acsmindwell"

    config_get acsmaxdwell "$vif" acsmaxdwell
    [ -n "$acsmaxdwell" ] && iwpriv "$ifname" acsmaxdwell "$acsmaxdwell"

    config_get acsreport "$vif" acsreport
    [ -n "$acsreport" ] && iwpriv "$ifname" acsreport "$acsreport"

    config_get ch_hop_en "$vif" ch_hop_en
    [ -n "$ch_hop_en" ] && iwpriv "$ifname" ch_hop_en "$ch_hop_en"

    config_get ch_long_dur "$vif" ch_long_dur
    [ -n "$ch_long_dur" ] && iwpriv "$ifname" ch_long_dur "$ch_long_dur"

    config_get ch_nhop_dur "$vif" ch_nhop_dur
    [ -n "$ch_nhop_dur" ] && iwpriv "$ifname" ch_nhop_dur "$ch_nhop_dur"

    config_get ch_cntwn_dur "$vif" ch_cntwn_dur
    [ -n "$ch_cntwn_dur" ] && iwpriv "$ifname" ch_cntwn_dur "$ch_cntwn_dur"

    config_get ch_noise_th "$vif" ch_noise_th
    [ -n "$ch_noise_th" ] && iwpriv "$ifname" ch_noise_th "$ch_noise_th"

    config_get ch_cnt_th "$vif" ch_cnt_th
    [ -n "$ch_cnt_th" ] && iwpriv "$ifname" ch_cnt_th "$ch_cnt_th"

    config_get_bool scanchevent "$vif" scanchevent
    [ -n "$scanchevent" ] && iwpriv "$ifname" scanchevent "$scanchevent"

    config_get_bool send_add_ies "$vif" send_add_ies
    [ -n "$send_add_ies" ] && iwpriv "$ifname" send_add_ies "$send_add_ies"

    config_get_bool ext_ifu_acs "$vif" ext_ifu_acs
    [ -n "$ext_ifu_acs" ] && iwpriv "$ifname" ext_ifu_acs "$ext_ifu_acs"

    config_get_bool enable_rtt "$vif" enable_rtt
    [ -n "$enable_rtt" ] && iwpriv "$ifname" enable_rtt "$enable_rtt"

    config_get_bool enable_lci "$vif" enable_lci
    [ -n "$enable_lci" ] && iwpriv "$ifname" enable_lci "$enable_lci"

    config_get_bool enable_lcr "$vif" enable_lcr
    [ -n "$enable_lcr" ] && iwpriv "$ifname" enable_lcr "$enable_lcr"

    config_get_bool rrm "$vif" rrm
    [ -n "$rrm" ] && iwpriv "$ifname" rrm "$rrm"

    config_get_bool rrmslwin "$vif" rrmslwin
    [ -n "$rrmslwin" ] && iwpriv "$ifname" rrmslwin "$rrmslwin"

    config_get_bool rrmstats "$vif" rrmsstats
    [ -n "$rrmstats" ] && iwpriv "$ifname" rrmstats "$rrmstats"

    config_get rrmdbg "$vif" rrmdbg
    [ -n "$rrmdbg" ] && iwpriv "$ifname" rrmdbg "$rrmdbg"

    config_get acparams "$vif" acparams
    [ -n "$acparams" ] && iwpriv "$ifname" acparams $acparams

    config_get setwmmparams "$vif" setwmmparams
    [ -n "$setwmmparams" ] && iwpriv "$ifname" setwmmparams $setwmmparams

    config_get_bool qbssload "$vif" qbssload
    [ -n "$qbssload" ] && iwpriv "$ifname" qbssload "$qbssload"

    config_get_bool proxyarp "$vif" proxyarp
    [ -n "$proxyarp" ] && iwpriv "$ifname" proxyarp "$proxyarp"

    config_get_bool dgaf_disable "$vif" dgaf_disable
    [ -n "$dgaf_disable" ] && iwpriv "$ifname" dgaf_disable "$dgaf_disable"

    config_get setibssdfsparam "$vif" setibssdfsparam
    [ -n "$setibssdfsparam" ] && iwpriv "$ifname" setibssdfsparam "$setibssdfsparam"

    config_get startibssrssimon "$vif" startibssrssimon
    [ -n "$startibssrssimon" ] && iwpriv "$ifname" startibssrssimon "$startibssrssimon"

    config_get setibssrssihyst "$vif" setibssrssihyst
    [ -n "$setibssrssihyst" ] && iwpriv "$ifname" setibssrssihyst "$setibssrssihyst"

    config_get noIBSSCreate "$vif" noIBSSCreate
    [ -n "$noIBSSCreate" ] && iwpriv "$ifname" noIBSSCreate "$noIBSSCreate"

    config_get setibssrssiclass "$vif" setibssrssiclass
    [ -n "$setibssrssiclass" ] && iwpriv "$ifname" setibssrssiclass $setibssrssiclass

    config_get offchan_tx_test "$vif" offchan_tx_test
    [ -n "$offchan_tx_test" ] && iwpriv "$ifname" offchan_tx_test $offchan_tx_test

    handle_vow_dbg_cfg() {
            local value="$1"
            [ -n "$value" ] && iwpriv "$ifname" vow_dbg_cfg $value
    }

    config_list_foreach "$vif" vow_dbg_cfg handle_vow_dbg_cfg

    config_get_bool vow_dbg "$vif" vow_dbg
    [ -n "$vow_dbg" ] && iwpriv "$ifname" vow_dbg "$vow_dbg"

    handle_set_max_rate() {
            local value="$1"
            [ -n "$value" ] && wlanconfig "$ifname" set_max_rate $value
    }
    config_list_foreach "$vif" set_max_rate handle_set_max_rate

    config_get_bool implicitbf "$vif" implicitbf
    [ -n "$implicitbf" ] && iwpriv "$ifname" implicitbf "${implicitbf}"

    config_get_bool vhtsubfee "$vif" vhtsubfee
    [ -n "$vhtsubfee" ] && iwpriv "$ifname" vhtsubfee "${vhtsubfee}"

    config_get_bool vhtmubfee "$vif" vhtmubfee
    [ -n "$vhtmubfee" ] && iwpriv "$ifname" vhtmubfee "${vhtmubfee}"

    config_get_bool vhtsubfer "$vif" vhtsubfer
    [ -n "$vhtsubfer" ] && iwpriv "$ifname" vhtsubfer "${vhtsubfer}"

    config_get_bool vhtmubfer "$vif" vhtmubfer
    [ -n "$vhtmubfer" ] && iwpriv "$ifname" vhtmubfer "${vhtmubfer}"

    config_get vhtstscap "$vif" vhtstscap
    [ -n "$vhtstscap" ] && iwpriv "$ifname" vhtstscap "${vhtstscap}"

    config_get vhtsounddim "$vif" vhtsounddim
    [ -n "$vhtsounddim" ] && iwpriv "$ifname" vhtsounddim "${vhtsounddim}"

    config_get encap_type "$vif" encap_type
    [ -n "$encap_type" ] && iwpriv "$ifname" encap_type "${encap_type}"

    config_get decap_type "$vif" decap_type
    [ -n "$decap_type" ] && iwpriv "$ifname" decap_type "${decap_type}"

    config_get_bool rawsim_txagr "$vif" rawsim_txagr
    [ -n "$rawsim_txagr" ] && iwpriv "$ifname" rawsim_txagr "${rawsim_txagr}"

    config_get clr_rawsim_stats "$vif" clr_rawsim_stats
    [ -n "$clr_rawsim_stats" ] && iwpriv "$ifname" clr_rawsim_stats "${clr_rawsim_stats}"

    config_get_bool rawsim_debug "$vif" rawsim_debug
    [ -n "$rawsim_debug" ] && iwpriv "$ifname" rawsim_debug "${rawsim_debug}"

    config_get set_monrxfilter "$vif" set_monrxfilter
    [ -n "$set_monrxfilter" ] && iwpriv "$ifname" set_monrxfilter "${set_monrxfilter}"

    config_get neighbourfilter "$vif" neighbourfilter
    [ -n "$neighbourfilter" ] && iwpriv "$ifname" neighbourfilter "${neighbourfilter}"

    config_get athnewind "$vif" athnewind
    [ -n "$athnewind" ] && iwpriv "$ifname" athnewind "$athnewind"

    config_get osen "$vif" osen
    [ -n "$osen" ] && iwpriv "$ifname" osen "$osen"

    config_get re_scalingfactor "$vif" re_scalingfactor
    [ -n "$re_scalingfactor" ] && iwpriv "$ifname" set_whc_sfactor "$re_scalingfactor"

    config_get root_distance "$vif" root_distance
    [ -n "$root_distance" ] && iwpriv "$ifname" set_whc_dist "$root_distance"

    config_get caprssi "$vif" caprssi
    [ -n "$caprssi" ] && iwpriv "$ifname" caprssi "${caprssi}"
        
    config_get_bool ap_isolation_enabled $device ap_isolation_enabled 0
    config_get_bool isolate "$vif" isolate 0

    if [ $ap_isolation_enabled -ne 0 ]; then
            [ "$mode" = "wrap" ] && isolate=1
    fi

    config_get_bool ctsprt_dtmbcn "$vif" ctsprt_dtmbcn
    [ -n "$ctsprt_dtmbcn" ] && iwpriv "$ifname" ctsprt_dtmbcn "${ctsprt_dtmbcn}"

    config_get assocwar160  "$vif" assocwar160
    [ -n "$assocwar160" ] && iwpriv "$ifname" assocwar160 "$assocwar160"

    config_get rawdwepind "$vif" rawdwepind
    [ -n "$rawdwepind" ] && iwpriv "$ifname" rawdwepind "$rawdwepind"

    config_get revsig160  "$vif" revsig160
    [ -n "$revsig160" ] && iwpriv "$ifname" revsig160 "$revsig160"
    

    config_get channel_block_list "$vif" channel_block_list
    [ -n "$channel_block_list" ] && wifitool "$ifname" block_acs_channel "$channel_block_list"

    radio_5g_sid=$(getfirm SPECIAL_ID)
    if [ "$device" = "wifi1" -a "$country" != "ID" -a "$mode" = "ap" ]; then
        if [ "$radio_5g_sid" == "42340000" ]; then
	        wifitool "$ifname" block_acs_channel "36,40,44,48,165"
	    else
	        wifitool "$ifname" block_acs_channel "149,153,157,161,165"
	    fi
    fi

    config_get rept_spl  "$vif" rept_spl
    [ -n "$rept_spl" ] && iwpriv "$ifname" rept_spl "$rept_spl"

    config_get cactimeout  "$vif" cactimeout
    [ -n "$cactimeout" ] && iwpriv "$ifname" set_cactimeout "$cactimeout"
    
    config_get global_wds qcawifi global_wds

    if [ $global_wds -ne 0 ]; then
        iwpriv "$ifname" athnewind 1
    fi

    config_get pref_uplink "$device" pref_uplink
    [ -n "$pref_uplink" ] && iwpriv "$phy" pref_uplink "${pref_uplink}"

    config_get fast_lane "$device" fast_lane
    [ -n "$fast_lane" ] && iwpriv "$phy" fast_lane "${fast_lane}"

    if [ $fast_lane -ne 0 ]; then
        iwpriv "$ifname" athnewind 1
    fi


    local net_cfg 
    local bridge=
    net_cfg="$(find_net_config "$vif")"
    [ -z "$net_cfg" -o "$isolate" = 1 -a "$mode" = "wrap" ] || {
        [ -f /sys/class/net/${ifname}/parent ] &&  [ "$net_cfg" != "backhaul" ] && { \
        bridge="$(bridge_interface "$net_cfg")"
        config_set "$vif" bridge "$bridge"
        }
    }

       
        case "$mode" in
            ap|wrap|ap_monitor|ap_smart_monitor|mesh|ap_lp_iot|ap_guest)


                iwpriv "$ifname" ap_bridge "$((isolate^1))"

                config_get_bool l2tif "$vif" l2tif
                [ -n "$l2tif" ] && iwpriv "$ifname" l2tif "$l2tif"
            ;;

        esac


    create_process "$vif" "$mode" "$bridge" "$start_hostapd" "$start_wapid"
    
    [ -z "$bridge" -o "$isolate" = 1 -a "$mode" = "wrap" ] || {
        [ -f /sys/class/net/${ifname}/parent ] && { \
                start_net "$ifname" "$net_cfg"
        }
    }    

    config_get set11NRates "$vif" set11NRates
    [ -n "$set11NRates" ] && iwpriv "$ifname" set11NRates "$set11NRates"

    # 256 QAM capability needs to be parsed first, since
    # vhtmcs enables/disable rate indices 8, 9 for 2G
    # only if vht_11ng is set or not
    config_get_bool vht_11ng "$vif" vht_11ng
    [ -n "$vht_11ng" ] && iwpriv "$ifname" vht_11ng "$vht_11ng"

    config_get_bool ngvhtintop "$vif" ngvhtintop
    [ -n "$ngvhtintop" ] && iwpriv "$ifname" 11ngvhtintop "$ngvhtintop"

    config_get vhtmcs "$vif" vhtmcs
    [ -n "$vhtmcs" ] && iwpriv "$ifname" vhtmcs "$vhtmcs"

    config_get dis_legacy "$vif" dis_legacy
    [ -n "$dis_legacy" ] && iwpriv "$ifname" dis_legacy "$dis_legacy"

    config_get set_bcn_rate "$vif" set_bcn_rate
    [ -n "$set_bcn_rate" ] && iwpriv "$ifname" set_bcn_rate "$set_bcn_rate"

    #support nawds
    config_get nawds_mode "$vif" nawds_mode
    [ -n "$nawds_mode" ] && wlanconfig "$ifname" nawds mode "${nawds_mode}"

    handle_nawds() {
            local value="$1"
            [ -n "$value" ] && wlanconfig "$ifname" nawds add-repeater $value
    }
    config_list_foreach "$vif" nawds_add_repeater handle_nawds

    handle_hmwds() {
            local value="$1"
            [ -n "$value" ] && wlanconfig "$ifname" hmwds add_addr $value
    }
    config_list_foreach "$vif" hmwds_add_addr handle_hmwds

    config_get nawds_override "$vif" nawds_override
    [ -n "$nawds_override" ] && wlanconfig "$ifname" nawds override "${nawds_override}"

    config_get nawds_defcaps "$vif" nawds_defcaps
    [ -n "$nawds_defcaps" ] && wlanconfig "$ifname" nawds defcaps "${nawds_defcaps}"

    handle_hmmc_add() {
            local value="$1"
            [ -n "$value" ] && wlanconfig "$ifname" hmmc add $value
    }
    config_list_foreach "$vif" hmmc_add handle_hmmc_add

    # TXPower settings only work if device is up already
    # while atheros hardware theoretically is capable of per-vif (even per-packet) txpower
    # adjustment it does not work with the current atheros hal/madwifi driver

    config_get vif_txpower "$vif" txpower
    # use vif_txpower (from wifi-iface) instead of txpower (from wifi-device) if
    # the latter doesn't exist
    txpower="${txpower:-$vif_txpower}"
    [ -z "$txpower" ] || iwconfig "$ifname" txpower "${txpower%%.*}"
    
    if [ $enable_rps_wifi == 1 ] && [ -f "/lib/update_system_params.sh" ]; then
            . /lib/update_system_params.sh
            enable_rps $ifname
    fi

    #share wifi1 process to cpu0,1,3
    #if [ "wifi1" = "$device" ]; then
    #        echo 3 > /sys/devices/virtual/net/${ifname}/queues/rx-0/rps_cpus
    #fi
    
}



up_all_vap() {
    local vlanid=3 gvlan=2
    local start_hostapd= start_wapid=
    #local brchanged=0
    tpdbg "up_all_vap" >/dev/console
    for dev in $DEVICES; do
        config_get dev_disabled "$dev" disabled   
        #[ "$dev_disabled" = "1" ] && continue
        for vif in $(config_get "$dev" vifs); do 
            if [ -d /sys/class/net/$vif ]; then
                local brname=
                config_get disabled "$vif" disabled
                net_cfg="$(find_net_config "$vif")"
                [ -n "$net_cfg" ] && [ "$net_cfg" != "backhaul" ] && brname="$(bridge_interface "$net_cfg")" 
                [ "$disabled" = "1" -o "$dev_disabled" = "1" ] && {
                    [ -d /sys/class/net/$vif/master ] && [ -n "$brname" ] && {
                        brctl delif $brname $vif
                        [ "$?" = "0" ] && brchanged=1
                    }
                    continue
                }
                
                local up=$(uci_get_state wireless.$vif.up)
                [ "$up" = "1" ] || {                          
                    config_get mode "$vif" mode
                    config_get enc "$vif" encryption "none" 
                    case "$enc" in
                        none)
                            # We start hostapd in open mode also
                            start_hostapd=1
                            ;;
                        mixed*|psk*|wpa*|8021x)
                            start_hostapd=1
                            ;;
                        wapi*)
                            start_wapid=1
                            ;;
                    esac 
                 
                    create_process "$vif" "$mode" "$brname" "$start_hostapd" "$start_wapid" 
                 }
                 
                 ifconfig "$vif" up
                 set_wifi_up "$vif" "$vif"
             fi
        done
    done
    
    [ "$brchanged" = "1" ] && [ -f /etc/init.d/hyd ] && /etc/init.d/hyd restart
}


config_vap() {
    local vif="$1" action="$2" start_hostapd= start_wapid= hasvif=
    local net_cfg= brname=
    local mode phy disabled

    [ -z "$vif" ] && return
    config_get mode "$vif" mode
    config_get phy "$vif" device
    config_get disabled "$vif" disabled 0
    
    config_get ifname "$vif" vapname

    [ -z "$mode" -o -z "phy" ] && return
    config_get dev_disabled "$phy" disabled 
 
    tpdbg "config_vap vif:$vif disabled:$disabled"
    [ -d /sys/class/net/$vif ] && hasvif="1"
    [ -n "$hasvif" ] && down_vap $vif
    [ "$disabled" = "1" ] && {
        return
    }
       

    [ -z "$hasvif" -o "$action" = "reload" ] && create_vap "$vif" "$phy" "$mode" &>$STDOUT && return 0   
    config_get_bool isolate "$vif" isolate 0
    [ -n "$isolate" ] && iwpriv "$ifname" ap_bridge "$((isolate^1))"
    
    config_get ssid "$vif" ssid
    if [ -n "$ssid" ]; then
        iwconfig "$vif" essid on
        iwconfig "$vif" essid ${ssid:+-- }"$ssid"
    else
        iwconfig "$vif" essid off
    fi

    config_get_bool vhtsubfee "$vif" vhtsubfee
    [ -n "$vhtsubfee" ] && iwpriv "$ifname" vhtsubfee "${vhtsubfee}"

    config_get_bool vhtmubfee "$vif" vhtmubfee
    [ -n "$vhtmubfee" ] && iwpriv "$ifname" vhtmubfee "${vhtmubfee}"
    
    config_get_bool vhtsubfer "$vif" vhtsubfer
    [ -n "$vhtsubfer" ] && iwpriv "$ifname" vhtsubfer "${vhtsubfer}"

    config_get_bool vhtmubfer "$vif" vhtmubfer
    [ -n "$vhtmubfer" ] && iwpriv "$ifname" vhtmubfer "${vhtmubfer}"

    config_get_bool hidden "$vif" hidden 0
    iwpriv "$vif" hide_ssid "$hidden"
    
    #clear encryption
    #iwpriv "$vif" authmode 1
    #iwconfig "$vif" enc off
    #iwconfig "$vif" key off

    config_get enc "$vif" encryption "none"
    case "$enc" in
        none)
            start_hostapd=1
        ;;
        wep*)
            case "$enc" in
                *mixed*)  iwpriv "$vif" authmode 4;;
                *shared*) iwpriv "$vif" authmode 2;;
                *)        iwpriv "$vif" authmode 1;;
            esac
            for idx in 1 2 3 4; do
                config_get key "$vif" "key${idx}"
                iwconfig "$vif" enc "[$idx]" "${key:-off}"
            done
            config_get key "$vif" key
            key="${key:-1}"
            case "$key" in
                [1234]) iwconfig "$vif" enc "[$key]";;
                *) iwconfig "$vif" enc "$key";;
            esac
        ;;
        mixed*|psk*|wpa*|8021x)
            start_hostapd=1
        ;;
        wapi*)
            start_wapid=1
        ;;        
    esac
      
    if [ "$mode" == "sta" ]; then
            config_get addr "$vif" bssid "any"
            addr=${addr//-/:}
            iwconfig "$vif" ap "$addr" &   
    fi
    
    [ "$dev_disabled" = "1" ] && {
        return
    }
       
    net_cfg="$(find_net_config "$vif")"
    [ -z "$net_cfg" ] || brname="$(bridge_interface "$net_cfg")"
    #[ -z "$brname" ] && brname="br-$net_cfg"   
    config_set "$vif" bridge  "$brname" 
    create_process "$vif" "$mode" "$brname" "$start_hostapd" "$start_wapid"
    
}

config_country() {
    config_get blockdfslist "$1" blockdfslist
    [ -n "$blockdfslist" ] && iwpriv "$phy" blockdfslist "$blockdfslist"

    config_get country "$1" country US
    case "$country" in
        [0-9]*)
            iwpriv "$phy" setCountryID "$country"
        ;;
        *)
            [ -n "$country" ] && iwpriv "$phy" setCountry "$country"
        ;;
    esac   
}

config_vap_mode() {
    local cfg cfgs="rts frag chwidth disablecoext vht_11ng"
    local device="$1" vif="$2" mode="$3" chan="$4" txpower="$5"
    local hwmode
    
    for cfg in $cfgs; do config_get "$cfg" "$vif" "$cfg"; done   
    
    case "$mode" in
    # The parsing stops at the first match so we need to make sure
    # these are in the right orders (most generic at the end)
            *ng:HT20) hwmode=11NGHT20;;
            *ng:HT40-) hwmode=11NGHT40MINUS;;
            *ng:HT40+) hwmode=11NGHT40PLUS;;
            *ng:HT40) hwmode=11NGHT40;;
            *ng:*) hwmode=11NGHT20;;
            *na:HT20) hwmode=11NAHT20;;
            *na:HT40-) hwmode=11NAHT40MINUS;;
            *na:HT40+) hwmode=11NAHT40PLUS;;
            *na:HT40) hwmode=11NAHT40;;
            *na:*) hwmode=11NAHT40;;
            *ac:HT20) hwmode=11ACVHT20;;
            *ac:HT40+) hwmode=11ACVHT40PLUS;;
            *ac:HT40-) hwmode=11ACVHT40MINUS;;
            *ac:HT40) hwmode=11ACVHT40;;
            *ac:HT80) hwmode=11ACVHT80;;
            *ac:HT160) hwmode=11ACVHT160;;
            *ac:HT80_80) hwmode=11ACVHT80_80;;
            *ac:*) hwmode=11ACVHT80
                if [ -f /sys/class/net/$device/5g_maxchwidth ]; then
                       maxchwidth="$(cat /sys/class/net/$device/5g_maxchwidth)"
                       [ -n "$maxchwidth" ] && hwmode=11ACVHT$maxchwidth
                fi;;
            *b:*) hwmode=11B;;
            *bg:*) hwmode=11G;;
            *g:*) hwmode=11G; pureg=1;;
            *a:*) hwmode=11A;;
            *) hwmode=AUTO;;
    esac
    iwpriv "$vif" mode "$hwmode"
	
    
    #iwconfig "$vif" channel 0

    [ -n "$vht_11ng" ] && iwpriv "$vif" vht_11ng "$vht_11ng"
    [ -n "$disablecoext" ] && config_disablecoext "$vif" "${disablecoext}"
    [ -n "$chwidth" ] && iwpriv "$vif" chwidth "$chwidth"
    [ -n "$frag" ] && iwconfig "$vif" frag "${frag%%.*}"
    #[ -n "$rts" ] && iwconfig "$vif" rts "${rts%%.*}"
    [ -n "$chan" ] && config_channel "$vif" "$chan"
    #[ -n "$txpower" ] && iwconfig "$vif" txpower "$txpower"
}

wifi_mode() {
    tpdbg "wifi_mode:$1" 
    local dev vif
    local mode hwmode htmode channel txpower
    for dev in $1; do
        config_get disabled "$dev" disabled 0
        if [ "$disabled" = "1" ]; then
            for vif in $(config_get "$dev" vifs); do 
                [ -d /sys/class/net/$vif ]  && down_vap "$vif" &>$STDOUT
            done;
            continue
        fi

        local vifs=""
        for vif in $(config_get "$dev" vifs); do 
            config_get type "$vif" type 0
            if [ "$type" = "default" ]; then
                tpdbg "wifi_mode filter: $vif"
                continue
            fi

            [ -d /sys/class/net/$vif ] && append vifs "$vif"
            config_get mode "$vif" mode
            if [ "$mode" == "sta" ]; then
                down_vap "$vif" &>$STDOUT
            else
                ifconfig "$vif" down &>$STDOUT
            fi
        done;

        config_get hwmode "$dev" hwmode auto
        config_get htmode "$dev" htmode auto
        config_get channel "$dev" channel 0
        config_get txpower "$dev" txpower
        [ -n "$2" -o "$1" = "country" ] && config_country "$dev" &>$STDOUT
        for vif in $vifs; do config_vap_mode "$dev" "$vif" "$hwmode:$htmode" "$channel" "$txpower" &>$STDOUT; done
        [ -n "$tpscale" ] && iwpriv "$dev" tpscale "$tpscale" &>$STDOUT
    done;
}


wifi_vap() {
    tpdbg "wifi_vap:$1" 
    local device vifs disabled dev_disabled dev_disabled_all
	#get maclist_sec from blacklist.
	config_load blacklist
	maclist_sec=""
	config_foreach getmaclist_sec client 
	
    for vap in $1; do
        config_get device "$vap" device
        config_get vifs "$device" vifs
        config_get disabled "$vap" disabled
        [ "$disabled" = "1" ] && down_vap "$vap" && continue
        #for vif in $vifs; do ifconfig "$vif" down &>$STDOUT; done
        config_vap "$vap" &>$STDOUT
    done
}




wifi_update() {
    local action="${1//,/ }"
    local device="${2//,/ }"
    local vap="${3//,/ }"

    #action=${1%% *} && action=${action//,/ }
    #device=${1#* } && device=${device%% *} && device=${device//,/ } 
    #vap=${1##* } && vap=${vap//,/ }

    lock /var/run/wifilock    
    
    brchanged=0
    
    for cmd in $action; do
        if [ "$cmd" == "vap" ]; then
            [ -z "$vap" ] && vap=$device
            wifi_$cmd "$vap"
        else
            wifi_$cmd "$device"       
        fi
    done
    
    up_all_vap &>$STDOUT
    
    lock -u /var/run/wifilock     
}
