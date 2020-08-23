## CURRENTLY NOT USABLE

include $(TOPDIR)/rules.mk

PKG_NAME:=kismet-capture-sdr-rtladsb

include ../kismet.mk

#PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)
#PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)/capture_sdr_rtladsb/
#PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

#PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)/capture_sdr_rtladsb/

include $(INCLUDE_DIR)/package.mk
# include files/python3-host.mk
# include files/python3-package.mk
include $(TOPDIR)/feeds/packages/lang/python/python-package.mk
include $(TOPDIR)/feeds/packages/lang/python/python3-package.mk

define Package/kismet-capture-sdr-rtladsb
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Kismet ADSB SDR Capture Support
  URL:=https://www.kismetwireless.net
  DEPENDS:= \
	  +python3 \
	  +python3-setuptools \
	  +python3-cffi \
	  +python3-numpy \
	  +python3-protobuf \
	  +librtlsdr
  SUBMENU:=wireless
  VARIANT:=python3
endef

define Package/kismet-capture-sdr-rtladsb/description
  Helper binary to capture ADSB packets from a rtlsdr.
  Enables local and remote ADSB capture with Kismet
endef

define Build/Prepare
	(cd $(PKG_BUILD_DIR) && tar -xzf $(DL_DIR)/$(PKG_SOURCE) $(PKG_NAME)-$(PKG_VERSION)/capture_sdr_rtladsb/ --strip-components 2)
endef

$(eval $(call Py3Package,kismet-capture-sdr-rtladsb))
$(eval $(call BuildPackage,kismet-capture-sdr-rtladsb))
$(eval $(call BuildPackage,kismet-capture-sdr-rtladsb-src))
