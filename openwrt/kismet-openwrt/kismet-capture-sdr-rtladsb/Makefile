## CURRENTLY NOT USABLE

include $(TOPDIR)/rules.mk

PKG_NAME:=kismet-capture-sdr-rtladsb

include ../kismet.mk

include $(INCLUDE_DIR)/package.mk
$(call include_mk, python3-package.mk)

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
	  +python3-protobuf
  SUBMENU:=wireless
  VARIANT:=python3
endef

define Package/kismet-capture-sdr-rtladsb/description
  Helper binary to capture ADSB packets from a rtlsdr.
  Enables local and remote ADSB capture with Kismet
endef


$(eval $(call Py3Package,kismet-capture-sdr-rtladsb))
$(eval $(call BuildPackage,kismet-capture-sdr-rtladsb))
#$(eval $(call BuildPackage,kismet-capture-sdr-rtladsb-src))
