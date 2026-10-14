--made by mrrp :3

local maxLength = GetConVar("zchat_maxmessagelength")

local NoDrop = CreateClientConVar("zchat_dropcharacters", 1, true, false, "Play the character dropping animation when erasing text", 0, 1)
local ShowTextBoxInactive = CreateClientConVar("zchat_showtextboxinactive", 1, true, false, "Showing your text in textbox while chat is turned off", 0, 1)

//\\ положение и размер окна чата сохраняются между заходами (-1 — значения по умолчанию)
local chatSaveX = CreateClientConVar("zchat_posx", -1, true, false, "Сохранённая позиция окна чата по X")
local chatSaveY = CreateClientConVar("zchat_posy", -1, true, false, "Сохранённая позиция окна чата по Y")
local chatSaveW = CreateClientConVar("zchat_width", -1, true, false, "Сохранённая ширина окна чата")
local chatSaveH = CreateClientConVar("zchat_height", -1, true, false, "Сохранённая высота окна чата")

local function CallbackBind(self, callback)
	return function(_, ...)
		return callback(self, ...)
	end
end

local function PaintMarkupOverride(text, font, x, y, color, alignX, alignY, alpha)
	alpha = alpha or 255

	-- background for easier reading
	surface.SetTextPos(x + 1, y + 1)
	surface.SetTextColor(0, 0, 0, alpha)
	surface.SetFont(font)
	surface.DrawText(text)

	surface.SetTextPos(x, y)
	surface.SetTextColor(color.r, color.g, color.b, alpha)
	surface.SetFont(font)
	surface.DrawText(text)
end

local PANEL = {}

function PANEL:Init()
	self.text = ""
	self.alpha = 0
	self.fadeDelay = 15
	self.fadeDuration = 5
	self.yAnimDuration = 1

	self.yAnim = 5
end

function PANEL:SetMarkup(text)
	self.text = text

	self.markup = hg.markup.Parse(self.text, self:GetWide())
	self.markup.onDrawText = PaintMarkupOverride

	self:SetTall(self.markup:GetHeight())

	timer.Simple(self.fadeDelay, function()
		if (!IsValid(self)) then
			return
		end

		self:CreateAnimation(self.fadeDuration, {
			index = 3,
			target = {alpha = 0}
		})
	end)

	self:CreateAnimation(self.yAnimDuration, {
		index = 4,
		target = {yAnim = 0},
		easing = "outQuint"
	})

	self:CreateAnimation(0.5, {
		index = 3,
		target = {alpha = 255},
	})
end

function PANEL:PerformLayout(width, height)
	self.markup = hg.markup.Parse(self.text, width)
	self.markup.onDrawText = PaintMarkupOverride

	self:SetTall(self.markup:GetHeight())
end

function PANEL:Paint(width, height)
	local newAlpha

	if (hg.chat:GetActive()) then
		newAlpha = math.max(hg.chat.alpha, self.alpha)
	else
		newAlpha = self.alpha - (255 - hg.chat.realAlpha)
	end

	DisableClipping(true)
		local chatboxX, chatboxY = hg.chat:GetPos()
		local wide, tall = hg.chat:GetSize()

		render.SetScissorRect(chatboxX, chatboxY, chatboxX + wide, chatboxY + tall, true)
			self.markup:draw(0, self.yAnim, nil, nil, newAlpha)
		render.SetScissorRect(0, 0, 0, 0, false)
	DisableClipping(false)
end

vgui.Register("zChatMessage", PANEL, "Panel")

PANEL = {}

DEFINE_BASECLASS("DTextEntry")

function PANEL:Init()
	self:SetFont("zChatFont")
	self:SetUpdateOnType(true)
	self:SetHistoryEnabled(true)

	self.History = hg.chat.messageHistory
	self.droppedCharacters = {}

	self.prevText = ""

	self:SetTextColor(color_white)

	self:SetPaintBackground(false)

	self.m_bLoseFocusOnClickAway = false
end

function PANEL:AllowInput(newCharacter)
	local text = self:GetText()
	local maxLen = maxLength:GetInt()

	-- we can't check for the proper length using utf-8 since AllowInput is called for single bytes instead of full characters
	if (string.len(text .. newCharacter) > maxLen) then
		surface.PlaySound("common/talk.wav")
		return true
	end
end

function PANEL:Think()
	local text = self:GetText()
	local maxLen = maxLength:GetInt()

	if (text:utf8len() > maxLen) then
		local newText = text:utf8sub(0, maxLen)

		self:SetText(newText)
		self:SetCaretPos(newText:utf8len())
	end
end

local gradient_l = Material("vgui/gradient-l")

function PANEL:Paint(w, h)
	surface.SetDrawColor(31, 43, 31, 100)
	surface.DrawRect(0, 0, w, h)

	-- surface.SetDrawColor(137, 137, 137, 150)
	-- surface.SetMaterial(gradient_l)
	-- surface.DrawTexturedRect(0, 0, w * 0.9, h)

	for k, v in ipairs(self.droppedCharacters) do
		local text = v.text

		v.velocityY = v.velocityY + (5 * FrameTime())
		v.y = v.y + v.velocityY

		v.x = v.x + v.velocityX

		v.alpha = v.alpha - FrameTime() * 750

		DisableClipping(true)
			surface.SetTextColor(150, 150, 150, v.alpha)
			surface.SetTextPos(v.x, v.y)
			surface.SetFont("zChatFont")
			surface.DrawText(text)
		DisableClipping(false)

		if v.alpha <= 0 then
			table.remove(self.droppedCharacters, k)
		end
	end

	if ShowTextBoxInactive:GetBool() and !hg.chat:GetActive() and self.prevText != "" then
		DisableClipping(true)
		surface.SetAlphaMultiplier(1)
			surface.SetTextColor(150, 150, 150, 55)
			surface.SetTextPos(0, 0)
			surface.SetFont("zChatFont")
			surface.DrawText(self.prevText)
		surface.SetAlphaMultiplier(0)
		DisableClipping(false)
	end

	BaseClass.Paint(self, w, h)
end

function PANEL:OnValueChange(text)
	local prevText = self.prevText

	if NoDrop:GetBool() then
		local len1, len2 = string.utf8len(prevText), string.utf8len(text)

		if len1 > len2 then
			local droppedText = string.utf8sub(prevText, self:GetCaretPos() + 1, self:GetCaretPos() + (len1 - len2))

			local droppedChars = string.Explode(utf8.charpattern, droppedText)
			for k, v in ipairs(droppedChars) do
				local data = {}
				data.text = v

				surface.SetFont("zChatFont")
				-- local tw1 = surface.GetTextSize(text)
				local tw2 = surface.GetTextSize(v)

				data.x = tw2 * (self:GetCaretPos())

				-- local panelWide = self:GetWide()

				-- if data.x > panelWide then
				-- 	data.x = data.x - (data.x - panelWide)
				-- end

				data.y = 8

				data.velocityX = math.Rand(-0.1, 0.1)
				data.velocityY = -1

				data.alpha = 255

				table.insert(self.droppedCharacters, data)
			end
		end
	end

	self.prevText = text
end

vgui.Register("zChatboxEntry", PANEL, "DTextEntry")

--\ Заголовок окна чата: рисуем и таскаем через глобальные функции, чтобы правки
--\ применялись сразу после lua_refresh, без пересоздания окна чата.
--\ hg.ChatRev поднимаем, когда меняется сама структура заголовка, иначе хватает одних правок Paint.
hg.ChatRev = 8

local titleShadow = Color(0, 0, 0, 180)

function hg.ChatTitlebarPaint(bar, w, h)
	--\ Своей подложки у заголовка нет: сквозь него виден фон самого окна чата,
	--\ поэтому цвет заголовка совпадает с цветом области сообщений. Никаких
	--\ подчёркиваний и рамок — полоска между заголовком и чатом убрана.

	local name = GetHostName()
	if not name or name == "" then
		name = "EL-City"
	end

	--\ не влезает в полосу — обрезаем с многоточием
	surface.SetFont("zChatTitle")

	local max_w = w - 28
	if surface.GetTextSize(name) > max_w then
		local len = string.utf8len(name)

		while len > 1 and surface.GetTextSize(string.utf8sub(name, 1, len) .. "…") > max_w do
			len = len - 1
		end

		name = string.utf8sub(name, 1, len) .. "…"
	end

	--\\ тень, как у сообщений: на размытом фоне белый текст иначе теряется
	draw.SimpleText(name, "zChatTitle", 9, h / 2 + 1, titleShadow, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	draw.SimpleText(name, "zChatTitle", 8, h / 2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

	--\ ручки перетаскивания (три полоски справа) больше нет: заголовок перетаскивается
	--\ за любое место, а полоски только мусорили в углу
	--
	-- НОВОЕ: убрать три полоски в углу заголовка — здесь ничего не рисуем.
end

function hg.ChatTitlebarPressed(bar, mousecode)
	if mousecode ~= MOUSE_LEFT then return end

	local chat = bar:GetParent()
	if not IsValid(chat) then return end

	bar.dragging = true
	bar.grab_x = gui.MouseX() - chat:GetX()
	bar.grab_y = gui.MouseY() - chat:GetY()

	bar:MouseCapture(true)
end

function hg.ChatTitlebarReleased(bar)
	bar.dragging = false

	bar:MouseCapture(false)

	--\\ запоминаем, куда игрок поставил окно
	local chat = bar:GetParent()

	--\\ подсветка краёв больше не нужна
	if IsValid(chat) then
		chat.snap_x, chat.snap_y = nil, nil
	end

	hg.ChatSaveLayout(chat)
end

function hg.ChatTitlebarThink(bar)
	if not bar.dragging then return end

	local chat = bar:GetParent()
	if not IsValid(chat) then return end

	local wide, tall = chat:GetWide(), chat:GetTall()
	local max_x, max_y = math.max(ScrW() - wide, 0), math.max(ScrH() - tall, 0)
	local dist = ScreenScale(8)

	local x = math.Clamp(gui.MouseX() - bar.grab_x, 0, max_x)
	local y = math.Clamp(gui.MouseY() - bar.grab_y, 0, max_y)

	--\\ притягиваем к краям экрана и к позиции по умолчанию
	x = hg.ChatSnapTo(x, {0, max_x, ScrW() * 0.02}, dist)
	y = hg.ChatSnapTo(y, {0, max_y, ScrH() * 0.67}, dist)

	chat.snap_x = (x == 0) and 1 or (x == max_x) and 2 or nil
	chat.snap_y = (y == 0) and 1 or (y == max_y) and 2 or nil

	chat:SetPos(x, y)
end

--\\ магнит к краям экрана: если значение подъехало ближе чем на dist, притягиваем к цели
function hg.ChatSnapTo(value, targets, dist)
	local best, best_dist = value, dist

	for _, target in ipairs(targets) do
		local delta = math.abs(value - target)

		if delta <= best_dist then
			best, best_dist = target, delta
		end
	end

	return best
end

--\ Раскладываем окно чата по сохранённым позиции и размеру, иначе ставим значения по умолчанию
function hg.ChatApplyLayout(panel)
	if not IsValid(panel) then return end

	local min_w, min_h = ScreenScale(180), ScreenScale(90)

	local wide, tall = chatSaveW:GetFloat(), chatSaveH:GetFloat()

	wide = (wide > 0) and math.max(wide, min_w) or ScrW() * 0.3
	tall = (tall > 0) and math.max(tall, min_h) or ScrH() * 0.2

	wide, tall = math.min(wide, ScrW()), math.min(tall, ScrH())

	local x, y = chatSaveX:GetFloat(), chatSaveY:GetFloat()

	if x < 0 then x = ScrW() * 0.02 end
	if y < 0 then y = ScrH() * 0.67 end

	panel:SetSize(wide, tall)
	panel:SetPos(math.Clamp(x, 0, math.max(ScrW() - wide, 0)), math.Clamp(y, 0, math.max(ScrH() - tall, 0)))
end

function hg.ChatSaveLayout(panel)
	if not IsValid(panel) then return end

	chatSaveX:SetFloat(math.Round(panel:GetX()))
	chatSaveY:SetFloat(math.Round(panel:GetY()))
	chatSaveW:SetFloat(math.Round(panel:GetWide()))
	chatSaveH:SetFloat(math.Round(panel:GetTall()))
end

--\ Уголок в правом нижнем углу окна: тянем — меняем ширину и высоту
function hg.ChatGripperPaint(grip, w, h)
	local hovered = grip:IsHovered() or grip.dragging

	surface.SetDrawColor(255, 255, 255, hovered and 220 or 90)

	for i = 1, 3 do
		local gap = 3 * i

		surface.DrawRect(w - gap, h - 2, 2, 2)
		surface.DrawRect(w - 2, h - gap, 2, 2)
	end
end

function hg.ChatGripperPressed(grip, mousecode)
	if mousecode ~= MOUSE_LEFT then return end

	grip.dragging = true

	grip:MouseCapture(true)
end

function hg.ChatGripperReleased(grip)
	grip.dragging = false

	grip:MouseCapture(false)

	--\ запоминаем новый размер
	local chat = grip:GetParent()

	--\\ подсветка краёв больше не нужна
	if IsValid(chat) then
		chat.snap_x, chat.snap_y = nil, nil
	end

	hg.ChatSaveLayout(chat)
end

function hg.ChatGripperThink(grip)
	local chat = grip:GetParent()
	if not IsValid(chat) then return end

	--\ держим уголок в правом нижнем углу окна при любом изменении размера
	local want_x, want_y = chat:GetWide() - grip:GetWide(), chat:GetTall() - grip:GetTall()

	if grip:GetX() ~= want_x or grip:GetY() ~= want_y then
		grip:SetPos(want_x, want_y)
	end

	if not grip.dragging then return end

	local min_w, min_h = ScreenScale(180), ScreenScale(90)

	local dist = ScreenScale(8)

	local max_w = math.max(ScrW() - chat:GetX(), min_w)
	local max_h = math.max(ScrH() - chat:GetY(), min_h)

	local wide = math.Clamp(gui.MouseX() - chat:GetX(), min_w, max_w)
	local tall = math.Clamp(gui.MouseY() - chat:GetY(), min_h, max_h)

	--\\ притягиваем правый и нижний край к краям экрана и к размеру по умолчанию
	wide = hg.ChatSnapTo(wide, {max_w, ScrW() * 0.3}, dist)
	tall = hg.ChatSnapTo(tall, {max_h, ScrH() * 0.2}, dist)

	chat.snap_x = (wide == max_w) and 2 or nil
	chat.snap_y = (tall == max_h) and 2 or nil

	chat:SetSize(wide, tall)
end

PANEL = {}

AccessorFunc(PANEL, "bActive", "Active", FORCE_BOOL)
AccessorFunc(PANEL, "realAlpha", "RealAlpha", FORCE_BOOL)

function PANEL:Init()
	hg.chat = self

	self.entries = {}
	self.messageHistory = {}

	self.alpha = 255
	self.realAlpha = 255

	//\\ размер и позицию берём из сохранённых значений, иначе ставим по умолчанию
	hg.ChatApplyLayout(self)

	//\ Заголовок окна чата: за него чат можно таскать мышью
	local titlebar = self:Add("DPanel")
	self.titlebar = titlebar

	//\ высоту подгоняем под фактическую высоту строки, чтобы крупный текст влезал
	local titlebar_h = ScreenScaleH(20)

	surface.SetFont("zChatTitle")
	local _, text_h = surface.GetTextSize("Ag")
	if text_h and text_h > 0 then
		titlebar_h = math.max(titlebar_h, text_h + 12)
	end

	//\ ревизия кода: по ней окно чата понимает, что создано старой версией и его надо пересоздать
	titlebar.hg_rev = hg.ChatRev

	titlebar:SetZPos(2)
	titlebar:Dock(TOP)
	titlebar:SetTall(titlebar_h)
	titlebar:DockMargin(0, 0, 0, 2)
	titlebar:SetMouseInputEnabled(true)
	titlebar:SetCursor("sizeall")

	//\ рисуем и таскаем через глобальные функции: тогда правки внешнего вида применяются
	//\ сразу после lua_refresh, без пересоздания окна чата
	titlebar.Paint = function(bar, w, h)
		if hg.ChatTitlebarPaint then hg.ChatTitlebarPaint(bar, w, h) end
	end

	titlebar.OnMousePressed = function(bar, mousecode)
		if hg.ChatTitlebarPressed then hg.ChatTitlebarPressed(bar, mousecode) end
	end

	titlebar.OnMouseReleased = function(bar)
		if hg.ChatTitlebarReleased then hg.ChatTitlebarReleased(bar) end
	end

	titlebar.Think = function(bar)
		if hg.ChatTitlebarThink then hg.ChatTitlebarThink(bar) end
	end

	local entryPanel = self:Add("Panel")
	entryPanel:SetZPos(1)
	entryPanel:Dock(BOTTOM)
	entryPanel:DockMargin(4, 0, 4, 4)

	self.entry = entryPanel:Add("zChatboxEntry")
	self.entry:Dock(FILL)
	-- self.entry.OnValueChange = ix.util.Bind(self, self.OnTextChanged)
	-- self.entry.OnKeyCodeTyped = ix.util.Bind(self, self.OnKeyCodeTyped)
	self.entry.OnEnter = CallbackBind(self, self.OnMessageSent)

	self.history = self:Add("DScrollPanel")
	self.history:Dock(FILL)
	self.history:DockMargin(4, 2, 4, 4)

	//\\ уголок в правом нижнем углу: за него окно тянется по ширине и высоте
	local grip = self:Add("Panel")
	self.gripper = grip

	grip:SetSize(ScreenScale(11), ScreenScale(11))
	grip:SetZPos(3)
	grip:SetMouseInputEnabled(true)
	grip:SetCursor("sizenesw")

	grip.Paint = function(g, w, h)
		if hg.ChatGripperPaint then hg.ChatGripperPaint(g, w, h) end
	--
	-- НОВОЕ: отключить отрисовку уголка-гриппера, чтобы убрать полоски в правом нижнем углу чата
	-- (закомментировано, чтобы не удалять код совсем; если нужно — раскомментировать и удалить Paint-функцию целиком).
	end

	grip.OnMousePressed = function(g, mousecode)
		if hg.ChatGripperPressed then hg.ChatGripperPressed(g, mousecode) end
	end

	grip.OnMouseReleased = function(g)
		if hg.ChatGripperReleased then hg.ChatGripperReleased(g) end
	end

	grip.Think = function(g)
		if hg.ChatGripperThink then hg.ChatGripperThink(g) end
	end

	self:SetActive(false)
end

local gradient_d = Material("vgui/gradient-d")
local gray = Color(255, 255, 255, 100)
local black = Color(0, 0, 0, 200)

function PANEL:Paint(w, h)
	hg.DrawBlur(self, 5)

	surface.SetDrawColor(67, 247, 67, 100 + math.sin(CurTime()) * 30)
	surface.SetMaterial(gradient_d)
	surface.DrawTexturedRect(0, h * 0.5, w, h * 0.5)

	// потише, чем раньше: иначе размытие за чатом просто не видно
	surface.SetDrawColor(0, 0, 0, 130)
	surface.DrawRect(0, 0, w, h)

	surface.SetAlphaMultiplier(1)
		self.history:PaintManual()
		local bar = self.history:GetVBar()
		bar:SetAlpha(self:GetAlpha())
	surface.SetAlphaMultiplier(self:GetAlpha() / 255)

	DisableClipping(true)
		draw.SimpleText("Зажмите ALT и нажмите ENTER для шёпота", "zChatFontSmall", 5, h * 1.01 + 1, black)
		draw.SimpleText("Зажмите ALT и нажмите ENTER для шёпота", "zChatFontSmall", 4, h * 1.01, gray)

		if LocalPlayer().organism and LocalPlayer().organism.otrub  then
			draw.SimpleText("Ваши сообщения сейчас не видны никому.", "zChatFontSmall", w + 1, h * 1.01 + 1, black, TEXT_ALIGN_RIGHT)
			draw.SimpleText("Ваши сообщения сейчас не видны никому.", "zChatFontSmall", w, h * 1.01, gray, TEXT_ALIGN_RIGHT)
		end
	DisableClipping(false)

	//\\ подсветка края экрана, к которому притянулось окно
	if self.snap_x or self.snap_y then
		local ox, oy = self:GetX(), self:GetY()

		DisableClipping(true)
			surface.SetDrawColor(255, 255, 255, 120)

			if self.snap_x == 1 then
				surface.DrawRect(-ox, -oy, 2, ScrH())
			elseif self.snap_x == 2 then
				surface.DrawRect(ScrW() - ox - 2, -oy, 2, ScrH())
			end

			if self.snap_y == 1 then
				surface.DrawRect(-ox, -oy, ScrW(), 2)
			elseif self.snap_y == 2 then
				surface.DrawRect(-ox, ScrH() - oy - 2, ScrW(), 2)
			end
		DisableClipping(false)
	end

	if self.bActive then
		self:SetAlpha(self.alpha - (255 - self.realAlpha))
	end
end

function PANEL:SetActive(bActive, bRemovePrev)
	if (bActive) then
		self:SetAlpha(255)
		self:MakePopup()
		self.entry:RequestFocus()

		input.SetCursorPos(self:LocalToScreen(10, self:GetTall() + 10))

		hook.Run("StartChat")
	else
		self:SetAlpha(0)
		self:SetMouseInputEnabled(false)
		self:SetKeyboardInputEnabled(false)

		//\\ если окно закрыли прямо во время перетаскивания, подсветку края убираем
		self.snap_x, self.snap_y = nil, nil

		if bRemovePrev then
			self.entry:SetText("")
			self.entry.prevText = ""
		end

		gui.EnableScreenClicker(false)

		hook.Run("FinishChat")
	end

	self.bActive = bActive

	local bar = self.history:GetVBar()
	bar:SetScroll(bar.CanvasSize)
end

function PANEL:AnimateAlpha(newAlpha)
	self:CreateAnimation(1, {
		index = 1,
		target = {alpha = newAlpha},
	})
end

function PANEL:AnimateRealAlpha(newAlpha)
	self:CreateAnimation(1, {
		index = 2,
		target = {realAlpha = newAlpha},
	})
end

function PANEL:SetRealAlpha(alpha)
	self.realAlpha = alpha
end

function PANEL:OnMessageSent()
	local text = self.entry:GetText()

	if (text:find("%S")) then
		local lastEntry = hg.chat.messageHistory[#hg.chat.messageHistory]

		-- only add line to textentry history if it isn't the same message
		if (lastEntry != text) then
			if (#hg.chat.messageHistory >= 20) then
				table.remove(hg.chat.messageHistory, 1)
			end

			hg.chat.messageHistory[#hg.chat.messageHistory + 1] = text
		end

		net.Start("zChatMessage")
			net.WriteString(text)
		net.SendToServer()
	end

	self:SetActive(false, true)
end

function PANEL:AddLine(elements)
	local buffer = {
		"<font=zChatFont>"
	}

	buffer = hook.Run("ModifyMessageBuffer", buffer, CHAT_SPEAKER) or buffer

	for _, v in ipairs(elements) do
		if (type(v) == "IMaterial") then
			local texture = v:GetName()

			if (texture) then
				buffer[#buffer + 1] = string.format("<img=%s,%dx%d> ", texture, v:Width(), v:Height())
			end
		elseif (istable(v) and v.r and v.g and v.b) then
			buffer[#buffer + 1] = string.format("<color=%d,%d,%d>", v.r, v.g, v.b)
		elseif (type(v) == "Player") then
			local color = team.GetColor(v:Team())

			buffer[#buffer + 1] = string.format("<color=%d,%d,%d>%s", color.r, color.g, color.b,
				v:GetName():gsub("<", "&lt;"):gsub(">", "&gt;"))
		else
			buffer[#buffer + 1] = tostring(v):gsub("<", "&lt;"):gsub(">", "&gt;")
		end
	end

	local panel = self.history:Add("zChatMessage")
	panel:Dock(TOP)
	panel:InvalidateParent(true)
	panel:SetMarkup(table.concat(buffer))

	if (#self.entries >= 100) then
		local oldPanel = table.remove(self.entries, 1)

		if (IsValid(oldPanel)) then
			oldPanel:Remove()
		end
	end

	local bar = self.history:GetVBar()
	local bScroll = !self:GetActive() or bar.Scroll == bar.CanvasSize -- only scroll when we're not at the bottom/inactive

	if bScroll then
		bar:SetScroll(bar.CanvasSize)
	end

	self.entries[#self.entries + 1] = panel
	return panel
end

function PANEL:AddMessage(...)
	self:AddLine({...})

	chat.PlaySound()
end

vgui.Register("zChatbox", PANEL, "EditablePanel")

--\\ при смене разрешения окно чата не должно остаться за экраном
hook.Add("OnScreenSizeChanged", "ZChatLayout", function()
	hg.ChatApplyLayout(hg.chat)
end)