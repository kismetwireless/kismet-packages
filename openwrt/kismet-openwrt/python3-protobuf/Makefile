
include $(TOPDIR)/rules.mk

PKG_NAME:=python3-protobuf
PKG_VERSION:=4.25.1
PKG_RELEASE:=1

PKG_SOURCE:=protobuf-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://files.pythonhosted.org/packages/source/p/protobuf/
PKG_HASH:=57d65074b4f5baa4ab5da1605c02be90ac20c8b40fb137d6a8df9f416b0d0ce2

PKG_BUILD_DIR:=$(BUILD_DIR)/protobuf-$(PKG_VERSION)

PYPI_NAME=protobuf

include $(TOPDIR)/feeds/packages/lang/python/pypi.mk
include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/packages/lang/python/python3-package.mk

define Package/python3-protobuf
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Protobuf implementation in Python
  URL:=https://developers.google.com/protocol-buffers/
  DEPENDS:= \
	+python3-light \
	+python3-setuptools \
	+python3-six
  VARIANT:=python3
endef

define Package/python3-protobuf/description
   The official implementation of Google Protobufs in Python3
endef

$(eval $(call Py3Package,python3-protobuf))
$(eval $(call BuildPackage,python3-protobuf))
#$(eval $(call BuildPackage,python3-protobuf-src))
