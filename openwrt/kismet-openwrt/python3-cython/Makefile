
include $(TOPDIR)/rules.mk

PKG_NAME:=python3-cython
PKG_VERSION:=0.29.21
PKG_RELEASE:=1

PKG_SOURCE:=Cython-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://files.pythonhosted.org/packages/source/c/cython/
PKG_HASH:=e57acb89bd55943c8d8bf813763d20b9099cc7165c0f16b707631a7654be9cad

PKG_BUILD_DIR:=$(BUILD_DIR)/Cython-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/packages/lang/python/python-package.mk
include $(TOPDIR)/feeds/packages/lang/python/python3-package.mk

define Package/python3-cython
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Cython
  URL:=https://pypi.org/project/Cython/
  DEPENDS:= \
	+python3-light \
	+python3-setuptools 
  VARIANT:=python3
endef

define Package/python3-cython/description
   C language extension library for Python
endef

$(eval $(call Py3Package,python3-cython))
$(eval $(call BuildPackage,python3-cython))
$(eval $(call BuildPackage,python3-cython-src))

