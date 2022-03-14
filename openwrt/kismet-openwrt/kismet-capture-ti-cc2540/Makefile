include $(TOPDIR)/rules.mk

PKG_NAME:=kismet-capture-ti-cc2540

include ../kismet.mk

include $(INCLUDE_DIR)/package.mk

define Package/kismet-capture-ti-cc2540
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Kismet TI CC2540 BTLE Capture Support
  URL:=https://www.kismetwireless.net
  DEPENDS:=+libpthread +libpcap +libnl +libcap +protobuf-lite +libprotobuf-c +libusb-1.0 
  SUBMENU:=kismet
endef

define Package/kismet-capture-ti-cc2540/description
  Helper binary to capture BTLE packets from a TI CC2540 adapter.
  Enables local and remote BTLE capture with Kismet
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
	capture_ti_cc_2540/kismet_cap_ti_cc_2540
endef

define Package/kismet-capture-ti-cc2540/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/capture_ti_cc_2540/kismet_cap_ti_cc_2540 $(1)/usr/bin/
endef


$(eval $(call BuildPackage,kismet-capture-ti-cc2540))
