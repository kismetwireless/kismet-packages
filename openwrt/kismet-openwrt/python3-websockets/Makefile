
include $(TOPDIR)/rules.mk

PKG_NAME:=python3-websockets
PKG_VERSION:=8.1
PKG_RELEASE:=1

PKG_SOURCE:=websockets-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://files.pythonhosted.org/packages/source/w/websockets/
PKG_HASH:=5c65d2da8c6bce0fca2528f69f44b2f977e06954c8512a952222cea50dad430f

PKG_BUILD_DIR:=$(BUILD_DIR)/websockets-$(PKG_VERSION)

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
$(eval $(call BuildPackage,python3-websockets-src))

