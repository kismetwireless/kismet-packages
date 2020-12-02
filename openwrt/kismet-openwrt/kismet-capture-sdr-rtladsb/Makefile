## CURRENTLY NOT USABLE

include $(TOPDIR)/rules.mk

PKG_NAME:=kismet-capture-sdr-rtladsb

include ../kismet.mk

include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/packages/lang/python/python-package.mk
include $(TOPDIR)/feeds/packages/lang/python/python3-package.mk

KISMET_MODULE:=KismetCaptureRtladsb

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
	  +python3-websockets \
	  +librtlsdr
  SUBMENU:=kismet
  VARIANT:=python3
endef

define Package/kismet-capture-sdr-rtladsb/description
  Helper binary to capture ADSB packets from a rtlsdr.
  Enables local and remote ADSB capture with Kismet
endef

define Build/Prepare
	(cd $(PKG_BUILD_DIR) && \
		tar -xzf $(DL_DIR)/$(PKG_SOURCE) $(PKG_NAME)-$(PKG_VERSION)/capture_sdr_rtladsb/ --strip-components 2 && \
		tar -xzf $(DL_DIR)/$(PKG_SOURCE) $(PKG_NAME)-$(PKG_VERSION)/protobuf_definitions/ --strip-components 1 && \
	$(STAGING_DIR_HOSTPKG)/bin/protoc -I protobuf_definitions/ --python_out=$(KISMET_MODULE)/kismetexternal protobuf_definitions/kismet.proto && \
	$(STAGING_DIR_HOSTPKG)/bin/protoc -I protobuf_definitions/ --python_out=$(KISMET_MODULE)/kismetexternal protobuf_definitions/http.proto && \
	$(STAGING_DIR_HOSTPKG)/bin/protoc -I protobuf_definitions/ --python_out=$(KISMET_MODULE)/kismetexternal protobuf_definitions/eventbus.proto && \
	$(STAGING_DIR_HOSTPKG)/bin/protoc -I protobuf_definitions/ --python_out=$(KISMET_MODULE)/kismetexternal protobuf_definitions/datasource.proto && \
	sed -i -E 's/^import kismet_/from . import kismet_/' $(KISMET_MODULE)/kismetexternal/kismet_pb2.py && \
	sed -i -E 's/^import kismet_/from . import kismet_/' $(KISMET_MODULE)/kismetexternal/http_pb2.py && \
	sed -i -E 's/^import kismet_/from . import kismet_/' $(KISMET_MODULE)/kismetexternal/eventbus_pb2.py && \
	sed -i -E 's/^import kismet_/from . import kismet_/' $(KISMET_MODULE)/kismetexternal/datasource_pb2.py \
	)
endef

$(eval $(call Py3Package,kismet-capture-sdr-rtladsb))
$(eval $(call BuildPackage,kismet-capture-sdr-rtladsb))
#$(eval $(call BuildPackage,kismet-capture-sdr-rtladsb-src))
