
include $(TOPDIR)/rules.mk

PKG_NAME:=python3-numpy
PKG_VERSION:=1.19.1
PKG_RELEASE:=1

PKG_SOURCE:=numpy-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/numpy/numpy/releases/download/v${PKG_VERSION}/
PKG_HASH:=1396e6c3d20cbfc119195303b0272e749610b7042cc498be4134f013e9a3215c

PKG_BUILD_DIR:=$(BUILD_DIR)/numpy-$(PKG_VERSION)

HOST_PYTHON3_PACKAGE_BUILD_DEPENDS:=cython

include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/packages/lang/python/python-package.mk
include $(TOPDIR)/feeds/packages/lang/python/python3-package.mk

define Package/python3-numpy
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Numpy
  URL:=https://github.com/numpy/numpy
  DEPENDS:= \
	+PACKAGE_python3-numpy:python3-light \
	+PACKAGE_python3-numpy:python3-setuptools \
	+PACKAGE_python3-numpy:python3-cython
  VARIANT:=python3
endef

define Package/python3-numpy/description
   Numpy math library for Python3
endef

$(eval $(call Py3Package,python3-numpy))
$(eval $(call BuildPackage,python3-numpy))
$(eval $(call BuildPackage,python3-numpy-src))

