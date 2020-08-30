include $(TOPDIR)/rules.mk

PKG_NAME:=kismet-capture-linux-bluetooth

include ../kismet.mk

include $(INCLUDE_DIR)/package.mk

define Package/kismet-capture-linux-bluetooth
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Kismet HCI Bluetooth Support
  URL:=https://www.kismetwireless.net
  DEPENDS:=+libpthread +libpcap +libnl +libcap +protobuf-lite +libprotobuf-c
  SUBMENU:=kismet
endef

define Package/kismet-capture-linux-blueooth/description
  Helper binary to capture Bluetooth device info from a HCI adapter.
  Enables local and remote Bluetooth device discovery with Kismet
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
	--disable-libusb \
	--disable-debuglibs

# Override libs to force lpthread because we don't detect it properly on openwrt
CONFIGURE_VARS += \
	CXXFLAGS="$$$$CXXFLAGS"  \
	LIBS="-lm -lpthread" 

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR) \
	LD="$(TARGET_CXX)" \
	capture_linux_bluetooth/kismet_cap_linux_bluetooth
endef

define Package/kismet-capture-linux-bluetooth/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/capture_linux_bluetooth/kismet_cap_linux_bluetooth $(1)/usr/bin/
endef


$(eval $(call BuildPackage,kismet-capture-linux-bluetooth))
