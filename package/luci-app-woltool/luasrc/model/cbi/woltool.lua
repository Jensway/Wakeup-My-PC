local util = require "luci.util"
local disp = require "luci.dispatcher"

local wake_url = disp.build_url("admin", "services", "woltool", "wake")

local m = Map("wolhost", translate("唤醒电脑"),
	translate("点击主机右侧的「唤醒」按钮即可发送唤醒包。可在下方添加或删除主机。") ..
	[=[
<style>
.cbi-section-table { table-layout: fixed; width: 100%; }
.cbi-section-table input[type="text"] { width: 100%; box-sizing: border-box; }
.cbi-section-table .td, .cbi-section-table .th { overflow: hidden; text-overflow: ellipsis; white-space: nowrap; padding: 4px 6px; }
</style>
]=] ..
	string.format([=[
<script>
var wolUrl = '%s';
function wolWake(btn) {
	var name = btn.getAttribute('data-name');
	btn.disabled = true;
	var orig = btn.value;
	btn.value = '发送中...';
	var tk = document.querySelector('input[name="token"]');
	var xhr = new XMLHttpRequest();
	xhr.open('POST', wolUrl, true);
	xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
	xhr.onload = function() {
		btn.disabled = false;
		btn.value = orig;
		try {
			var r = JSON.parse(xhr.responseText);
			alert(r.success ? '\u2714 ' + r.message : '\u2716 ' + r.message);
		} catch(e) {
			alert(xhr.status === 200 ? '\u2714 唤醒包已发送' : '\u2716 请求失败');
		}
	};
	xhr.onerror = function() {
		btn.disabled = false;
		btn.value = orig;
		alert('\u2716 网络请求失败');
	};
	var body = 'name=' + encodeURIComponent(name);
	if (tk) body += '&token=' + encodeURIComponent(tk.value);
	xhr.send(body);
}
</script>
]=], wake_url))

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

local wake = s:option(DummyValue, "_wake", translate("操作"))
wake.rawhtml = true
wake.cfgvalue = function(self, section)
	local name = m:get(section, "name") or ""
	return string.format(
		'<input type="button" class="cbi-button cbi-button-apply" value="%s" data-name="%s" onclick="wolWake(this)" />',
		translate("唤醒"),
		util.pcdata(name)
	)
end

return m
