#!/bin/sh
#
#
#
FILENAME='stalist'

. /lib/functions.sh

#get each vap's assoclist sta.
#input: $1 - section
#input: #2 - ap type
__get_assoclists() {
	local config="$1"  
        local type vapname disabled   

        config_get type "$config" type
        config_get vapname "$config" vapname
	config_get_bool disabled "$config" disabled

	[ $disabled = 0 -a "$type" = "$2" ] || return
	
	if [ "$type" = "lan" ]; then
		type="host"
	elif [ "$type" = "guest" ]; then
		type="guest"
	else
		return
	fi

	#check interface exist
	if $(echo $(iwconfig $vapname 2>/dev/null) | grep "Access Point" > /dev/null); then
		wlanconfig $vapname list | grep -v ADDR | awk '{print $1}' | sed "s/:/-/g;s/^/$type &/g" >> /tmp/$FILENAME
	else
		echo "invalid iface"	
	fi
}

if [ -f /tmp/$FILENAME ]; then
	rm /tmp/$FILENAME
fi
touch /tmp/$FILENAME

config_load wireless
config_foreach __get_assoclists wifi-iface lan
config_foreach __get_assoclists wifi-iface guest




