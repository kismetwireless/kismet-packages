include $(TOPDIR)/rules.mk

PKG_NAME:=kismet-icao-database

include ../kismet.mk

include $(INCLUDE_DIR)/package.mk

define Package/kismet-icao-database
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Kismet ICAO airplane database
  URL:=https://www.kismetwireless.net
  DEPENDS:=kismet 
  SUBMENU:=kismet
endef

define Package/kismet-icao-database/description
  Kismet ICAO airplane database
  Compressed database of ICAO airplane registrations.  Without this
  database, Kismet will not be able to resolve flight info for 
  airlines detected via ADSB.
endef

define Build/Configure
	echo "No configuration needed"
endef

define Build/Compile
	echo "No compilation needed"
endef

define Package/kismet-manuf-database/install
	$(INSTALL_DIR) $(1)/etc/kismet/
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/conf/kismet_adsb_icao.txt.gz $(1)/etc/kismet
endef

$(eval $(call BuildPackage,kismet-icao-database))
