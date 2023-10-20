#!/bin/sh
G_UCI_DEFAULT_PATH="/etc/config"
G_UCI_CONFIG_FILE="pc_insights"
G_PROC_PCTL_PATH="/proc/pctl"
G_PC_INSIGHTS_PATH="/tmp/tmp-device-config"
G_NTP_TIME="/tmp/run/ntpd.uptime"                   # ntpd.uptime
G_LAST_NTP_TIME="/tmp/run/last_ntpd_uptime"         # save last ntpd.uptime
G_LAST_TIME="/tmp/last_time"                                 # save last saveconfig time
G_LAST_DAY_TIME="/tmp/parental_control/last_day_time"        # save surf internet time before reboot  
G_BEFORE_REBOOT_DAY_PATH="/tmp/parental_control"   # save surf internet history before reboot  
G_PCTL_CONFIG_FILE="parental_control"               # parental control uci config file
G_UPDATE_STATUS="/tmp/parental_control/update"      # 1: updating 
G_BLOCK_STATUS="pctl_block"
INSIGHTS_HISTORY_MAX="100"
ACCESS_ENTRY_MAX="10"
FORBID_ENTRY_MAX="5"
uci_r="uci -c $G_PC_INSIGHTS_PATH"
uci_b="uci -c $G_BEFORE_REBOOT_DAY_PATH"


#if owner is nonexistent then clear it info
clear_nonexistent_owner_log_in_proc()
{
    local write_flash="0"
    local line=1
    for i in `seq 0 15`
    do
        let line=${i}+1
        pctl_owner=`uci get ${G_PCTL_CONFIG_FILE}.${i} 2>/dev/null`
        insi_owner=`uci get ${G_UCI_CONFIG_FILE}.${i} 2>/dev/null`
        tmp_insi_owner=`$uci_r get ${G_UCI_CONFIG_FILE}.${i} 2>/dev/null`
        if [ -z "$pctl_owner" ] && [ -n "$insi_owner" ];then
            # clear entry info in pc_insights
            uci delete ${G_UCI_CONFIG_FILE}.${i}
            uci commit $G_UCI_CONFIG_FILE
            saveconfig

            #clear info in proc file
            echo "f">/proc/pctl/${i}
            
            #clear time before reboot 
            sed -i "${line}c 0" ${G_LAST_DAY_TIME}
        fi

        if [ -z "$pctl_owner" ] && [ -n "$tmp_insi_owner" ];then

            $uci_r delete ${G_UCI_CONFIG_FILE}.${i}
            $uci_r commit $G_UCI_CONFIG_FILE
            echo "f">/proc/pctl/${i}
            sed -i "${line}c 0" ${G_LAST_DAY_TIME}
        fi
    done

}

init_pc_insights()
{   
    clear_nonexistent_owner_log_in_proc
  
}

load_pc_insights()
{
    local owner_id=$1
	local owner_name=$2
    # # if this entry is not exist then add it
    $uci_r set $G_UCI_CONFIG_FILE.${owner_id}="owner"
	$uci_r set $G_UCI_CONFIG_FILE.${owner_id}.owner_name="$owner_name"
	$uci_r set $G_UCI_CONFIG_FILE.${owner_id}.owner_id="$owner_id"
    
    #if day log entry is not exist, create it,else do nothing
    
    local day_log=`$uci_r get $G_UCI_CONFIG_FILE.$owner_id.day_1 2>/dev/null`
    if [ -z "${day_log}" ];then
        for day in `seq 1 7`
        do
            $uci_r set $G_UCI_CONFIG_FILE.$owner_id.day_$day="-1;0;"
        done
    fi
    
    day_log=`$uci_r get $G_UCI_CONFIG_FILE.$owner_id.month_access_ll 2>/dev/null`
    if [ -z "${day_log}" ];then

        $uci_r set $G_UCI_CONFIG_FILE.$owner_id.month_access_t="-1;0;"
        $uci_r set $G_UCI_CONFIG_FILE.$owner_id.month_access_l="-1;0;"
        $uci_r set $G_UCI_CONFIG_FILE.$owner_id.month_access_ll="-1;0;"
        $uci_r set $G_UCI_CONFIG_FILE.$owner_id.month_forbid_t="-1;0;"
        $uci_r set $G_UCI_CONFIG_FILE.$owner_id.month_forbid_l="-1;0;"
        $uci_r set $G_UCI_CONFIG_FILE.$owner_id.month_forbid_ll="-1;0;"
        
    fi
    $uci_r commit $G_UCI_CONFIG_FILE
}
get_day_info()
{
    local owner=$1
    local day_num=$2
    local option=$3
    local day_info=""
    # # get 7 days info
    day_info=`cat  ${G_PROC_PCTL_PATH}/${owner}|grep -v ","|tr '\n' ','`
    if [ "$option" = "4" ] # get row value
    then
    {
        key_words=`echo $day_info|awk -v num="${day_num}" 'BEGIN{FS=","}{print $num}'`
        result=`grep -n "$key_words" ${G_PROC_PCTL_PATH}/${owner}|cut -d : -f 1` 

    }
    else # get time, timestamp or url_num
    {
        result=`echo $day_info|awk -v num="${day_num}" 'BEGIN{FS=","}{print $num}'\
                                |awk -v num="${option}" 'BEGIN{FS=" "}{print $num}'`
    }
    fi
    # echo $resutl>/dev/console
    echo $result

}
get_day_url_entry()
{
    local owner=$1
    local day=$2
    local type=$3
    local day_url=""
    if [ "$type" == "access_entry" ] || [ "$type" == "forbid_entry" ];then
        day_url=`cat  ${G_PROC_PCTL_PATH}/${owner}|grep  "$type"|cut -d "," -f2-|tr '\n' ';'`
    fi
    echo $day_url
}

get_history_url_entry()
{
    local owner=$1
    local day=$2
    local type=$3
    local option="4"
    # local row=$(get_day_info "$owner" "${day}" "${option}")
    local row="1"
    local num=$(get_day_url_num "$owner" "${day}")
    if [ "${num}" -gt "${INSIGHTS_HISTORY_MAX}" ]
    then
        num=${INSIGHTS_HISTORY_MAX}
    fi
    if [ "$type" = "time" ] #url,time;
    then

        url_entry=`tail -n +2 ${G_PROC_PCTL_PATH}/${owner}|tail -n +$row|head -n $num\
                |awk 'BEGIN{FS=","}{print $2","$3}'|tr '\n' ';'`

    else                    #url,timestamp;

        url_entry=`tail -n +2 ${G_PROC_PCTL_PATH}/${owner}|tail -n +$row|head -n $num\
                |awk 'BEGIN{FS=","}{print $2","$4}'|tr '\n' ';'`

    fi

    echo $url_entry  
}
get_day_url_num()
{
    local owner=$1
    local day=$2
    local option="3"
    local url_num=$(get_day_info "$owner" "${day}" "${option}")
    echo $url_num

}

get_day_time()
{
    local owner=$1
    local day=$2
    local option="1"
    local day_time=$(get_day_info "$owner" "${day}" "${option}")
    echo $day_time
}
get_day_timestamp()
{
    local owner=$1
    local day=$2
    local option="2"
    local day_timestamp=$(get_day_info "$owner" "${day}" "${option}")
    echo $day_timestamp
}
merge_url_entry()
{

    local entry1=$1
    local entry2=$2
    local entry_num=$3
    local time_total=0
    local entry=""
    # echo "------------------>merge start">/dev/console
    local time_stamp1=$(echo ${entry1}|cut -d ";" -f2)
    local time1=$(echo ${entry1}|cut -d ";" -f1)
    # time_stamp2=$(echo ${entry2}|cut -d ";" -f2)
    local time2=$(echo ${entry2}|cut -d ";" -f1)
    if [ "$time1" != "-1" ] || [ "$time2" != "-1" ];then 
        let time_total=${time1}+${time2} 
    else
        time_total=$time1
    fi  
    entry1=$(echo ${entry1}|cut -d ";" -f3-|tr ' ' '_')
    entry2=$(echo ${entry2}|cut -d ";" -f3-|tr ' ' '_')
    if [ -n "$entry1" ] || [ -n "$entry2" ];then
 
    # url time
    # if first line is same then add second line,sort it by time
    entry=$(echo -n ${entry1}${entry2}|tr ";" "\n"|tr "," " " \
            |awk  '{sum[$1]+=$2}END{for(c in sum){print c,sum[c]}}' \
            |awk 'BEGIN{FS=" "}{print $2" "$1}'|sort -n -r \
            |awk 'BEGIN{FS=" "}{print $2" "$1}' \
            |tr ' ' ','|tr '\n' ';'|tr '_' ' '|cut -d ";" -f1-${entry_num})

    fi

    end_with_semicolon=$(echo $entry|grep ";$")
    if [ -n "$end_with_semicolon" ] || [ -z "$entry" ];then
        echo "${time_total};${time_stamp1};${entry}"    
    else
        echo "${time_total};${time_stamp1};${entry};"
    fi
    # echo "------------------>merge end">/dev/console

}

update_uci_monthly_days_info()
{
    local owner=$1
    # set this month log
    local today_log=`$uci_r get $G_UCI_CONFIG_FILE.$owner.day_1 2>/dev/null`
    local month_access_t=`$uci_r get $G_UCI_CONFIG_FILE.$owner.month_access_t 2>/dev/null`
    local forbid_today_log=`$uci_r get $G_UCI_CONFIG_FILE.$owner.forbid_day_1 2>/dev/null`
    local month_forbid_t=`$uci_r get $G_UCI_CONFIG_FILE.$owner.month_forbid_t 2>/dev/null`
    
    today_url=$(echo ${today_log}|cut -d ";" -f3-)
    forbid_url=$(echo ${forbid_today_log}|cut -d ";" -f3-)
    if [ -n "$today_url" ];then
        month_access_t=$(merge_url_entry "$today_log" "$month_access_t" "$ACCESS_ENTRY_MAX")
        $uci_r set $G_UCI_CONFIG_FILE.$owner.month_access_t="$month_access_t"
    fi
    if [ -n "$forbid_url" ];then
         month_forbid_t=$(merge_url_entry "$forbid_today_log" "$month_forbid_t" "$FORBID_ENTRY_MAX")
         $uci_r set $G_UCI_CONFIG_FILE.$owner.month_forbid_t="$month_forbid_t"
    fi
    
    # set 7 days log
    for day in `seq 6 -1 1`
    do
        let last_day=${day}+1
        today_log=`$uci_r get $G_UCI_CONFIG_FILE.$owner.day_$day 2>/dev/null`
        if [ -n "${today_log}" ];then
            $uci_r set $G_UCI_CONFIG_FILE.$owner.day_$last_day="${today_log}"
            $uci_r set $G_UCI_CONFIG_FILE.$owner.day_$day="-1;0;"
        else 
            $uci_r set $G_UCI_CONFIG_FILE.$owner.day_$last_day="-1;0;"
            $uci_r set $G_UCI_CONFIG_FILE.$owner.day_$day="-1;0;"
        fi
  
    done
    # set todays forbid
    $uci_r set $G_UCI_CONFIG_FILE.$owner.forbid_day_1="-1;0;"


    # set last month log
    local now_timestamp=`date +%s`
    let now_timestamp=${now_timestamp}+86400 
    next_day=`date -d @${now_timestamp} +%d`
    if [ "$next_day" == "01" ];then
        month_access_l=`$uci_r get $G_UCI_CONFIG_FILE.$owner.month_access_l 2>/dev/null`
        month_forbid_l=`$uci_r get $G_UCI_CONFIG_FILE.$owner.month_forbid_l 2>/dev/null`
        $uci_r set $G_UCI_CONFIG_FILE.$owner.month_access_l="$month_access_t"
        $uci_r set $G_UCI_CONFIG_FILE.$owner.month_forbid_l="$month_forbid_t"
        $uci_r set $G_UCI_CONFIG_FILE.$owner.month_access_ll="$month_access_l"
        $uci_r set $G_UCI_CONFIG_FILE.$owner.month_forbid_ll="$month_forbid_l"
        $uci_r set $G_UCI_CONFIG_FILE.$owner.month_access_t="-1;0;"
        $uci_r set $G_UCI_CONFIG_FILE.$owner.month_forbid_t="-1;0;"
    fi

    $uci_r commit $G_UCI_CONFIG_FILE
    clean_day_time_before_reboot
}

get_owner_day_time_from_flash()
{
    local owner=$1
    local time_before_reboot=`uci get ${G_UCI_CONFIG_FILE}.${owner}.day_1|cut -d ";" -f1 2>/dev/null`
    if [ -n "${time_before_reboot}" ] && [ "${time_before_reboot}" != "-1" ]
    then
        echo "${time_before_reboot}"
    else
        echo "0"
    fi
}
get_all_time_before_reboot() {
    local last_time=""
    for i in `seq 0 15`
    do
	last_time=$(get_owner_day_time_from_flash "$i")
	echo $last_time>>$G_LAST_DAY_TIME
    done
}

get_day_time_from_file()
{   
    let line=1+$1
    last_time=`cat ${G_LAST_DAY_TIME}|head -n "$line"|tail -n 1`
    echo $last_time

}

clean_day_time_before_reboot()
{
    echo "0">$G_LAST_DAY_TIME
    for i in `seq 0 15`
    do
	echo "0">>$G_LAST_DAY_TIME
    done

}

save_to_flash_when_timeout() 
{
    local owner=$1
    local new_time=$2
    local limit_time="0"
    local weekend_limit=`uci get ${G_PCTL_CONFIG_FILE}.${owner}.weekend_limit 2>/dev/null`
    local workday_limit=`uci get ${G_PCTL_CONFIG_FILE}.${owner}.workday_limit 2>/dev/null`

    local date1=`date +%A`
    if [ "${date1}" = "Statuday" ] || [ "${date1}" = "Sunday" ];then
        if [ "$weekend_limit" == "0" ];then
            return
        fi
        limit_time=`uci get ${G_PCTL_CONFIG_FILE}.${owner}.weekend_time 2>/dev/null`
    else
        if [ "$workday_limit" == "0" ];then
            return
        fi
        limit_time=`uci get ${G_PCTL_CONFIG_FILE}.${owner}.workday_time 2>/dev/null`
    fi
    # time before reboot >= time limit
    local time_before_reboot=$(get_day_time_from_file "$owner")
    if test "$time_before_reboot" -ge "$limit_time"
    then
        return  
    fi
    # time has saved >= time limit
    local time_saved=$(get_owner_day_time_from_flash "$owner")
    if test "$time_saved" -ge "$limit_time"
    then
        return  
    fi

    # echo $limit_time>/dev/console
    if [ -n "$limit_time" ]
    then
        if test "$new_time" -ge "$limit_time"
        then
            cp ${G_PC_INSIGHTS_PATH}/${G_UCI_CONFIG_FILE} ${G_UCI_DEFAULT_PATH} 
            saveconfig
        fi
    fi
}

update_uci_day_info()   
{
    local owner=$1
    local day=$2
    local day_time="0"
    local day_timestamp="0"
    local day_url_entry=""
    local forbid_url_entry=""
    local uci_day_info="-1,0;"
    local uci_forbid_info="-1,0;"
    local last_day_info="-1;0;"
    local last_forbid_info="-1;0;"

    day_time=$(get_day_time "$owner" "${day}" )
    local day_time_reboot=$(get_day_time_from_file "$owner")
    let all_time=${day_time}+${day_time_reboot}
    if [ "$day_time" != "0" ]
    then
       
        day_timestamp=$(get_day_timestamp "$owner" "${day}" )
        day_url_entry=$(get_day_url_entry "$owner" "${day}" "access_entry")
        forbid_url_entry=$(get_day_url_entry "$owner" "${day}" "forbid_entry")
    
    fi

    uci_day_info="${day_time};${day_timestamp};${day_url_entry}"
    uci_forbid_info="${day_time};${day_timestamp};${forbid_url_entry}"
    
    if [ "$day_time_reboot" != "0" ]
    then
        last_day_info=`$uci_b get $G_UCI_CONFIG_FILE.$owner.day_$day 2>/dev/null`
        uci_day_info=$(merge_url_entry "$last_day_info" "$uci_day_info" "$ACCESS_ENTRY_MAX")
        last_forbid_info=`$uci_b get $G_UCI_CONFIG_FILE.$owner.forbid_day_$day 2>/dev/null`
        uci_forbid_info=$(merge_url_entry "$last_forbid_info" "$uci_forbid_info" "$FORBID_ENTRY_MAX")
        
    fi

    $uci_r set $G_UCI_CONFIG_FILE.$owner.day_$day="${uci_day_info}"
    $uci_r set $G_UCI_CONFIG_FILE.$owner.forbid_day_$day="${uci_forbid_info}"
    $uci_r commit $G_UCI_CONFIG_FILE
    
    save_to_flash_when_timeout "$owner" "${all_time}"
}

inverted_order() # aa;bb;cc -> cc;bb;aa
{
    local day_url_entry=$1
    local OLD_IFS=$IFS
    IFS=";"
    for line in ${day_url_entry}
    do
        tmp="${line};${tmp}"
    done
    IFS=$OLD_IFS
    echo $tmp
}

delete_redundant_history_list() #history list should not more than 100
{
    local owner=$1
    local tmp_history=`$uci_r -d "|" get $G_UCI_CONFIG_FILE.$owner.history 2>/dev/null`
    [ -z "${tmp_history}" ] && return
    local count=`echo ${tmp_history}|grep -o ";"|wc -l`

    if test "$count" -gt "$INSIGHTS_HISTORY_MAX"
    then
        let num=${count}-100

        tmp_history=`echo $tmp_history|cut -d ";" -f "-${num}"`
        tmp_history="${tmp_history};"
        OLD_IFS=$IFS
        IFS="|"
        for list in ${tmp_history}
        do
            IFS=${OLD_IFS}
            list=${list//"'"/}
            $uci_r del_list $G_UCI_CONFIG_FILE.$owner.history="${list}"
        done     
    
        $uci_r commit $G_UCI_CONFIG_FILE
   fi
}

update_uci_history_list() 
{
    local owner=$1
    local day="1"
    local day_url_num=$(get_day_url_num "$owner" "${day}" )
    if [ "$day_url_num" = "0" ]
    then
        return
    else
        day_url_entry=$(get_history_url_entry "$owner" "${day}" "timestamp")
        day_url_entry=$(inverted_order "${day_url_entry}")
        last_timestamp=`$uci_r get $G_UCI_CONFIG_FILE.$owner.history 2>/dev/null \
        |awk 'BEGIN{FS=","}{print $NF}'|cut -d ";" -f1`

        for i in `seq 1 ${INSIGHTS_HISTORY_MAX}`
        do
            
            history_url_entry=`echo $day_url_entry|cut -d ";" -f $i 2>/dev/null`
            [ -z "${history_url_entry}" ] && break
            history_timestamp=`echo ${history_url_entry}|cut -d "," -f2`

            if [ -z "$last_timestamp" ] || [ "${history_timestamp}" -gt "${last_timestamp}" ] 
            then
                $uci_r add_list $G_UCI_CONFIG_FILE.$owner.history="${history_url_entry};"
            fi
            
        done
        
    fi
    delete_redundant_history_list  "$owner"
    $uci_r commit $G_UCI_CONFIG_FILE   
}
is_need_saveconfig_to_flash() #save config once a day
{
    local owner=$1
    if [ ! -f "$G_NTP_TIME" ]
    then
        echo "false"
        return
    fi
    local last_year_mon_day=`cat $G_LAST_TIME 2>/dev/null`
    local year_mon_day=`date "+%G-%m-%d"`

    if [ "${last_year_mon_day}" = "${year_mon_day}" ];then
        echo "false"
        return
    fi
    local hour_min=`date +%T|cut -c1-5` 
    if [ "${hour_min}" = "23:58" ] || [ "${hour_min}" = "23:59" ] # everyday 23:58:xx - 23:59:xx ,saveconfig
    then
        echo  "${year_mon_day}">$G_LAST_TIME
        echo "need save history to flash">/dev/console
        echo "true"
        return
    fi
}
check_ntp_uptime_status() # if status changed then return true
{
    if [ ! -f "$G_NTP_TIME" ]
    then
        echo "false"
        return
    fi
    local ntp_uptime=`cat $G_NTP_TIME 2>/dev/null`
    local last_ntp_uptime=`cat $G_LAST_NTP_TIME 2>/dev/null`
    if [ "$last_ntp_uptime" != "$ntp_uptime" ];then
        echo "$ntp_uptime">$G_LAST_NTP_TIME
        echo "true"
        return
    fi
    echo "false"
    return
}

delete_conntrack_by_ip() 
{
    local ip=""
    local owner_macs="$1"
    if [ -z "$owner_macs" ]
    then
        return
    fi
    local OLD_IFS=$IFS
    IFS=" "
   
    for mac in $owner_macs
	do
        ip=`cat /proc/net/arp |grep -i "$mac"|cut -d " " -f1`
        if [ -n "$ip" ]
        then
            echo "----delete conntrack ip=${ip}">/dev/console        
            conntrack -D -s "$ip"
            conntrack -D -d "$ip"
        fi
    done
    IFS=$OLD_IFS
}

set_owner_block_status()
{
    local owner=$1
    local owner_macs=""
    if [ ! -f "${G_PC_INSIGHTS_PATH}/${G_BLOCK_STATUS}" ]
    then
        touch ${G_PC_INSIGHTS_PATH}/${G_BLOCK_STATUS}
    fi

    local last_flag=`$uci_r get $G_BLOCK_STATUS.${owner}.owner_block 2>/dev/null`
    flag=`cat ${G_PROC_PCTL_PATH}/${owner}|head -n 1|cut  -d " " -f4`
    if [ -z "$last_flag" ] || [ "$flag" != "$last_flag" ]
    then
        if [ "$flag" == "1" ]
        then
            owner_macs=`uci -p /var/state get parental_control.core.id_${owner} 2>/dev/null`
            if [ -z "$owner_macs" ]
            then
                return
            fi
            delete_conntrack_by_ip "$owner_macs"
        fi
    fi
    $uci_r set $G_BLOCK_STATUS.${owner}="owner"
	$uci_r set $G_BLOCK_STATUS.${owner}.owner_block="$flag"
	$uci_r commit $G_BLOCK_STATUS

}
update_day_info()
{
    local owner=$1
    local day=$2
    local hour_min=`date +%T|cut -c1-5` 
    if [ "${hour_min}" = "23:58" ] || [ "${hour_min}" = "23:59" ]
    then
        return
    fi
    local state=`cat ${G_UPDATE_STATUS} 2>/dev/null`
    [ "${state}" = "1" ] && return
    echo "1">${G_UPDATE_STATUS}
    update_uci_history_list "$owner"
    update_uci_day_info "$owner" "$day"
    set_owner_block_status "$owner"
    echo "0">${G_UPDATE_STATUS}
}