#
# Copyright (C) 2015 seatry.com
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

define Profile/MTALL64M
	NAME:=MTALL mt7620a DevBoard 64MB
	PACKAGES:=\
		kmod-usb-core kmod-usb-ohci kmod-usb2 kmod-ledtrig-netdev kmod-ledtrig-timer \
		kmod-usb-acm kmod-usb-net kmod-usb-net-asix kmod-usb-net-rndis kmod-usb-serial kmod-usb-serial-option \
		usb-modeswitch usb-modeswitch-data comgt
endef

define Profile/MTALL64M/Description
	Package set for MTALL mt7620a IOT DevBoard
	256MB DDR2 + 64MB Flash
endef

$(eval $(call Profile,MTALL64M))

