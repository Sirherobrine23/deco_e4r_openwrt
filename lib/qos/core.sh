# Copyright (C) 2009-2010 OpenWrt.org

PC_LIBDIR=${PC_LIBDIR:-/lib/qos}

include /lib/network
# check firewall
fw_is_loaded() {
    local bool=$(uci_get_state firewall.core.loaded)
    return $((! ${bool:-0}))
}


fw_init() {
    [ -z "$PC_INITIALIZED" ] || return 0

    . $PC_LIBDIR/config.sh

    # export the qos config
    fw_config_append qos_v2
	fw_config_append client_mgmt

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
    echo "loading qos"
    fw_load_qos
	
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

    fw_hnat_start
    fw_exit_qos
    echo '0' > /proc/sfe_ipv4/qos_enable
    syslog $LOG_INF_SERVICE_STOP
    echo "--------->exiting qos">/dev/console
}

fw_restart() {

    local qos_status_file="/tmp/qos_running_status"
    if [ -f $qos_status_file ];then
        while [ 1 ]; do
            if [ ! -f $qos_status_file ];then
                echo $$>$qos_status_file
                break
            fi
            sleep 1
        done
    else
        echo $$>$qos_status_file
    fi
	
	[ "$(cat $qos_status_file)" == "$$" ] || exit

    fw_stop
	fw_start
    
    rm -f $qos_status_file
}

fw_reload() {
    # make sure firewall is loaded
    fw_is_loaded || {
        echo "firewall is not loaded" >&2
        exit 1
    }
    # reload
    fw_init

    fw_config_once fw_rule_reload global
}

fw_check() {
	fw_is_loaded || {
        echo "firewall is not loaded" >&2
        exit 1
    }
	
	# init
    fw_init
	
	fw_check_clients
}
