# Copyright (C) 2009-2010 OpenWrt.org

IF_LIBDIR=${IF_LIBDIR:-/lib/ipv6-firewall}

include /lib/network
# check firewall
fw_is_loaded() {
        local bool=$(uci_get_state firewall.core.loaded)
        return $((! ${bool:-0}))
}

fw_init() {
	[ -z "$IF_INITIALIZED" ] || return 0

	. $IF_LIBDIR/config.sh
	. $IF_LIBDIR/core_log.sh
	. $IF_LIBDIR/core_firewall.sh

	fw_config_append ipv6_firewall

	IF_INITIALIZED=1
	return 0
}

fw_start() {
    # make sure firewall is loaded
    fw_is_loaded || {
        echo "firewall is not loaded" >&2
        exit 1
    }

    # init
    fw_init

    # ready to load rules from uci config
    echo "loading ipv6_firewall"
    fw_load_ipv6_firewall
    syslog $LOG_INF_SERVICE_START
}

fw_stop() {
    # make sure firewall is loaded
    fw_is_loaded || {
        echo "firewall is not loaded" >&2
        exit 1
    }

    # init
    fw_init

    # ready to exit rules from uci config
    echo "exiting ipv6_firewall"
    fw_exit_ipv6_firewall
    syslog $LOG_INF_SERVICE_STOP
}

fw_restart() {
    fw_stop
    fw_start
}

fw_reload() {
    # make sure firewall is loaded
    fw_is_loaded || {
        echo "firewall is not loaded" >&2
        exit 1
    }

    local rule_id=$(cat $TEMP_IF_PATH/op_rule_id 2>/dev/null)
    rm -f $TEMP_IF_PATH/op_rule_id
    #touch $TEMP_IF_PATH/op_rule_id

    #if [ -f $TEMP_IF_PATH/running_status ];then
    #    while [ 1 ]; do
    #        if [ ! -f $TEMP_IF_PATH/running_status ];then
    #            echo $$>$TEMP_IF_PATH/running_status
    #        fi
    #        sleep 1
    #        if [ "$(cat $TEMP_IF_PATH/running_status)" == "$$" ];then
    #            break
    #        fi
    #    done
    #else
    #    echo $$>$TEMP_IF_PATH/running_status
    #fi

    fw_init
    fw_reload_ipv6_firewall $rule_id

    #rm -f $TEMP_IF_PATH/running_status
}
