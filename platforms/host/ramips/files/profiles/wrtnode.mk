#
# Copyright (C) 2015 wrtnode.org (seatry.com)
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

define Profile/WRTNODE
	NAME:=WRTNODE mt7620n DevBoard
	PACKAGES:=\
		kmod-usb-core kmod-usb-ohci kmod-usb2 kmod-ledtrig-netdev kmod-ledtrig-timer \
		kmod-usb-acm kmod-usb-net kmod-usb-net-asix kmod-usb-net-rndis kmod-usb-serial kmod-usb-serial-option \
		usb-modeswitch usb-modeswitch-data comgt
endef

define Profile/WRTNODE/Description
	Package set for WRTNODE mt7620n DevBoard
	64MB DDR2 + 16MB Flash
endef

$(eval $(call Profile,WRTNODE))

