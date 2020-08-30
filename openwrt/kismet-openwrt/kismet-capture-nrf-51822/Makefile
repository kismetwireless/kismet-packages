include $(TOPDIR)/rules.mk

PKG_NAME:=kismet-capture-nrf-51822

include ../kismet.mk

include $(INCLUDE_DIR)/package.mk

define Package/kismet-capture-nrf-51822
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Kismet NRF51822 BTLE
  URL:=https://www.kismetwireless.net
  DEPENDS:=+libpthread +libpcap +libnl +libcap +protobuf-lite +libprotobuf-c +libusb-1.0
  SUBMENU:=kismet
endef

define Package/kismet-capture-nrf-51822/description
  Helper binary to capture BTLE from a NRF51822 serial adapter.
  Enables local and remote BTLE packet capture with Kismet
endef

define Build/Configure
  $(call Build/Configure/Default,--with-linux-headers=$(LINUX_DIR))
endef

CONFIGURE_ARGS += \
	--enable-capture-tools-only \
	--sysconfdir=/etc/kismet \
	--bindir=/usr/bin \
	--disable-python-tools \
	--with-protoc=$(STAGING_DIR_HOSTPKG)/bin/protoc \
	--enable-protobuflite \
	--disable-element-typesafety \
	--disable-debuglibs

# Override libs to force lpthread because we don't detect it properly on openwrt
CONFIGURE_VARS += \
	CXXFLAGS="$$$$CXXFLAGS"  \
	LIBS="-lm -lpthread" 

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR) \
	LD="$(TARGET_CXX)" \
	capture_nrf_51822/kismet_cap_nrf_51822
endef

define Package/kismet-capture-nrf-51822/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/capture_nrf_51822/kismet_cap_nrf_51822 $(1)/usr/bin/
endef


$(eval $(call BuildPackage,kismet-capture-nrf-51822))
