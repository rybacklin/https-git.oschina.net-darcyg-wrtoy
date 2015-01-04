#
# Copyright (C) 2013-2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=automount
PKG_RELEASE:=1

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)
PKG_INSTALL_DIR:=$(PKG_BUILD_DIR)/ipkg-install

include $(INCLUDE_DIR)/kernel.mk
include $(INCLUDE_DIR)/package.mk

define Package/automount
	SECTION:=automount
	CATEGORY:=DG-Common-Packages
	TITLE:=Auto Mount SD Card / Usb Storages
endef

define Package/automount/description
	This package provides Auto Mount SD Card / Usb Storages
endef

define Build/Prepare
        echo
endef

define Build/Compile
        echo
endef

define Package/automount/install
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) ./files/etc/config/fstab $(1)/etc/config/fstab
	$(INSTALL_BIN) ./files/usr/bin/mksdcard $(1)/usr/bin/mksdcard
endef

$(eval $(call BuildPackage,automount))

