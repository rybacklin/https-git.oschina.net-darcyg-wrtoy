#
# Copyright (C) 2006-2014 Seatry.com
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=phpMyAdmin
#PKG_VERSION:=4.2.9.1
PKG_VERSION:=4.0.10.4
PKG_RELEASE:=1
PKG_MAINTAINER:=phpMyAdmin.net
PKG_LICENSE:=GPL-2.0
PKG_LICENSE_FILES:=COPYING

#http://sourceforge.net/projects/phpmyadmin/files/phpMyAdmin/4.2.9/phpMyAdmin-4.2.9-all-languages.tar.gz/download#!md5!
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-all-languages.tar.gz
#PKG_SOURCE_URL:=http://downloads.sourceforge.net/$(PKG_NAME)/
PKG_SOURCE_URL:=http://downloads.sourceforge.net/phpmyadmin/
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)-all-languages
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_SOURCE_SUBDIR)
#PKG_INSTALL_DIR:=$(PKG_BUILD_DIR)/ipkg-install

# 4.2.9
#PKG_MD5SUM:=c3f1e02f03e2b3f0e8b2fd4a4900084a
# 4.0.10.4
PKG_MD5SUM:=c26b3f21df3422a440d2af724abf7fcf

include $(INCLUDE_DIR)/package.mk

define Package/phpmyadmin
	SECTION:=dsn
	CATEGORY:=DG-Common-Packages
  TITLE:=PHP Mysql Admin 4.x
  URL:=http://phpmyadmin.sourceforge.net/
endef

define Package/phpmyadmin/Description
  PHP Mysql Admin 4.x Web Portal
endef

# 源码解包预处理
define Build/Prepare
  $(call Build/Prepare/Default)
endef

# 编译
define Build/Compile
  echo
endef

define Package/phpmyadmin/install
	$(INSTALL_DIR) $(1)/usr/data/webroot/phpadmin
	$(CP) -Rf $(PKG_BUILD_DIR)/doc        $(1)/usr/data/webroot/phpadmin
	$(CP) -Rf $(PKG_BUILD_DIR)/examples   $(1)/usr/data/webroot/phpadmin
	$(CP) -Rf $(PKG_BUILD_DIR)/js         $(1)/usr/data/webroot/phpadmin
	$(CP) -Rf $(PKG_BUILD_DIR)/libraries  $(1)/usr/data/webroot/phpadmin
	$(CP) -Rf $(PKG_BUILD_DIR)/locale     $(1)/usr/data/webroot/phpadmin
	$(CP) -Rf $(PKG_BUILD_DIR)/setup      $(1)/usr/data/webroot/phpadmin
	$(CP) -Rf $(PKG_BUILD_DIR)/themes     $(1)/usr/data/webroot/phpadmin
	$(CP)     $(PKG_BUILD_DIR)/*.php      $(1)/usr/data/webroot/phpadmin
	#$(CP)     $(PKG_BUILD_DIR)/.*.yml     $(1)/usr/data/webroot/phpadmin
	$(CP)     $(PKG_BUILD_DIR)/*.xml.*    $(1)/usr/data/webroot/phpadmin
	#$(CP)     $(PKG_BUILD_DIR)/*.md       $(1)/usr/data/webroot/phpadmin
	$(CP)     $(PKG_BUILD_DIR)/*.ico      $(1)/usr/data/webroot/phpadmin
	$(CP)     $(PKG_BUILD_DIR)/*.txt      $(1)/usr/data/webroot/phpadmin
	$(CP)     $(PKG_BUILD_DIR)/*.css      $(1)/usr/data/webroot/phpadmin
	$(CP)     $(PKG_BUILD_DIR)/*.json     $(1)/usr/data/webroot/phpadmin
	$(CP)     $(PKG_BUILD_DIR)/RELEASE*   $(1)/usr/data/webroot/phpadmin
	$(CP)     $(PKG_BUILD_DIR)/README     $(1)/usr/data/webroot/phpadmin
	$(CP)     $(PKG_BUILD_DIR)/LICENSE    $(1)/usr/data/webroot/phpadmin
	#$(CP)     $(PKG_BUILD_DIR)/DC*        $(1)/usr/data/webroot/phpadmin
	$(CP)     $(PKG_BUILD_DIR)/ChangeLog  $(1)/usr/data/webroot/phpadmin
	$(CP)     ./files/config.default.php  $(1)/usr/data/webroot/phpadmin/libraries
endef

$(eval $(call BuildPackage,phpmyadmin))
