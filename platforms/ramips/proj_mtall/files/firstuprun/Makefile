#
# Copyright (C) 2013-2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=firstuprun
PKG_RELEASE:=1

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)
PKG_INSTALL_DIR:=$(PKG_BUILD_DIR)/ipkg-install

include $(INCLUDE_DIR)/kernel.mk
include $(INCLUDE_DIR)/package.mk

define Package/mtall-firstuprun
	SECTION:=mtall-firstuprun
	CATEGORY:=DG-Common-Packages
	TITLE:=Board First UP Run Config
endef

define Package/mtall-firstuprun/description
	This package provides Board First UP Run Config
endef

define Build/Prepare
        echo
endef

define Build/Compile
        echo
endef

define Package/mtall-firstuprun/install
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(CP) ./files/etc/uci-defaults/samba              $(1)/etc/uci-defaults/samba
	$(CP) ./files/etc/uci-defaults/00-system          $(1)/etc/uci-defaults/00-system
	$(CP) ./files/etc/uci-defaults/10-fstab           $(1)/etc/uci-defaults/10-fstab
	$(CP) ./files/etc/uci-defaults/10-network-config  $(1)/etc/uci-defaults/10-network-config
	$(CP) ./files/etc/uci-defaults/10-wireless-config $(1)/etc/uci-defaults/10-wireless-config
	$(CP) ./files/etc/uci-defaults/A01-set-login      $(1)/etc/uci-defaults/A01-set-login
	$(CP) ./files/etc/uci-defaults/A02-luci-config    $(1)/etc/uci-defaults/A02-luci-config
	$(CP) ./files/etc/uci-defaults/mjpg-streamer      $(1)/etc/uci-defaults/mjpg-streamer
	$(CP) ./files/etc/uci-defaults/sftp               $(1)/etc/uci-defaults/sftp
	$(CP) ./files/etc/uci-defaults/reboot             $(1)/etc/uci-defaults/zreboot
	$(CP) ./files/etc/banner                          $(1)/etc/banner
	$(CP) ./files/etc/rc.local                        $(1)/etc/rc.local
endef

$(eval $(call BuildPackage,mtall-firstuprun))

