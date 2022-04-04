include $(TOPDIR)/rules.mk

PKG_NAME:=kismet-tools

include ../kismet.mk

include $(INCLUDE_DIR)/package.mk

define Package/kismet-tools
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Kismet server and log tools
  URL:=https://www.kismetwireless.net
  DEPENDS:=+libpthread +libpcap +libpcre +libstdcpp +libsqlite3 +zlib +libatomic +libsensors
  SUBMENU:=kismet
endef

define Package/kismet-tools/description
  Kismet server and log manipulation tools for discovering Kismet
  servers and converting kismetdb logs to wigle, csv, json, pcap, etc.
endef

define Build/Configure
  $(call Build/Configure/Default,--with-linux-headers=$(LINUX_DIR))
endef

CONFIGURE_ARGS += \
	--sysconfdir=/etc/kismet \
	--bindir=/usr/bin \
	--disable-python-tools \
	--with-protoc=$(STAGING_DIR_HOSTPKG)/bin/protoc \
	--enable-protobuflite \
	--disable-element-typesafety \
	--disable-libusb \
	--disable-debuglibs \
	--disable-libwebsockets

# Override libs to force lpthread because we don't detect it properly on openwrt
CONFIGURE_VARS += \
	CXXFLAGS="$$$$CXXFLAGS"  \
	LIBS="-lm -lpthread" 

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR) \
	LD="$(TARGET_CXX)" \
	tools/kismet_discovery \
	log_tools/kismetdb_clean \
	log_tools/kismetdb_dump_devices \
	log_tools/kismetdb_statistics \
	log_tools/kismetdb_strip_packets \
	log_tools/kismetdb_to_gpx \
	log_tools/kismetdb_to_kml \
	log_tools/kismetdb_to_pcap \
	log_tools/kismetdb_to_wiglecsv
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


$(eval $(call BuildPackage,kismet-tools))
