module("luci.controller.woltool", package.seeall)

function index()
	local fs = require "nixio.fs"

	-- 如果没有配置文件，就不显示菜单
	if not fs.access("/etc/config/wolhost") then
		return
	end

	entry({"admin", "services", "woltool"}, cbi("woltool"), _("唤醒电脑"), 60).dependent = true
	entry({"admin", "services", "woltool", "hosts"}, cbi("woltool_hosts"), _("主机管理"), 61).dependent = true
end

