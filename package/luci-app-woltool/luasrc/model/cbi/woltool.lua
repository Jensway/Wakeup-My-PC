local util = require "luci.util"
local disp = require "luci.dispatcher"

local wake_url = disp.build_url("admin", "services", "woltool", "wake")

local m = Map("wolhost", translate("唤醒电脑"),
	translate("点击主机右侧的「唤醒」按钮即可发送唤醒包。可在下方添加或删除主机。") ..
	[=[
<style>
.cbi-section-table { width: 100%; }
.cbi-section-table .td, .cbi-section-table .th { padding: 4px 6px; vertical-align: middle; }
.cbi-section-table input[type="text"] { box-sizing: border-box; width: 100%; min-width: 50px; }
.cbi-section-table .cbi-section-table-cell { width: 1px; white-space: nowrap; text-align: center; }
.cbi-section-table .td:nth-last-child(1),
.cbi-section-table .td:nth-last-child(2),
.cbi-section-table .th:nth-last-child(1),
.cbi-section-table .th:nth-last-child(2) { width: 1px; white-space: nowrap; }

/* 小屏：表格改为卡片式纵向布局，避免错位和空白 */
@media (max-width: 768px) {
	.cbi-section-table, .cbi-section-table thead, .cbi-section-table tbody,
	.cbi-section-table tr, .cbi-section-table th, .cbi-section-table .td,
	.cbi-section-table td { display: block; }
	.cbi-section-table thead { display: none; }
	.cbi-section-table tbody tr {
		margin-bottom: 16px;
		padding: 12px;
		border: 1px solid #e0e0e0;
		border-radius: 6px;
		background: #fafafa;
	}
	.cbi-section-table .td, .cbi-section-table td {
		width: 100% !important;
		padding: 8px 0 !important;
		border: none !important;
		white-space: normal !important;
	}
	.cbi-section-table .td::before, .cbi-section-table td::before {
		display: block;
		font-weight: bold;
		margin-bottom: 4px;
		color: #333;
	}
	.cbi-section-table .td:nth-child(1)::before, .cbi-section-table td:nth-child(1)::before { content: "名称:"; }
	.cbi-section-table .td:nth-child(2)::before, .cbi-section-table td:nth-child(2)::before { content: "MAC 地址:"; }
	.cbi-section-table .td:nth-child(3)::before, .cbi-section-table td:nth-child(3)::before { content: "接口:"; }
	.cbi-section-table .td:nth-child(4)::before, .cbi-section-table td:nth-child(4)::before { content: "操作:"; }
	.cbi-section-table .td:nth-child(5)::before, .cbi-section-table td:nth-child(5)::before { content: ""; margin: 0; }
	.cbi-section-table .td:nth-child(4), .cbi-section-table .td:nth-child(5),
	.cbi-section-table td:nth-child(4), .cbi-section-table td:nth-child(5) {
		display: flex !important;
		flex-wrap: wrap;
		gap: 8px;
		align-items: center;
	}
	.cbi-section-table .td:nth-child(4)::before, .cbi-section-table .td:nth-child(5)::before,
	.cbi-section-table td:nth-child(4)::before, .cbi-section-table td:nth-child(5)::before { display: none; }
	.cbi-section-table .td:nth-child(4) .cbi-button, .cbi-section-table .td:nth-child(5) .cbi-button,
	.cbi-section-table .td:nth-child(5) a, .cbi-section-table td:nth-child(4) .cbi-button,
	.cbi-section-table td:nth-child(5) .cbi-button, .cbi-section-table td:nth-child(5) a { margin: 0; }
	.cbi-section-table input[type="text"] { max-width: 100%; }
	.cbi-section-table .cbi-button-add { margin-top: 8px; }
}
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
