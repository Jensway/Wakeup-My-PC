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
	.cbi-section-table {
		width: 100% !important;
		max-width: 100% !important;
	}

	.cbi-section-table .tr.cbi-section-table-titles {
		display: none;
	}

	.cbi-section-table .tr {
		display: block;
		width: 100% !important;
		max-width: 100% !important;
		box-sizing: border-box;
		overflow: hidden;
		margin-bottom: 10px;
		padding: 10px;
		border: 1px solid #d9d9d9;
		border-radius: 8px;
		background: #fafafa;
	}

	.cbi-section-table .td {
		display: grid;
		grid-template-columns: 4rem minmax(0, 1fr);
		column-gap: 8px;
		align-items: center;
		width: 100% !important;
		max-width: 100% !important;
		box-sizing: border-box;
		padding: 0 !important;
		margin: 0 0 8px 0;
		border: 0 !important;
		text-align: left !important;
		white-space: normal !important;
	}

	.cbi-section-table .td::before {
		content: attr(data-title);
		display: block;
		margin: 0;
		font-size: 12px;
		line-height: 1.2;
		font-weight: 600;
		color: #666;
		white-space: nowrap;
	}

	.cbi-section-table .td[data-title=""]::before {
		display: none;
	}

	.cbi-section-table .td > * {
		min-width: 0;
		max-width: 100%;
	}

	.cbi-section-table .td.mobile-field-cell input[type="text"] {
		width: 100% !important;
		min-width: 0;
	}

	.cbi-section-table .woltool-mobile-action-row {
		display: flex;
		gap: 8px;
		width: 100%;
		max-width: 100%;
		margin-top: 2px;
	}

	.cbi-section-table .woltool-mobile-action-row .td.mobile-action-cell {
		display: block;
		flex: 1 1 0;
		width: auto !important;
		max-width: calc(50% - 4px) !important;
		margin: 0;
	}

	.cbi-section-table .woltool-mobile-action-row .td.mobile-action-cell::before {
		display: none;
	}

	.cbi-section-table .woltool-mobile-action-row .td.mobile-action-cell .cbi-button,
	.cbi-section-table .woltool-mobile-action-row .td.mobile-action-cell input[type="button"],
	.cbi-section-table .woltool-mobile-action-row .td.mobile-action-cell input[type="submit"],
	.cbi-section-table .woltool-mobile-action-row .td.mobile-action-cell a.cbi-button,
	.cbi-section-table .woltool-mobile-action-row .td.mobile-action-cell a {
		width: 100%;
		min-width: 0;
		box-sizing: border-box;
		text-align: center;
		white-space: nowrap;
	}

	.cbi-page-actions,
	.cbi-page-actions.woltool-mobile-actions {
		display: flex;
		flex-wrap: nowrap;
		gap: 6px;
		align-items: stretch;
	}

	.cbi-page-actions input,
	.cbi-page-actions .cbi-button,
	.cbi-page-actions a.cbi-button {
		flex: 1 1 0;
		min-width: 0;
		padding-left: 4px;
		padding-right: 4px;
		font-size: 12px;
		white-space: nowrap;
	}

	.cbi-section-create.woltool-merged {
		display: none !important;
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
			if (c >= cells.length - 2) {
				cells[c].classList.add("mobile-action-cell");
			} else {
				cells[c].classList.add("mobile-field-cell");
			}
		}
	}

	if (window.matchMedia("(max-width: 768px)").matches) {
		var pageActions = document.querySelector(".cbi-page-actions");
		var createBar = document.querySelector(".cbi-section-create");
		var addButton = document.querySelector(".cbi-section-create .cbi-button-add, .cbi-section-create input.cbi-button-add, .cbi-section-create .cbi-button");

		for (var i = 0; i < rows.length; i++) {
			var actionCells = rows[i].querySelectorAll(".td.mobile-action-cell");
			if (actionCells.length >= 2 && !rows[i].querySelector(".woltool-mobile-action-row")) {
				var actionRow = document.createElement("div");
				actionRow.className = "woltool-mobile-action-row";
				rows[i].insertBefore(actionRow, actionCells[0]);
				for (var a = 0; a < actionCells.length; a++) {
					actionRow.appendChild(actionCells[a]);
				}
			}
		}

		if (pageActions && addButton && !pageActions.contains(addButton)) {
			pageActions.insertBefore(addButton, pageActions.firstChild);
			pageActions.classList.add("woltool-mobile-actions");
			if (createBar) {
				createBar.classList.add("woltool-merged");
			}
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
