
include $(TOPDIR)/rules.mk

PKG_NAME:=python3-websockets
PKG_VERSION:=12.0
PKG_RELEASE:=1

PKG_SOURCE:=websockets-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://files.pythonhosted.org/packages/source/w/websockets/
PKG_HASH:=81df9cbcbb6c260de1e007e58c011bfebe2dafc8435107b0537f393dd38c8b1b

PKG_BUILD_DIR:=$(BUILD_DIR)/websockets-$(PKG_VERSION)

PYPI_NAME:=websockets

include $(TOPDIR)/feeds/packages/lang/python/pypi.mk
include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/packages/lang/python/python3-package.mk

define Package/python3-websockets
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Websockets
  URL:=https://pypi.org/project/websockets/
  DEPENDS:= \
	+python3-light \
	+python3-setuptools 
  VARIANT:=python3
endef

define Package/python3-websockets/description
	Websockets implementation for python3
endef

$(eval $(call Py3Package,python3-websockets))
$(eval $(call BuildPackage,python3-websockets))
#$(eval $(call BuildPackage,python3-websockets-src))

