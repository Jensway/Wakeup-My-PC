module("luci.controller.woltool", package.seeall)

function index()
	local fs = require "nixio.fs"

	if not fs.access("/etc/config/wolhost") then
		return
	end

	entry({"admin", "services", "woltool"}, cbi("woltool"), _("唤醒电脑"), 60).dependent = true
	entry({"admin", "services", "woltool", "wake"}, call("action_wake")).leaf = true
end

function action_wake()
	local http = require "luci.http"
	local sys = require "luci.sys"

	local name = http.formvalue("name")
	if name and #name > 0 then
		local code = sys.call(string.format("woltool %q >/tmp/woltool_last.log 2>&1", name))
		http.prepare_content("application/json")
		if code == 0 then
			http.write_json({ success = true, message = "唤醒包已发送至 " .. name })
		else
			http.write_json({ success = false, message = "发送失败，错误码: " .. tostring(code) })
		end
	else
		http.status(400, "Bad Request")
		http.prepare_content("application/json")
		http.write_json({ success = false, message = "未指定主机名称" })
	end
end
