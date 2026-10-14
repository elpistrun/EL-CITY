--; ─────────────────────────────────────────────────────────────────────────────
--; Роль на следующий раунд (AdminPanel) — клиент.
--;
--; Открыть: F6 -> Next-Round Roles, или консоль zb_admin_roles.
--; Список ролей и права — на сервере (sv_nextrole.lua), сюда он приезжает
--; по сети: ничего не читаем из sh_-файлов, панель работает с тем, что сервер прислал.
--; ─────────────────────────────────────────────────────────────────────────────

local color_bg = Color(40, 40, 40)
local color_text = Color(225, 225, 225)
local color_dim = Color(170, 170, 170)

local roles = {}		--; { { id, name, context, color }, ... } — прислал сервер
local role_context = "team"	--; какой сейчас раунд с точки зрения сервера
local pending = {}		--; [steamid] = { name, role, admin }

local function get_role(id)
	for i, info in ipairs(roles) do
		if info.id == id then return info end
	end
end

local function role_label(id)
	local info = get_role(id)

	return info and info.name or (isstring(id) and id or "?")
end

local function role_color(id)
	local info = get_role(id)

	return info and info.color or color_dim
end

--; роль подходит текущему раунду? (чужую тоже можно поставить — она подождёт своего)
local function role_relevant(id)
	local info = get_role(id)
	if not info then return false end
	if not info.context or info.context == "any" then return true end

	return info.context == role_context
end

local function send(action, steamid64, role)
	net.Start("zb_nextrole_set")
	net.WriteString(action)
	net.WriteString(steamid64 or "")
	net.WriteString(role or "")
	net.SendToServer()
end

local function pending_label(steamid64)
	local entry = pending[steamid64]

	return entry and role_label(entry.role) or "-"
end

net.Receive("zb_nextrole_list", function()
	role_context = net.ReadString()
	roles = {}

	for i = 1, net.ReadUInt(8) do
		roles[#roles + 1] = {
			id = net.ReadString(),
			name = net.ReadString(),
			context = net.ReadString(),
			color = Color(net.ReadUInt(8), net.ReadUInt(8), net.ReadUInt(8)),
		}
	end

	if IsValid(zb.AdminRoleFrame) then zb.AdminRoleFrame:RebuildRoles() end
end)

net.Receive("zb_nextrole_sync", function()
	pending = {}

	for i = 1, net.ReadUInt(8) do
		local steamid64, name, role, admin = net.ReadString(), net.ReadString(), net.ReadString(), net.ReadString()

		pending[steamid64] = { name = name, role = role, admin = admin }
	end

	if IsValid(zb.AdminRoleFrame) then zb.AdminRoleFrame:Refresh() end
end)

local PANEL = {}

function PANEL:Init()
	self:SetSize(840, 480)
	self:SetTitle("AdminPanel :: роль на следующий раунд")

	if hg and hg.GetMainSkin then self:SetSkin(hg.GetMainSkin()) end

	self:MakePopup()
	self:Center()

	self.Selected = LocalPlayer():SteamID()

	self.info = vgui.Create("DLabel", self)
	self.info:Dock(TOP)
	self.info:SetTall(44)
	self.info:DockMargin(8, 8, 8, 0)
	self.info:SetTextColor(color_text)
	self.info:SetWrap(true)
	self.info:SetText("")

	--; панели вокруг: TOP/BOTTOM/RIGHT доким раньше списка, иначе FILL съест их место
	self.roles = vgui.Create("DScrollPanel", self)
	self.roles:Dock(RIGHT)
	self.roles:SetWide(250)
	self.roles:DockMargin(4, 8, 8, 8)

	local bottom = vgui.Create("DPanel", self)
	bottom:Dock(BOTTOM)
	bottom:SetTall(36)
	bottom:DockMargin(8, 0, 8, 8)
	bottom.Paint = function() end

	local clear = vgui.Create("DButton", bottom)
	clear:Dock(LEFT)
	clear:SetWide(210)
	clear:SetText("Сбросить заявку")
	clear.DoClick = function()
		send("clear", self.Selected, "")
		surface.PlaySound("buttons/button19.wav")
	end

	local refresh = vgui.Create("DButton", bottom)
	refresh:Dock(RIGHT)
	refresh:SetWide(150)
	refresh:SetText("Обновить")
	refresh.DoClick = function()
		send("req", "", "")
	end

	self.list = vgui.Create("DListView", self)
	self.list:Dock(FILL)
	self.list:DockMargin(8, 8, 4, 8)
	self.list:AddColumn("Игрок")
	self.list:AddColumn("SteamID")
	self.list:AddColumn("Следующий раунд")
	self.list:AddColumn("Поставил")
	self.list:SetMultiSelect(false)
	--; OnRowSelected отдаёт НОМЕР строки, а не саму строку: панель достаём через GetLine
	self.list.OnRowSelected = function(list, index)
		local line = list:GetLine(index)
		if not line then return end

		self.Selected = line.SteamID

		self:UpdateInfo()
	end

	self:RebuildRoles()
	self:Refresh()
end

--; кнопки ролей строятся из того, что прислал сервер
function PANEL:RebuildRoles()
	local holder = self.roles
	if not IsValid(holder) then return end

	local scroll = holder.VBar and holder.VBar:GetScroll() or 0

	holder:Clear()

	if #roles == 0 then
		local wait = vgui.Create("DLabel", holder)
		wait:Dock(TOP)
		wait:SetTall(46)
		wait:SetWrap(true)
		wait:SetTextColor(color_dim)
		wait:SetText("Список ролей ещё не пришёл от сервера — нажми «Обновить».")

		return
	end

	for i, role_info in ipairs(roles) do
		local btn = vgui.Create("DButton", holder)
		btn:Dock(TOP)
		btn:DockMargin(0, 0, 0, 6)
		btn:SetTall(40)
		btn:SetText(role_info.name)

		btn.DoClick = function()
			send("set", self.Selected, role_info.id)
			surface.PlaySound("buttons/button14.wav")
		end

		btn.Paint = function(sel, w, h)
			local col = role_info.color or color_bg

			surface.SetDrawColor(col.r, col.g, col.b, sel:IsHovered() and 255 or 215)
			surface.DrawRect(0, 0, w, h)

			--; роль не для текущего режима: притемнена, но поставить её всё равно можно
			if not role_relevant(role_info.id) then
				surface.SetDrawColor(0, 0, 0, 110)
				surface.DrawRect(0, 0, w, h)
			end

			surface.SetDrawColor(0, 0, 0, 90)
			surface.DrawOutlinedRect(0, 0, w, h)
		end
	end

	if holder.VBar then holder.VBar:SetScroll(scroll) end
end

function PANEL:UpdateInfo()
	local lply = LocalPlayer()
	local target = player.GetBySteamID(self.Selected)

	local who
	if IsValid(target) then
		who = target:Nick() .. (target == lply and " (ты)" or "")
	elseif self.Selected == lply:SteamID() then
		who = lply:Nick() .. " (ты)"
	else
		who = tostring(self.Selected)
	end

	local entry = pending[self.Selected]
	local now = entry and ("сейчас: " .. role_label(entry.role) .. " (поставил " .. tostring(entry.admin or "?") .. ")") or "сейчас заявки нет"

	self.info:SetText("Цель: " .. who .. "   |   " .. now .. "\nРежим: " .. (role_context == "homicide" and "homicide" or "командный") .. "   |   заявка сработает один раз, в следующем раунде.")
end

function PANEL:Refresh()
	local list = self.list
	if not IsValid(list) then return end

	list:Clear()

	local lply = LocalPlayer()
	local seen = {}

	local function add_row(ply, steamid64, name)
		local entry = pending[steamid64]
		local row = list:AddLine(name, steamid64, pending_label(steamid64), entry and tostring(entry.admin or "?") or "-")

		row.SteamID = steamid64
		row.Player = IsValid(ply) and ply or nil

		seen[steamid64] = true

		return row
	end

	add_row(lply, lply:SteamID(), lply:Nick() .. "  (я)")

	local others = {}
	for i, ply in player.Iterator() do
		if ply != lply then others[#others + 1] = ply end
	end

	table.sort(others, function(a, b) return a:Nick() < b:Nick() end)

	for i, ply in ipairs(others) do
		add_row(ply, ply:SteamID(), ply:Nick())
	end

	--; заявки тех, кого уже нет в игре — чтобы их можно было снять
	for steamid64, entry in pairs(pending) do
		if not seen[steamid64] then
			add_row(nil, steamid64, tostring(entry.name or "?") .. "  (не в игре)")
		end
	end

	local lines = list:GetLines()
	local select_row = 1

	for i, row in ipairs(lines) do
		if row.SteamID == self.Selected then
			select_row = i
			break
		end
	end

	--; у DListView нет SelectRow: выбирается сама строка (панель), а не её номер
	if lines[select_row] then list:SelectItem(lines[select_row]) end

	self:UpdateInfo()
end

function PANEL:OnRemove()
	if zb.AdminRoleFrame == self then zb.AdminRoleFrame = nil end
end

vgui.Register("ZBAdminRolePanel", PANEL, "DFrame")

--; админ-проверка мягче обычной: хост listen-сервера тоже должен попадать
local function is_admin(ply)
	return ply:IsAdmin() or ply:IsSuperAdmin() or ply:IsListenServerHost()
end

--; одна точка входа: и консоль, и кнопка в F6-панели (cl_modeselect_menu.lua)
function zb.OpenNextRolePanel()
	local lply = LocalPlayer()

	if not is_admin(lply) then
		lply:ChatPrint("Роли на следующий раунд: только для админов.")
		return
	end

	local frame = zb.AdminRoleFrame
	if not IsValid(frame) then
		frame = vgui.Create("ZBAdminRolePanel")
		zb.AdminRoleFrame = frame
	end

	frame:Refresh()
	frame:MakePopup()
	send("req", "", "")
end

concommand.Add("zb_admin_roles", function()
	zb.OpenNextRolePanel()
end)
