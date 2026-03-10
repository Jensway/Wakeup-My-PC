local util = require "luci.util"
local disp = require "luci.dispatcher"

local wake_url = disp.build_url("admin", "services", "woltool", "wake")

local m = Map("wolhost", translate("唤醒电脑"),
	translate("点击主机右侧的「唤醒」按钮即可发送唤醒包。可在下方添加或删除主机。") ..
	[=[
<style>
@media screen and (max-width: 768px) {
	.cbi-section-table .tr { display: block; margin-bottom: 10px; border-bottom: 1px solid #ccc; padding-bottom: 8px; }
	.cbi-section-table .tr.cbi-section-table-titles { display: none; }
	.cbi-section-table .td { display: block; text-align: left !important; padding: 3px 8px; position: relative; padding-left: 40%; }
	.cbi-section-table .td::before { content: attr(data-title); position: absolute; left: 8px; font-weight: bold; width: 35%; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
	.cbi-section-table .td.cbi-section-table-cell { padding-left: 8px; text-align: center !important; }
	.cbi-section-table .td.cbi-section-table-cell input[type="button"] { width: 100%; }
	.cbi-section-table .cbi-button-up, .cbi-section-table .cbi-button-down { display: none; }
}
</style>
<script>
document.addEventListener('DOMContentLoaded', function() {
	var ths = document.querySelectorAll('.cbi-section-table .tr.cbi-section-table-titles .th');
	var titles = [];
	for (var i = 0; i < ths.length; i++) titles.push(ths[i].textContent.trim());
	var rows = document.querySelectorAll('.cbi-section-table .tr:not(.cbi-section-table-titles)');
	for (var r = 0; r < rows.length; r++) {
		var tds = rows[r].querySelectorAll('.td');
		for (var c = 0; c < tds.length && c < titles.length; c++) {
			if (titles[c]) tds[c].setAttribute('data-title', titles[c]);
		}
	}
});
</script>
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
