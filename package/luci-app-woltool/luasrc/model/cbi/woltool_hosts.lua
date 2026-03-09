local m = Map("wolhost", translate("主机管理"),
	translate("在这里增删改需要被唤醒的主机。每个主机会出现在“唤醒电脑”的下拉列表中。"))

local s = m:section(TypedSection, "host", translate("主机列表"))
s.addremove = true
s.anonymous = true

local name = s:option(Value, "name", translate("名称"))
name.rmempty = false

local mac = s:option(Value, "mac", translate("MAC 地址"))
mac.rmempty = false

local iface = s:option(Value, "iface", translate("接口"))
iface.placeholder = "br-lan"

return m

