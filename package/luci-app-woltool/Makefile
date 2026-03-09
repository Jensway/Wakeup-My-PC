include $(TOPDIR)/rules.mk

LUCI_TITLE:=Wakeup-My-PC (woltool) Web UI
LUCI_PKGARCH:=all

PKG_NAME:=luci-app-woltool
PKG_VERSION:=1.0.0
PKG_RELEASE:=1

PKG_MAINTAINER:=Wakeup-My-PC <noreply@example.com>

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
  SECTION:=luci
  CATEGORY:=LuCI
  SUBMENU:=3. Applications
  TITLE:=$(LUCI_TITLE)
  DEPENDS:=+luci-base +woltool
endef

define Package/$(PKG_NAME)/description
 Simple LuCI interface for woltool.
 Allows selecting a host from /etc/config/wolhost and sending Wake-on-LAN packets.
endef

define Build/Compile
	# Lua/CBI only, nothing to compile
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/controller
	$(INSTALL_DATA) ./luasrc/controller/woltool.lua $(1)/usr/lib/lua/luci/controller/woltool.lua

	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/model/cbi
	$(INSTALL_DATA) ./luasrc/model/cbi/woltool.lua $(1)/usr/lib/lua/luci/model/cbi/woltool.lua
endef

$(eval $(call BuildPackage,$(PKG_NAME)))

