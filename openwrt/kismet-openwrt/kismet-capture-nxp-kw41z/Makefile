include $(TOPDIR)/rules.mk

PKG_NAME:=kismet-capture-nxp-kw41z

include ../kismet.mk

include $(INCLUDE_DIR)/package.mk

define Package/kismet-capture-nxp-kw41z
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Kismet NXPKW41Z Capture Support
  URL:=https://www.kismetwireless.net
  DEPENDS:=+libpthread +libpcap +libnl +libcap +protobuf-lite +libprotobuf-c +libusb-1.0 +libwebsockets-full
  SUBMENU:=kismet
endef

define Package/kismet-capture-nxp-kw41z/description
  Helper binary to capture BTLE from a NXPKW41Z adapter.
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
	capture_nxp_kw41z/kismet_cap_nxp_kw41z
endef

define Package/kismet-capture-nxp-kw41z/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/capture_nxp_kw41z/kismet_cap_nxp_kw41z $(1)/usr/bin/
endef


$(eval $(call BuildPackage,kismet-capture-nxp-kw41z))
