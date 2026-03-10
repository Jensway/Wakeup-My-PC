local sys = require "luci.sys"

local m = Map("wolhost", translate("唤醒电脑"),
	translate("点击主机右侧的「唤醒」按钮即可发送唤醒包。可在下方添加或删除主机。"))

local s = m:section(TypedSection, "host")
s.template = "cbi/tblsection"
s.addremove = true
s.anonymous = true

local name_opt = s:option(Value, "name", translate("名称"))
name_opt.rmempty = false

local mac_opt = s:option(Value, "mac", translate("MAC 地址"))
mac_opt.rmempty = false

local iface_opt = s:option(Value, "iface", translate("接口"))
iface_opt.placeholder = "br-lan"

local wake = s:option(Button, "_wake", translate("唤醒"))
wake.inputtitle = translate("唤醒")
wake.inputstyle = "apply"
wake.write = function(self, section)
	local name = m:get(section, "name")
	if name and #name > 0 then
		sys.call(string.format("woltool %q >/tmp/woltool_last.log 2>&1", name))
	end
end

return m
