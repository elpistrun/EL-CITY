--\\; Зелёная палитра RTV (клиент).
--\\;
--\\; Файл лежит в libraries/ намеренно: эту папку gamemode/loader.lua перечитывает
--\\; клиенту на каждой загрузке карты, поэтому новый файл доезжает даже если
--\\; клиент уже в игре (lua/homigrad включается один раз при запуске игры).
--\\;
--\\; Почему этот файл существует отдельно от gamemodes/.../rtv/derma/*:
--\\; панели ZB_RTVMenu / ZB_RTVButton приезжают клиенту ещё и из воркшоп-аддона
--\\; 3657285193 ("main addon" — resource.AddWorkshop в lua/autorun/loader.lua).
--\\; Внутри аддона лежит копия gamemodes/zcity со старой красной палитрой, а GMod
--\\; не скачивает и не перезаписывает файлы, которые у клиента уже есть, поэтому
--\\; правки в самих derma-файлах до клиентов не доезжают. У этого файла дубликата
--\\; в аддоне нет — он скачивается с сервера и потому реально исполняется.
if not CLIENT then return end

local FRAME_GREEN = Color(0, 255, 0, 128)

local function Blur(panel)
	local blur = hg.DrawBlur or hg.BlurBackground
	if blur then blur(panel) end
end

-- Кнопка "Exit" создаётся внутри zb.RTVMenu (из чужого файла) с красной рамкой.
-- Свою версию отрисовать нельзя, поэтому подменяем Paint самой кнопки, когда
-- она появляется у меню.
local function ExitPaintGreen(self, w, h)
	Blur(self)

	surface.SetDrawColor(FRAME_GREEN)
	surface.DrawOutlinedRect(0, 0, w, h, 2.5)

	surface.SetFont("HomigradFont")
	surface.SetTextColor(255, 255, 255, 255)
	local txt = "Exit"
	local tw, th = surface.GetTextSize(txt)
	surface.SetTextPos(w / 2 - tw / 2, h / 2 - th / 2)
	surface.DrawText(txt)
end

-- Панель окна: заголовок + зелёная рамка вместо красной.
local function MenuPaintGreen(self, w, h)
	Blur(self)

	surface.SetFont("ZB_InterfaceMediumLarge")
	surface.SetTextColor(color_white)
	local text = "Time to Rock The Vote"
	local lengthX = surface.GetTextSize(text)
	surface.SetTextPos(w / 2 - lengthX / 2, 20)
	surface.DrawText(text)

	surface.SetDrawColor(FRAME_GREEN)
	surface.DrawOutlinedRect(0, 0, w, h, 2.5)
end

local function MenuThinkGreen(self)
	if IsValid(self.ExitButton) then return end

	for _, child in ipairs(self:GetChildren()) do
		if child.GetClassName and child:GetClassName() == "DButton" then
			self.ExitButton = child
			child.Paint = ExitPaintGreen
			return
		end
	end
end

-- Строка карты: зелёная обводка, зелёная заливка голосов, зелёная вспышка победы.
local function ButtonPaintGreen(self, w, h)
	if self.disabled then return end

	surface.SetDrawColor(255, 255, 255, 255)
	surface.SetMaterial(self.MapIcon)
	surface.DrawTexturedRect(0, -w / 2, w + 15, w + 15)

	Blur(self)

	surface.SetDrawColor(0, 0, 0, 50)
	surface.DrawRect(0, 0, w, h)

	if self.disabled then
		surface.SetDrawColor(255, 255, 255, 50)
	else
		surface.SetDrawColor(0, 200, 40)
	end

	surface.DrawOutlinedRect(0, 0, w, h, ScreenScale(0.5))

	self.lerp = Lerp(FrameTime() * 5, self.lerp, w * (self.Votes / player.GetCount()))

	surface.SetDrawColor(0, 169, 0, 100)
	surface.DrawRect(0, 0, self.lerp, h)

	if self.Win and self.BipCD < CurTime() then
		self.alpha = 255
		surface.PlaySound("buttons/blip1.wav")
		self.BipCD = CurTime() + 1
		self:CreateAnimation(0.5, {
			index = 1,
			target = {
				alpha = 0
			},
			easing = "inExpo",
			bIgnoreConfig = true
		})
	end

	surface.SetDrawColor(0, 200, 40, self.alpha)
	surface.DrawRect(0, 0, w, h)
end

-- Патчим не регистрацию класса заново, а саму таблицу панели: так не важно,
-- кто и в каком порядке её зарегистрировал.
local function Apply()
	local menu = vgui.GetControlTable and vgui.GetControlTable("ZB_RTVMenu")
	local button = vgui.GetControlTable and vgui.GetControlTable("ZB_RTVButton")
	if not menu or not button then return false end

	menu.Paint = MenuPaintGreen
	menu.Think = MenuThinkGreen
	button.Paint = ButtonPaintGreen
	return true
end

Apply()
timer.Simple(1, Apply)
hook.Add("InitPostEntity", "ZB_RTVGreen", Apply)
