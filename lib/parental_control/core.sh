# Copyright (C) 2009-2010 OpenWrt.org

PC_LIBDIR=${PC_LIBDIR:-/lib/parental_control}

include /lib/network
# check firewall
fw_is_loaded() {
    local bool=$(uci_get_state firewall.core.loaded)
    return $((! ${bool:-0}))
}


fw_init() {
    [ -z "$PC_INITIALIZED" ] || return 0

    . $PC_LIBDIR/config.sh
    . $PC_LIBDIR/core_get_history.sh
    . $PC_LIBDIR/url_lib.sh
	
    init_pc_insights
    init_url_lib_for_kmod
    # export the parental_control config
	fw_config_append client_mgmt
    fw_config_append parental_control

    for file in $PC_LIBDIR/core_*.sh; do
        . $file
    done

    PC_INITIALIZED=1
    return 0
}

fw_start() {

    # make sure firewall is loaded
    fw_is_loaded || {
        echo "firewall is not loaded" >&2
        exit 1
    }

    # check the hook and chains

    # init
    fw_init

    # ready to load rules from uci config
    echo "loading parental_control"
    fw_load_parental_ctrl 
    syslog $LOG_INF_SERVICE_START
}

fw_stop() {
    # make sure firewall is loaded
    fw_is_loaded || {
        echo "firewall is not loaded" >&2
        exit 1
    }
    # check the hook and chains

    # init
    fw_init

    # ready to exit rules from uci config
    echo "exiting parental_control"
    fw_exit_parental_ctrl
    syslog $LOG_INF_SERVICE_STOP
}

fw_restart() {
    fw_stop
    fw_start
}

fw_reload() {
    fw_is_loaded || {
        echo "firewall is not loaded" >&2
        exit 1
    }
    local owner_id=`cat $TEMP_PCTL_PATH/op_owner_id 2>/dev/null`
    rm -f $TEMP_PCTL_PATH/op_owner_id
    if [ -f $TEMP_PCTL_PATH/running_status ];then
        while [ 1 ]; do
            if [ ! -f $TEMP_PCTL_PATH/running_status ];then
                echo $$>$TEMP_PCTL_PATH/running_status
            fi
            sleep 1
            if [ "$(cat $TEMP_PCTL_PATH/running_status)" == "$$" ];then
                break
            fi
        done
    else
        echo $$>$TEMP_PCTL_PATH/running_status
    fi
	
    fw_init
    fw_reload_parental_ctrl $owner_id
    
    rm -f $TEMP_PCTL_PATH/running_status
}

