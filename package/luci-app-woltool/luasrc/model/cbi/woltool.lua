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

/* 手机端布局 */
@media (max-width: 768px) {
	/* 表格改为卡片式 */
	.cbi-section-table,
	.cbi-section-table thead,
	.cbi-section-table tbody,
	.cbi-section-table tr,
	.cbi-section-table th,
	.cbi-section-table .td,
	.cbi-section-table td {
		display: block !important;
		width: auto !important;
	}
	.cbi-section-table thead { display: none !important; }
	.cbi-section-table tbody tr {
		margin: 8px 0;
		padding: 10px;
		border: 1px solid #ddd;
		border-radius: 4px;
		background: #f9f9f9;
	}

	/* 名称、MAC、接口三列 - 各占一行 */
	.cbi-section-table tbody tr td:nth-child(1),
	.cbi-section-table tbody tr td:nth-child(2),
	.cbi-section-table tbody tr td:nth-child(3),
	.cbi-section-table tbody tr .td:nth-child(1),
	.cbi-section-table tbody tr .td:nth-child(2),
	.cbi-section-table tbody tr .td:nth-child(3) {
		width: 100% !important;
		padding: 6px 0 !important;
		border-bottom: 1px solid #eee !important;
	}
	.cbi-section-table tbody tr td:nth-child(1)::before { content: "名称: "; font-weight: bold; }
	.cbi-section-table tbody tr td:nth-child(2)::before { content: "MAC: "; font-weight: bold; }
	.cbi-section-table tbody tr td:nth-child(3)::before { content: "接口: "; font-weight: bold; }
	.cbi-section-table tbody tr .td:nth-child(1)::before { content: "名称: "; font-weight: bold; }
	.cbi-section-table tbody tr .td:nth-child(2)::before { content: "MAC: "; font-weight: bold; }
	.cbi-section-table tbody tr .td:nth-child(3)::before { content: "接口: "; font-weight: bold; }

	/* 操作列和删除列 - 横向排列在同一行 */
	.cbi-section-table tbody tr td:nth-child(4),
	.cbi-section-table tbody tr td:nth-child(5),
	.cbi-section-table tbody tr .td:nth-child(4),
	.cbi-section-table tbody tr .td:nth-child(5) {
		display: inline-block !important;
		width: auto !important;
		padding: 6px 4px 6px 0 !important;
		border: none !important;
		vertical-align: middle !important;
	}
	.cbi-section-table tbody tr td:nth-child(4)::before,
	.cbi-section-table tbody tr td:nth-child(5)::before,
	.cbi-section-table tbody tr .td:nth-child(4)::before,
	.cbi-section-table tbody tr .td:nth-child(5)::before {
		display: none !important;
	}

	/* 按钮样式 */
	.cbi-section-table tbody input[type="button"],
	.cbi-section-table tbody a {
		margin: 0 2px !important;
		padding: 6px 10px !important;
		font-size: 13px !important;
	}

	/* 底部按钮横向排列 */
	#maincontent .cbi-section-table + div,
	.cbi-page-actions {
		display: flex !important;
		flex-wrap: wrap !important;
		gap: 6px !important;
		padding: 8px 0 !important;
	}
	#maincontent .cbi-section-table + div input,
	#maincontent .cbi-section-table + div button,
	.cbi-page-actions input,
	.cbi-page-actions button {
		margin: 0 !important;
		padding: 8px 12px !important;
		font-size: 13px !important;
	}
	.cbi-section-table input[type="text"] { max-width: 100%; }
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