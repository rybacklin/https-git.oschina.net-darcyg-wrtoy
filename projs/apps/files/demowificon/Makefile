include $(TOPDIR)/rules.mk

PKG_NAME:=demowificon
PKG_RELEASE:=1

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)
PKG_INSTALL_DIR:=$(PKG_BUILD_DIR)/ipkg-install

include $(INCLUDE_DIR)/kernel.mk
include $(INCLUDE_DIR)/package.mk

define Package/demowificon
  SECTION:=demo-wificon
  CATEGORY:=DGWRT-Demo
  SUBMENU :=demos
  TITLE:=wifi without ap communication demo app 
  DEPENDS:=+libpcap +libpthread +librt
endef

define Package/demowificon/description
	wifi without ap communication demo app  
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./src/* $(PKG_BUILD_DIR)/
endef
     
define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR) \
		$(TARGET_CONFIGURE_OPTS) CFLAGS="$(TARGET_CFLAGS)"
endef

define Package/demowificon/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/demo $(1)/usr/bin/
endef

$(eval $(call BuildPackage,demowificon))