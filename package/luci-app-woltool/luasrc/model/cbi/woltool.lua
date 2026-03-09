local uci = require "luci.model.uci".cursor()
local sys = require "luci.sys"

local m = SimpleForm("woltool", translate("唤醒电脑"),
	translate("从列表中选择一台主机，然后点击“唤醒”按钮。主机信息来自 /etc/config/wolhost。"))

m.reset = false
m.submit = translate("唤醒")

local s = m:section(SimpleSection)

local host = s:option(ListValue, "host", translate("主机"))
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

function m.handle(self, state, data)
	if state == FORM_VALID then
		local h = data and data.host
		if h and #h > 0 then
			-- 调用命令行工具 woltool <name>
			sys.call(string.format("woltool %q >/tmp/woltool_last.log 2>&1", h))
		end
	end

	-- 不调用 SimpleForm.handle，直接返回 true 以避免兼容性问题
	return true
end

return m

