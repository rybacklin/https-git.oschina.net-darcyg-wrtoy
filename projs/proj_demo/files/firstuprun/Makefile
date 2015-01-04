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

define Package/firstuprun
	SECTION:=firstuprun
	CATEGORY:=DG-Common-Packages
	TITLE:=Board First UP Run Config
endef

define Package/firstuprun/description
	This package provides Board First UP Run Config
endef

define Build/Prepare
        echo
endef

define Build/Compile
        echo
endef

define Package/firstuprun/install
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_DIR) $(1)/etc/lighttpd
	$(INSTALL_DIR) $(1)/etc/nginx
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_DIR) $(1)/etc/hotplug.d
	$(INSTALL_DIR) $(1)/etc/hotplug.d/block
	$(INSTALL_DIR) $(1)/etc/rc.local.d
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) ./files/etc/lighttpd/lighttpd.conf $(1)/etc/lighttpd/lighttpd.conf.def
	$(CP) ./files/etc/nginx/nginx.conf $(1)/etc/nginx/nginx.conf.def
	$(CP) ./files/etc/nginx/fastcgi_params $(1)/etc/nginx/fastcgi_params
	$(CP) ./files/etc/banner $(1)/etc/banner
	$(INSTALL_BIN) ./files/etc/init.d/done $(1)/etc/init.d/done
	$(INSTALL_BIN) ./files/etc/init.d/spawn-fcgi-php5 $(1)/etc/init.d/spawn-fcgi-php5
	#$(INSTALL_BIN) ./files/etc/hotplug.d/block/11-mount-luks $(1)/etc/hotplug.d/block/11-mount-luks
	#$(INSTALL_BIN) ./files/etc/rc.local.d/00-mount-luks $(1)/etc/rc.local.d/00-mount-luks
	#$(INSTALL_BIN) ./files/usr/bin/make-luks $(1)/usr/bin/make-luks
	$(INSTALL_BIN) ./files/usr/lib/libscf $(1)/usr/lib/libscf
	$(CP) ./files/etc/php.ini $(1)/etc/php.ini.def
	$(CP) ./files/etc/uci-defaults/firewalluser $(1)/etc/uci-defaults/firewalluser
	$(CP) ./files/etc/uci-defaults/lighttpd $(1)/etc/uci-defaults/lighttpd
	#$(CP) ./files/etc/uci-defaults/nginx $(1)/etc/uci-defaults/nginx
	#$(CP) ./files/etc/uci-defaults/mysqld $(1)/etc/uci-defaults/mysqld
	$(CP) ./files/etc/uci-defaults/00-system $(1)/etc/uci-defaults/00-system
	$(CP) ./files/etc/uci-defaults/10-fstab $(1)/etc/uci-defaults/10-fstab
	$(CP) ./files/etc/uci-defaults/10-network-config $(1)/etc/uci-defaults/10-network-config
	$(CP) ./files/etc/uci-defaults/10-wireless-config $(1)/etc/uci-defaults/10-wireless-config
	$(CP) ./files/etc/uci-defaults/12-mount-boot $(1)/etc/uci-defaults/12-mount-boot
	$(CP) ./files/etc/uci-defaults/20-uhttpd $(1)/etc/uci-defaults/20-uhttpd
	$(CP) ./files/etc/uci-defaults/A01-set-login $(1)/etc/uci-defaults/A01-set-login
	$(CP) ./files/etc/uci-defaults/zz-make-parted $(1)/etc/uci-defaults/zz-make-parted
	#$(CP) ./files/etc/uci-defaults/zz-samba $(1)/etc/uci-defaults/zz-samba
	$(CP) ./files/etc/uci-defaults/zzz-reboot $(1)/etc/uci-defaults/zzz-reboot
	$(INSTALL_BIN) ./files/etc/uci-defaults/zz-make-parted $(1)/usr/bin/make-parted
endef

$(eval $(call BuildPackage,firstuprun))

