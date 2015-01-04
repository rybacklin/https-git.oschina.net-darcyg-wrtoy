#!/bin/sh

. /lib/functions.sh
. ../netifd-proto.sh
init_proto "$@"

proto_setpvid_init_config() {
	proto_config_add_string "device"
	proto_config_add_string "port"
	proto_config_add_string "pvid"
}

proto_setpvid_setup() {
	local config="$1"
	local iface="$2"
	local device port pvid
	json_get_vars device port pvid
	swconfig dev $device port $port set pvid $pvid
	swconfig dev $device set apply
}

proto_setpvid_teardown() {
	local interface="$1"
	local iface="$2"
	local device port
	json_get_vars device port
	swconfig dev $device port $port set pvid 1
	swconfig dev $device set apply
}
add_protocol setpvid

