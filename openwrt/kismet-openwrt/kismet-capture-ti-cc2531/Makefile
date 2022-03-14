include $(TOPDIR)/rules.mk

PKG_NAME:=kismet-capture-ti-cc2531

include ../kismet.mk

include $(INCLUDE_DIR)/package.mk

define Package/kismet-capture-ti-cc2531
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Kismet TI CC2531 802.15.4 Capture Support
  URL:=https://www.kismetwireless.net
  DEPENDS:=+libpthread +libpcap +libnl +libcap +protobuf-lite +libprotobuf-c +libusb-1.0 
  SUBMENU:=kismet
endef

define Package/kismet-capture-ti-cc2531/description
  Helper binary to capture 802.15.4 packets from a TI CC2531 adapter.
  Enables local and remote 802.15.4 capture with Kismet
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
	capture_ti_cc_2531/kismet_cap_ti_cc_2531
endef

define Package/kismet-capture-ti-cc2531/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/capture_ti_cc_2531/kismet_cap_ti_cc_2531 $(1)/usr/bin/
endef


$(eval $(call BuildPackage,kismet-capture-ti-cc2531))
