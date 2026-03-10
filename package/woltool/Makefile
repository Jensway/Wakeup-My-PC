include $(TOPDIR)/rules.mk

PKG_NAME:=woltool
PKG_VERSION:=1.0.0
PKG_RELEASE:=1
PKGARCH:=all

PKG_MAINTAINER:=Wakeup-My-PC <noreply@example.com>

include $(INCLUDE_DIR)/package.mk

define Package/woltool
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Simple Wake-on-LAN helper for MT-6000
  DEPENDS:=+python3-light
endef

define Package/woltool/description
 A small helper to wake up configured hosts using a Python-based Wake-on-LAN sender on the router.
endef

define Build/Compile
	# script-only package, nothing to compile
endef

define Package/woltool/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) ./files/usr/bin/woltool $(1)/usr/bin/woltool
	$(INSTALL_BIN) ./files/usr/bin/wolmt6000 $(1)/usr/bin/wolmt6000

	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/etc/config/wolhost $(1)/etc/config/wolhost
endef

$(eval $(call BuildPackage,woltool))

