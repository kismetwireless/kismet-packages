include $(TOPDIR)/rules.mk

PKG_NAME:=kismet-capture-linux-wifi

include ../kismet.mk

include $(INCLUDE_DIR)/package.mk

define Package/kismet-capture-linux-wifi
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Kismet Wi-Fi Capture Support
  URL:=https://www.kismetwireless.net
  DEPENDS:=+libpthread +libpcap +libnl +libcap +protobuf-lite +libprotobuf-c +libwebsockets-full
  SUBMENU:=kismet
endef

define Package/kismet-capture-linux-wifi/description
  Helper binary to capture Wi-Fi packets from a monitor mode adapter.
  Enables local and remote Wi-Fi capture with Kismet
endef

define Build/Configure
  $(call Build/Configure/Default,--with-linux-headers=$(LINUX_DIR))
endef

CONFIGURE_ARGS += \
	$(CONFIGURE_OPTS) \
	--disable-libusb \
	--enable-capture-tools-only

# Override libs to force lpthread because we don't detect it properly on openwrt
CONFIGURE_VARS += \
	CXXFLAGS="$$$$CXXFLAGS"  \
	LIBS="-lm -lpthread" 

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR) \
	LD="$(TARGET_CXX)" \
	capture_linux_wifi/kismet_cap_linux_wifi 
endef

define Package/kismet-capture-linux-wifi/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/capture_linux_wifi/kismet_cap_linux_wifi $(1)/usr/bin/
endef


$(eval $(call BuildPackage,kismet-capture-linux-wifi))
