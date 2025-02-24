include $(TOPDIR)/rules.mk

PKG_NAME:=kismet-capture-rz-killerbee

include ../kismet.mk

include $(INCLUDE_DIR)/package.mk

define Package/kismet-capture-rz-killerbee
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Kismet Killerbee Capture Support
  URL:=https://www.kismetwireless.net
  DEPENDS:=+libpthread +libpcap +libnl +libcap +protobuf-lite +libprotobuf-c +libusb-1.0 
  SUBMENU:=kismet
endef

define Package/kismet-capture-rz-killerbee/description
  Helper binary to capture Zigbee from a Killerbee adapter.
  Enables local and remote 802.15.4 packet capture with Kismet
endef

define Build/Configure
  $(call Build/Configure/Default,--with-linux-headers=$(LINUX_DIR))
endef

CONFIGURE_ARGS += \
	$(CONFIGURE_OPTS) \
	--enable-capture-tools-only

# Override libs to force lpthread because we don't detect it properly on openwrt
CONFIGURE_VARS += \
	CXXFLAGS="$$$$CXXFLAGS"  \
	LIBS="-lm -lpthread" 

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR) \
	LD="$(TARGET_CXX)" \
	capture_rz_killerbee/kismet_cap_rz_killerbee
endef

define Package/kismet-capture-rz-killerbee/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/capture_rz_killerbee/kismet_cap_rz_killerbee $(1)/usr/bin/
endef


$(eval $(call BuildPackage,kismet-capture-rz-killerbee))
