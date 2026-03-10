local uci = require "luci.model.uci".cursor()
local sys = require "luci.sys"

-- ==================== 唤醒表单（SimpleForm） ====================
local f = SimpleForm("woltool", translate("唤醒电脑"),
	translate("从列表中选择一台主机，然后点击「唤醒」按钮。"))

f.reset = false
f.submit = translate("唤醒")

local ws = f:section(SimpleSection)

local host = ws:option(ListValue, "host", translate("主机"))
host.rmempty = false

uci:foreach("wolhost", "host", function(sec)
	local name = sec.name or sec[".name"]
	local mac = sec.mac or ""
	if name and name ~= "" then
		local label = name
		if mac ~= "" then
			label = string.format("%s (%s)", name, mac)
		end
		host:value(name, label)
	end
end)

function f.handle(self, state, data)
	if state == FORM_VALID then
		local h = data and data.host
		if h and #h > 0 then
			sys.call(string.format("woltool %q >/tmp/woltool_last.log 2>&1", h))
		end
	end
	return true
end

-- ==================== 主机管理（Map） ====================
local m = Map("wolhost", translate("主机管理"),
	translate("在这里增删改需要被唤醒的主机。"))

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

return f, m
