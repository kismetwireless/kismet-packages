include $(TOPDIR)/rules.mk

PKG_NAME:=kismet-capture-nrf-52840

include ../kismet.mk

include $(INCLUDE_DIR)/package.mk

define Package/kismet-capture-nrf-52840
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Kismet NRF52840 Bluetooth Source
  URL:=https://www.kismetwireless.net
  DEPENDS:=+libpthread +libpcap +libnl +libcap +protobuf-lite +libprotobuf-c +libusb-1.0 
  SUBMENU:=kismet
endef

define Package/kismet-capture-nrf-52840/description
  Helper binary to use an NRF52840 serial adapter as a Bluetooth capture source.
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
	capture_nrf_52840/kismet_cap_nrf_52840
endef

define Package/kismet-capture-nrf-52840/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/capture_nrf_52840/kismet_cap_nrf_52840 $(1)/usr/bin/
endef


$(eval $(call BuildPackage,kismet-capture-nrf-52840))
