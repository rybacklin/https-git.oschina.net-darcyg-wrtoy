#!/bin/sh

. /lib/functions.sh
. ../netifd-proto.sh
init_proto "$@"

proto_macvlan_init_config() {
	proto_config_add_string "hwaddr"
	proto_config_add_string "device"
}

proto_macvlan_setup() {
	local config="$1"
	local iface="$2"

	local hwaddr device
	json_get_vars hwaddr device
	
    #/usr/sbin/ip link add link $iface address $hwaddr $device type macvlan
    /sbin/ip link add link $iface $device type macvlan
    ifconfig $device hw ether $hwaddr
    ifconfig $device up
    proto_init_update $device 1 1
}

proto_macvlan_teardown() {
	local interface="$1"
	local iface="$2"
	local device
	json_get_vars device
	ip link delete $device
	proto_init_update $device 0
}

add_protocol macvlan

