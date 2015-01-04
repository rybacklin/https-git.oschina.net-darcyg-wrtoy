#
# Copyright (C) 2013-2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=eth-one-port
PKG_RELEASE:=1

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)
PKG_INSTALL_DIR:=$(PKG_BUILD_DIR)/ipkg-install

include $(INCLUDE_DIR)/kernel.mk
include $(INCLUDE_DIR)/package.mk

define Package/eth-one-port
	SECTION:=eth-one-port
	CATEGORY:=DG-Common-Packages
	TITLE:= WAN/LAN Share one Ethernet port
	#DEPENDS :=+luci
endef

define Package/eth-one-port/description
	This package provides  WAN/LAN Share one Ethernet port
endef

define Build/Prepare
        echo
endef

define Build/Compile
        echo
endef

define Package/eth-one-port/install
	$(INSTALL_DIR) $(1)/etc/rc.local.d
	$(INSTALL_DIR) $(1)/etc/config
	$(CP) ./files/etc/rc.local.d/000-config-macvlan $(1)/etc/rc.local.d/000-config-macvlan
	$(CP) ./files/etc/rc.local $(1)/etc/rc.local
	#$(INSTALL_BIN) ./files/usr/bin/set_default_page_to_wrtnode_portal.sh $(1)/usr/bin/
endef

$(eval $(call BuildPackage,eth-one-port))

