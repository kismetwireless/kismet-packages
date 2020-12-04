include $(TOPDIR)/rules.mk

PKG_NAME:=kismet

PKG_BUILD_PARALLEL:=1
HOST_BUILD_PARALLEL:=1 

PKG_BUILD_DEPENDS += protobuf/host

include ../kismet.mk

include $(INCLUDE_DIR)/package.mk

# We need libwebsockets 3.2 or higher, which apparently is nonfunctional on openwrt

define Package/kismet
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Kismet 2020
  URL:=https://www.kismetwireless.net/
  DEPENDS:=+libpthread +libpcap +libpcre +libstdcpp +libncurses +libsqlite3 +zlib +protobuf-lite +libprotobuf-c +libsensors
  SUBMENU:=kismet
endef

define Package/kismet/description
  Modern Kismet wireless capture and IDS, with the web-ui based Kismet
endef

define Build/Configure
  $(call Build/Configure/Default,--with-linux-headers=$(LINUX_DIR))
endef

CONFIGURE_ARGS += \
	$(CONFIGURE_OPTS) \
	--disable-libusb 

# Override libs to force lpthread because we don't detect it properly on openwrt
CONFIGURE_VARS += \
	CXXFLAGS="$$$$CXXFLAGS"  \
	LIBS="-lm -lpthread" 

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR) \
	LD="$(TARGET_CXX)" \
	kismet 
endef

define Package/kismet/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/kismet $(1)/usr/bin/

	$(INSTALL_DIR) $(1)/etc/kismet/
	$(INSTALL_CONF) ./files/kismet_package.conf $(1)/etc/kismet/
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/conf/kismet.conf $(1)/etc/kismet
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/conf/kismet_80211.conf $(1)/etc/kismet
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/conf/kismet_alerts.conf $(1)/etc/kismet
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/conf/kismet_filter.conf $(1)/etc/kismet
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/conf/kismet_httpd.conf $(1)/etc/kismet
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/conf/kismet_logging.conf $(1)/etc/kismet
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/conf/kismet_memory.conf $(1)/etc/kismet
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/conf/kismet_uav.conf $(1)/etc/kismet
	cp -Rv $(PKG_BUILD_DIR)/http_data $(1)/etc/kismet/
endef

$(eval $(call BuildPackage,kismet))

