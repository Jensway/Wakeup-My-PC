local util = require "luci.util"
local disp = require "luci.dispatcher"

local wake_url = disp.build_url("admin", "services", "woltool", "wake")

local m = Map("wolhost", translate("唤醒电脑"),
	translate("点击主机右侧的「唤醒」按钮即可发送唤醒包。可在下方添加或删除主机。") ..
	[=[
<style>
.cbi-section-table {
	width: 100%;
}

.cbi-section-table input[type="text"] {
	box-sizing: border-box;
	width: 100%;
}

@media (max-width: 768px) {
	.cbi-section-table .tr.cbi-section-table-titles {
		display: none;
	}

	.cbi-section-table .tr {
		display: block;
		margin-bottom: 14px;
		padding: 12px;
		border: 1px solid #d9d9d9;
		border-radius: 8px;
		background: #fafafa;
	}

	.cbi-section-table .td {
		display: block;
		width: 100% !important;
		padding: 0 !important;
		margin: 0 0 10px 0;
		border: 0 !important;
		text-align: left !important;
		white-space: normal !important;
	}

	.cbi-section-table .td:last-child {
		margin-bottom: 0;
	}

	.cbi-section-table .td::before {
		content: attr(data-title);
		display: block;
		margin-bottom: 4px;
		font-size: 12px;
		line-height: 1.4;
		font-weight: 600;
		color: #666;
	}

	.cbi-section-table .td[data-title=""]::before {
		display: none;
	}

	.cbi-section-table input[type="text"] {
		width: 100% !important;
		min-width: 0;
	}

	.cbi-section-table .cbi-button,
	.cbi-section-table input[type="button"],
	.cbi-section-table input[type="submit"],
	.cbi-section-table a.cbi-button {
		width: 100%;
		box-sizing: border-box;
		text-align: center;
		white-space: nowrap;
	}

	.cbi-section-table .td:nth-last-child(2),
	.cbi-section-table .td:last-child {
		margin-bottom: 8px;
	}

	.cbi-page-actions {
		display: flex;
		flex-wrap: wrap;
		gap: 8px;
	}

	.cbi-page-actions input,
	.cbi-page-actions .cbi-button {
		flex: 1 1 100%;
		min-width: 0;
	}
}
</style>
<script>
document.addEventListener("DOMContentLoaded", function() {
	var titles = [];
	var headers = document.querySelectorAll(".cbi-section-table .tr.cbi-section-table-titles .th");
	for (var i = 0; i < headers.length; i++) {
		titles.push(headers[i].textContent.replace(/\s+/g, " ").trim());
	}

	var rows = document.querySelectorAll(".cbi-section-table .tr:not(.cbi-section-table-titles)");
	for (var r = 0; r < rows.length; r++) {
		var cells = rows[r].querySelectorAll(".td");
		for (var c = 0; c < cells.length; c++) {
			cells[c].setAttribute("data-title", titles[c] || "");
		}
	}
});
</script>
]=] ..
	string.format([=[
<script>
var wolUrl = "%s";
function wolWake(btn) {
	var name = btn.getAttribute("data-name");
	var token = document.querySelector('input[name="token"]');
	var body = "name=" + encodeURIComponent(name);
	var orig = btn.value;
	var xhr = new XMLHttpRequest();
	if (token) body += "&token=" + encodeURIComponent(token.value);
	btn.disabled = true;
	btn.value = "\u53d1\u9001\u4e2d...";
	xhr.open("POST", wolUrl, true);
	xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
	xhr.onload = function() {
		btn.disabled = false;
		btn.value = orig;
		try {
			var result = JSON.parse(xhr.responseText);
			alert(result.success ? "\u2714 " + result.message : "\u2716 " + result.message);
		} catch (e) {
			alert(xhr.status === 200 ? "\u2714 \u5524\u9192\u5305\u5df2\u53d1\u9001" : "\u2716 \u8bf7\u6c42\u5931\u8d25");
		}
	};
	xhr.onerror = function() {
		btn.disabled = false;
		btn.value = orig;
		alert("\u2716 \u7f51\u7edc\u8bf7\u6c42\u5931\u8d25");
	};
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
