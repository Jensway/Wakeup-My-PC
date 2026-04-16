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
	.cbi-section-table.woltool-mobile-hidden {
		display: none !important;
	}

	.woltool-mobile-list {
		display: block;
		width: 100% !important;
		min-width: 0 !important;
		max-width: 100% !important;
		box-sizing: border-box;
	}

	.woltool-mobile-card {
		display: block;
		width: 100% !important;
		min-width: 0 !important;
		max-width: 100% !important;
		box-sizing: border-box;
		overflow: hidden;
		margin-bottom: 10px;
		padding: 10px;
		border: 1px solid #d9d9d9;
		border-radius: 8px;
		background: #fafafa;
	}

	.woltool-mobile-field {
		display: grid;
		grid-template-columns: 4rem minmax(0, 1fr);
		column-gap: 8px;
		align-items: center;
		width: 100%;
		max-width: 100%;
		margin: 0 0 8px 0;
	}

	.woltool-mobile-label {
		margin: 0;
		font-size: 12px;
		line-height: 1.2;
		font-weight: 600;
		color: #666;
		white-space: nowrap;
	}

	.woltool-mobile-value,
	.woltool-mobile-value > * {
		min-width: 0;
		max-width: 100%;
	}

	.woltool-mobile-value .cbi-value-field,
	.woltool-mobile-value input[type="text"],
	.woltool-mobile-value select {
		width: 100% !important;
		max-width: 100% !important;
		min-width: 0 !important;
		box-sizing: border-box;
	}

	.woltool-mobile-field input[type="text"] {
		width: 100% !important;
		min-width: 0;
		box-sizing: border-box;
	}

	.woltool-mobile-action-row {
		display: flex;
		gap: 8px;
		width: 100%;
		max-width: 100%;
		margin-top: 2px;
	}

	.woltool-mobile-action {
		flex: 1 1 0;
		min-width: 0;
		max-width: calc(50% - 4px);
	}

	.woltool-mobile-action .cbi-button,
	.woltool-mobile-action input[type="button"],
	.woltool-mobile-action input[type="submit"],
	.woltool-mobile-action a.cbi-button,
	.woltool-mobile-action a {
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
	function ensureFullWidth(node) {
		if (!node) {
			return;
		}
		node.style.width = "100%";
		node.style.maxWidth = "100%";
		node.style.minWidth = "0";
		node.style.boxSizing = "border-box";
	}

	function moveChildren(source, target) {
		while (source.firstChild) {
			target.appendChild(source.firstChild);
		}
	}

	var titles = [];
	var table = document.querySelector(".cbi-section-table");
	var headers = document.querySelectorAll(".cbi-section-table .tr.cbi-section-table-titles .th");
	for (var i = 0; i < headers.length; i++) {
		titles.push(headers[i].textContent.replace(/\s+/g, " ").trim());
	}

	var rows = document.querySelectorAll(".cbi-section-table .tr:not(.cbi-section-table-titles)");

	if (window.matchMedia("(max-width: 768px)").matches) {
		var pageActions = document.querySelector(".cbi-page-actions");
		var createBar = document.querySelector(".cbi-section-create");
		var addButton = document.querySelector(".cbi-section-create .cbi-button-add, .cbi-section-create input.cbi-button-add, .cbi-section-create .cbi-button");

		if (table) {
			ensureFullWidth(table);

			var parent = table.parentElement;
			for (var depth = 0; parent && depth < 4; depth++) {
				ensureFullWidth(parent);
				parent.style.overflowX = "hidden";
				parent = parent.parentElement;
			}

			if (!table.nextElementSibling || !table.nextElementSibling.classList || !table.nextElementSibling.classList.contains("woltool-mobile-list")) {
				var mobileList = document.createElement("div");
				mobileList.className = "woltool-mobile-list";

				for (var r = 0; r < rows.length; r++) {
					var cells = rows[r].querySelectorAll(".td");
					if (!cells.length) {
						continue;
					}

					var card = document.createElement("div");
					card.className = "woltool-mobile-card";

					for (var c = 0; c < cells.length; c++) {
						if (c >= cells.length - 2) {
							continue;
						}

						var field = document.createElement("div");
						field.className = "woltool-mobile-field";

						var label = document.createElement("div");
						label.className = "woltool-mobile-label";
						label.textContent = titles[c] || "";

						var value = document.createElement("div");
						value.className = "woltool-mobile-value";
						moveChildren(cells[c], value);

						field.appendChild(label);
						field.appendChild(value);
						card.appendChild(field);
					}

					if (cells.length >= 2) {
						var actionRow = document.createElement("div");
						actionRow.className = "woltool-mobile-action-row";

						for (var a = cells.length - 2; a < cells.length; a++) {
							var action = document.createElement("div");
							action.className = "woltool-mobile-action";
							moveChildren(cells[a], action);
							actionRow.appendChild(action);
						}

						card.appendChild(actionRow);
					}

					mobileList.appendChild(card);
				}

				table.parentNode.insertBefore(mobileList, table.nextSibling);
			}

			table.classList.add("woltool-mobile-hidden");
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
