include $(TOPDIR)/rules.mk

PKG_NAME:=kismet-manuf-database

include ../kismet.mk

include $(INCLUDE_DIR)/package.mk

define Package/kismet-manuf-database
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Kismet IEEE manufacturers
  URL:=https://www.kismetwireless.net
  DEPENDS:=kismet 
  SUBMENU:=kismet
endef

define Package/kismet-manuf-database/description
  Kismet IEEE manufacturer database
  Compressed database of manufacturer names for Kismet; without this
  database, Kismet will not be able to resolve manufacturers for 
  Wi-Fi devices.
endef

define Build/Configure
	echo "No configuration needed"
endef

define Build/Compile
	echo "No compilation needed"
endef

define Package/kismet-manuf-database/install
	$(INSTALL_DIR) $(1)/etc/kismet/
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/conf/kismet_manuf.txt.gz $(1)/etc/kismet
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/conf/kismet_bluetooth_ids.txt.gz $(1)/etc/kismet
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/conf/kismet_bluetooth_manuf.txt.gz $(1)/etc/kismet
endef

$(eval $(call BuildPackage,kismet-manuf-database))
