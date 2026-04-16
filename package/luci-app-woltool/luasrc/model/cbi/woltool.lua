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

/* 手机端：表格保持行内布局，隐藏表头，压缩列宽 */
@media (max-width: 768px) {
	.cbi-section-table thead { display: none; }
	.cbi-section-table tbody tr { display: block !important; white-space: nowrap; }
	.cbi-section-table tbody tr td,
	.cbi-section-table tbody tr .td { display: inline-block !important; white-space: nowrap; vertical-align: middle; }

	/* 名称列：固定宽度60px，后跟唤醒和删除按钮 */
	.cbi-section-table tbody tr td:nth-child(1),
	.cbi-section-table tbody tr .td:nth-child(1) { width: 60px !important; min-width: 60px !important; }
	/* MAC列：固定宽度90px */
	.cbi-section-table tbody tr td:nth-child(2),
	.cbi-section-table tbody tr .td:nth-child(2) { width: 90px !important; min-width: 90px !important; }
	/* 接口列：固定宽度70px */
	.cbi-section-table tbody tr td:nth-child(3),
	.cbi-section-table tbody tr .td:nth-child(3) { width: 70px !important; min-width: 70px !important; }
	/* 操作列和删除列：紧凑 */
	.cbi-section-table tbody tr td:nth-child(4),
	.cbi-section-table tbody tr td:nth-child(5),
	.cbi-section-table tbody tr .td:nth-child(4),
	.cbi-section-table tbody tr .td:nth-child(5) { width: auto !important; }

	/* 表格可横向滚动 */
	.cbi-section-table { display: block !important; overflow-x: auto !important; white-space: nowrap !important; }

	/* 输入框全宽显示 */
	.cbi-section-table input[type="text"] { width: 100% !important; min-width: unset !important; }

	/* 按钮紧凑 */
	.cbi-section-table input[type="button"],
	.cbi-section-table a { margin: 0 !important; padding: 4px 8px !important; font-size: 12px !important; white-space: nowrap; }

	/* 底部按钮强制一行 */
	.cbi-page-actions { display: flex !important; flex-wrap: nowrap !important; gap: 4px !important; }
	.cbi-page-actions input { flex: 1 !important; min-width: 0 !important; padding: 6px 4px !important; font-size: 12px !important; }
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
		alert('\u2716 网络请求失���');
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