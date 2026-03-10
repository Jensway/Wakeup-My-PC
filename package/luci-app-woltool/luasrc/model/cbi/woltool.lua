local uci = require "luci.model.uci".cursor()
local sys = require "luci.sys"
local http = require "luci.http"

local m = Map("wolhost", translate("唤醒电脑"),
	translate("选择主机进行唤醒，或在下方管理主机列表。"))

m.reset = false

-- 检测是否点击了「唤醒」按钮（任一表单值为「唤醒」即视为点击）
local function is_wake_submit()
	for k, v in pairs(http.formvalue() or {}) do
		if v == translate("唤醒") then
			return true
		end
	end
	return false
end

-- 唤醒区域：标题加大加粗，下方为下拉与唤醒按钮
local wake_sec = m:section(SimpleSection, translate("唤醒电脑"), translate("从列表中选择一台主机，然后点击「唤醒」按钮。"))
wake_sec.anonymous = true

-- 注入样式：本页第一个 section 标题加大加粗，与下方「主机管理」区分
local style_opt = wake_sec:option(DummyValue, "_wake_style", "")
style_opt.rawhtml = true
function style_opt.cfgvalue()
	return '<style>.cbi-section:first-of-type .cbi-section-title{font-size:1.25em;font-weight:bold}</style>' ..
		'<style>.cbi-section:first-of-type tr[data-id$="_wake_style"]{display:none}</style>'
end

local host = wake_sec:option(ListValue, "wake_host", translate("主机"))
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

local wake_btn = wake_sec:option(Button, "wake_btn", translate("唤醒"))

-- 主机管理区域：表格布局，一行一台主机
local s = m:section(TypedSection, "host", translate("主机管理"))
s.template = "cbi/tblsection"
s.addremove = true
s.anonymous = true

local name_opt = s:option(Value, "name", translate("名称"))
name_opt.rmempty = false

local mac_opt = s:option(Value, "mac", translate("MAC 地址"))
mac_opt.rmempty = false

local iface_opt = s:option(Value, "iface", translate("接口"))
iface_opt.placeholder = "br-lan"

-- 提交时：若为「唤醒」则执行命令并重定向，否则走默认保存
function m.parse(self, ...)
	if is_wake_submit() then
		local h
		for k, v in pairs(http.formvalue() or {}) do
			if k and k:find("wake_host") and v and #v > 0 then
				h = v
				break
			end
		end
		if h then
			sys.call(string.format("woltool %q >/tmp/woltool_last.log 2>&1", h))
		end
		http.redirect(luci.dispatcher.build_url("admin", "services", "woltool"))
		return
	end
	return Map.parse(self, ...)
end

return m
