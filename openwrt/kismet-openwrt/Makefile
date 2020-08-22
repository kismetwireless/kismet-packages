include $(TOPDIR)/rules.mk

PKG_NAME:=kismet
PKG_VERSION:=20xx-XX-XX
PKG_RELEASE:=1

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/kismetwireless/kismet.git
PKG_SOURCE_VERSION:=dcaddeeb4ad4b0f2fd852811c49f71dddc163567
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION).tar.gz
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)

PKG_USE_MIPS16:=0

include $(INCLUDE_DIR)/package.mk

HOST_BUILD_DEPENDS:=protobuf/host 




define Package/kismet
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Kismet 2020
  URL:=https://www.kismetwireless.net/
  DEPENDS:=+libpthread +libpcap +libpcre +libmicrohttpd +libnl +libcap +libstdcpp +libncurses +libsqlite3 +zlib +protobuf-lite +libprotobuf-c kismet-capture-linux-wifi
  SUBMENU:=wireless
endef

define Package/kismet/description
  Modern Kismet wireless capture and IDS
  Latest web UI based Kismet
endef



define Package/kismet-adsb-database
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Kismet ICAO Data
  URL:=https://www.kismetwireless.net
  DEPENDS:=kismet 
  SUBMENU:=wireless
endef

define Package/kismet-adsb-database/description
  Kismet ADSB ICAO database
  Large database of ICAO values for ADSB plane spotting; without this
  database, Kismet will not be able to resolve flight info if capturing
  ADSB data.
endef




define Package/kismet-manuf-database
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Kismet Manufacturer Data
  URL:=https://www.kismetwireless.net
  DEPENDS:=kismet 
  SUBMENU:=wireless
endef

define Package/kismet-manuf-database/description
  Kismet IEEE manufacturer database
  Compressed database of manufacturer names for Kismet; without this
  database, Kismet will not be able to resolve manufacturers for 
  Wi-Fi devices.
endef



define Package/kismet-tools
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Kismet server and log tools
  URL:=https://www.kismetwireless.net
  DEPENDS:=+kismet +libpthread +libpcap +libpcre +libstdcpp +libsqlite3 +zlib
  SUBMENU:=wireless
endef

define Package/kismet-tools/description
  Kismet server and log manipulation tools for monitoring for announcing
  servers and converting kismetdb logs to wigle, csv, json, pcap, etc.
endef




define Package/kismet-capture-linux-wifi
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Wi-Fi Capture
  URL:=https://www.kismetwireless.net
  DEPENDS:=+libpthread +libpcap +libnl +libcap +protobuf-lite +libprotobuf-c
  SUBMENU:=wireless
endef

define Package/kismet-capture-linux-wifi/description
  Kismet Wi-Fi local and remote capture helper
endef



define Package/kismet-capture-linux-bluetooth
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Bluetooth Capture
  URL:=https://www.kismetwireless.net
  DEPENDS:=+libpthread +libpcap +libnl +libcap +protobuf-lite +libprotobuf-c
  SUBMENU:=wireless
endef

define Package/kismet-capture-linux-blueooth/description
  Kismet Wi-Fi local and remote capture helper
endef



define Build/Configure
  $(call Build/Configure/Default,--with-linux-headers=$(LINUX_DIR))
endef

CONFIGURE_ARGS += \
	$(if $(CONFIG_PACKAGE_kismet),,--enable-capture-tools-only) \
	--sysconfdir=/etc/kismet \
	--bindir=/usr/bin \
	--disable-python-tools \
	--with-protoc=$(STAGING_DIR_HOSTPKG)/bin/protoc \
	--enable-protobuflite \
	--disable-element-typesafety \
	--disable-libusb \
	--disable-debuglibs

# Override libs to force lpthread because we don't detect it properly on openwrt
CONFIGURE_VARS += \
	CXXFLAGS="$$$$CXXFLAGS"  \
	LIBS="-lm -lpthread" 

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR) \
	LD="$(TARGET_CXX)" \
	$(if $(CONFIG_PACKAGE_kismet),all,datasources)
endef



define Package/kismet/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/kismet $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/kismet_cap_pcapfile $(1)/usr/bin/

	$(INSTALL_DIR) $(1)/etc/kismet/
	$(INSTALL_CONF) ./files/kismet_package.conf $(1)/etc/kismet/
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/conf/kismet.conf $(1)/etc/kismet
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/conf/kismet_80211.conf $(1)/etc/kismet
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/conf/kismet_alerts.conf $(1)/etc/kismet
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/conf/kismet_filter.conf $(1)/etc/kismet
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/conf/kismet_httpd.conf $(1)/etc/kismet
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/conf/kismet_logging.conf $(1)/etc/kismet
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/conf/kismet_memory.conf $(1)/etc/kismet
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/conf/kismet_storage.conf $(1)/etc/kismet
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/conf/kismet_uav.conf $(1)/etc/kismet
	cp -Rv $(PKG_BUILD_DIR)/http_data $(1)/etc/kismet/
endef



define Package/kismet-adsb-database/install
	$(INSTALL_DIR) $(1)/etc/kismet/
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/conf/kismet_adsb_icao.txt.gz $(1)/etc/kismet
endef


define Package/kismet-manuf-database/install
	$(INSTALL_DIR) $(1)/etc/kismet/
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/conf/kismet_manuf.txt.gz $(1)/etc/kismet
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/conf/kismet_bluetooth_ids.txt.gz $(1)/etc/kismet
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/conf/kismet_bluetooth_manuf.txt.gz $(1)/etc/kismet
endef


define Package/kismet-tools/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/tools/kismet_discovery $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/log_tools/kismetdb_clean $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/log_tools/kismetdb_dump_devices $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/log_tools/kismetdb_statistics $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/log_tools/kismetdb_strip_packets $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/log_tools/kismetdb_to_gpx $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/log_tools/kismetdb_to_kml $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/log_tools/kismetdb_to_pcap $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/log_tools/kismetdb_to_wiglecsv $(1)/usr/bin/
endef


define Package/kismet-capture-linux-wifi/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/capture_linux_wifi/kismet_cap_linux_wifi $(1)/usr/bin/
endef


$(eval $(call BuildPackage,kismet))
$(eval $(call BuildPackage,kismet-manuf-database))
$(eval $(call BuildPackage,kismet-adsb-database))
$(eval $(call BuildPackage,kismet-tools))
$(eval $(call BuildPackage,kismet-capture-linux-wifi))
$(eval $(call BuildPackage,kismet-capture-linux-bluetooth))

