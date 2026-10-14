//\\ Своя плашка «кто говорит» вместо стоковой из gamemodes/base/gamemode/cl_voice.lua.
//\\ Файл base лежит у клиента в самой игре, поэтому правки на сервере до игроков не
//\\ доезжают — перерегистрируем сам класс "VoiceNotify" уже из сборки. Создание,
//\\ стопка, позиция и затухание остаются базовыми (GAMEMODE:PlayerStartVoice /
//\\ PlayerEndVoice / таймер VoiceClean) — меняется только внешний вид и раскладка.
//\\ Вид: аватарка в высоту плашки стоит отдельно слева, подложка — прозрачное стекло
//\\ (размытие плюс лёгкое затемнение, без цветной заливки) с ником по центру.
//\\ Совместимость со стоковым классом сохранена: plyIndex, Color, VolumeColor,
//\\ SetText и UpdatePlayerInfo на месте — их читают аддоны (см. комментарии в base).

if not CLIENT then return end

local PANEL = {}

local PANEL_W = 220
local PANEL_H = 40
local RADIUS = 4

//; сегментов на угловую дугу: у стокового draw.RoundedBox их шесть, из-за чего углы
//; выходят гранёными. Своими дугами рисуем и маску (форму стекла), и кромку
local CORNER_SEG = 12

//; у аватарки скругление своё и много меньше: на её 40 px радиус 8 срезал бы картинку
local AVATAR_RADIUS = 2

//; аватарка ровно в высоту плашки: они стоят в один размер, без полей сверху и снизу
local AVATAR = PANEL_H
local AVATAR_X = 0
local PLATE_X = AVATAR_X + AVATAR + 8

//; плашка чуть длиннее стоковой (у base VoicePanelWide = 250): контейнер растягиваем сами,
//; отступ справа и вертикаль берём ровно те же, что в base — 50 px и ScrH()*0.13, а низ стопки задаём своими пикселями
local CONTAINER_W = 260
local CONTAINER_RIGHT = 50
local CONTAINER_TOP = 0.13

//; плашка голоса прижата к низу контейнера, поэтому опустить её — это уменьшить нижний
//; отступ: 60 px от низа экрана вместо стоковых 13% (это около 140 px на 1080p), то есть
//; примерно вдвое ниже. Высоту контейнера считаем от низа, а не долей экрана
local CONTAINER_BOTTOM = 60

//; ник мелкий и по центру плашки; совсем длинный ник ступенькой уходит на шрифт мельче.
//; ZB_InterfaceMedium (10) в запасном списке специально нет — он крупнее своего же ника,
//; поэтому запасной ступенью идёт только ZB_InterfaceSmall (6)
local NAME_SIZE = 9
local NAME_FONTS = {"ZB_VoiceName", "ZB_InterfaceSmall"}

//; подложка прозрачная, поэтому тень под ником обязательна: белый текст иначе теряется
local CLR_SHADOW = Color(0, 0, 0, 190)

//; стекло чуть темнее чистого размытия: так ник читается на светлых картах и видна
//; сама плашка там, где за ней однотонный фон
local CLR_TINT = Color(0, 0, 0, 55)

//; кромка плашки: без неё размытое стекло на однотонном тёмном фоне почти не видно
local CLR_OUTLINE = Color(255, 255, 255, 255)
local OUTLINE_W = 1

//; сколько плашка гаснет после того, как игрок замолчал. base на это тратит целую секунду
//; (там fadeAnim:Start(1)), из-за чего плашка висела ещё долго после разговора —
//; поэтому свою долю проходим за FADE_TIME, а остаток стоковой анимации не показываем
local FADE_TIME = 0.35

local blur_mat = Material("pp/blurscreen")

//\\ Шрифт ника: тот же hg_font, что у остальных надписей сборки, только размер свой
local function MakeNameFont()
	local cv = GetConVar("hg_font")
	local family = cv and cv:GetString() or ""

	if family == "" or family == "Bahnschrift" then
		family = "Rubik"
	end

	surface.CreateFont("ZB_VoiceName", {
		font = family,
		size = ScreenScale(NAME_SIZE),
		weight = 400,
		antialias = true
	})
end

//\\ Контур скруглённого прямоугольника: обход по часовой стрелке, по дуге на каждый угол.
//\\ Свои дуги нужны потому, что draw.RoundedBox рисует угол всего шестью точками, и он
//\\ выходит гранёным — это и было видно на скруглениях. Скруглённый прямоугольник выпуклый,
//\\ поэтому его можно отдать одним DrawPoly — без разбивки на прямоугольники и дуги
local function RoundedPoly(x, y, w, h, r, seg)
	local points = {}

	seg = math.max(seg or CORNER_SEG, 2)
	r = math.Clamp(r or 0, 0, math.min(w, h) / 2)

	//; центры угловых дуг и угол, с которого начинается каждая (дальше идём по 90°)
	local corners = {
		{x + w - r, y + r, -90},
		{x + w - r, y + h - r, 0},
		{x + r, y + h - r, 90},
		{x + r, y + r, 180},
	}

	for i = 1, #corners do
		local cx, cy, start = corners[i][1], corners[i][2], corners[i][3]

		for s = 0, seg do
			local ang = math.rad(start + 90 * s / seg)

			points[#points + 1] = {x = cx + math.cos(ang) * r, y = cy + math.sin(ang) * r}
		end
	end

	return points
end

//\\ Кромка по тому же контуру, но линиями по сегментам дуг: обводка из прямоугольников
//\\ стокового хелпера ступенчатая именно на углах. Толще пикселя — рисуем несколькими
//\\ вложенными контурами
local function DrawRoundedOutlineSmooth(x, y, w, h, r, thickness, color, seg)
	thickness = math.max(thickness or 1, 1)

	draw.NoTexture()
	surface.SetDrawColor(color)

	for i = 0, thickness - 1 do
		local pts = RoundedPoly(x + i, y + i, w - i * 2, h - i * 2, (r or 0) - i, seg)

		for k = 1, #pts - 1 do
			surface.DrawLine(pts[k].x, pts[k].y, pts[k + 1].x, pts[k + 1].y)
		end

		//; замыкаем контур: последняя точка дуги соединяется с первой по верхней стороне
		surface.DrawLine(pts[#pts].x, pts[#pts].y, pts[1].x, pts[1].y)
	end
end

//\\ Стенсил-маска со скруглением: всё, что нарисует func, останется только внутри
//\\ скруглённого прямоугольника. Нужна дважды — закруглить стекло плашки и аватарку
local function MaskRounded(x, y, w, h, radius, func)
	if w <= 0 or h <= 0 then return end

	//; пишем маску через провал сравнения, а не через проход: так запись не зависит от
	//; теста глубины и не теряется молча. Приём взят из чужого рабочего кода (F4-меню)
	render.SetStencilWriteMask(255)
	render.SetStencilTestMask(255)
	render.SetStencilReferenceValue(0)
	render.SetStencilPassOperation(STENCIL_KEEP)
	render.SetStencilZFailOperation(STENCIL_KEEP)
	render.ClearStencil()

	render.SetStencilEnable(true)
	render.SetStencilReferenceValue(1)
	render.SetStencilCompareFunction(STENCIL_NEVER)
	render.SetStencilFailOperation(STENCIL_REPLACE)

	//; сама маска не должна попасть в цвет: пишем её только в стенсил
	//; (render.SetColorMask в этом билде нет, поэтому гасим запись цвета оверрайдом).
	//; draw.NoTexture обязателен: маска рисуется ТЕКУЩИМ материалом, а после размытия
	//; текущий материал — blurscreen, и он тянул маску на весь экран: углы оставались
	//; квадратными (и у стекла, и у аватарки). Тот же приём есть в чужом коде: F4-меню
	//; зовёт draw.NoTexture перед своей маской по той же причине
	draw.NoTexture()
	surface.SetDrawColor(255, 255, 255, 255)
	render.OverrideColorWriteEnable(true, false)
	surface.DrawPoly(RoundedPoly(x, y, w, h, radius, CORNER_SEG))
	render.OverrideColorWriteEnable(false, false)

	render.SetStencilCompareFunction(STENCIL_EQUAL)
	render.SetStencilPassOperation(STENCIL_KEEP)
	render.SetStencilFailOperation(STENCIL_KEEP)

	func()

	render.SetStencilEnable(false)
	render.ClearStencil()
end

//\\ Подложка плашки: прозрачное стекло — только размытие того, что за ней, никакой краски.
//\\ Размытие берём выборкой по UV, а не «весь экран со сдвигом»: так стекло ложится точно
//\\ в плашку и не лезет под аватарку, да и рисуется только его площадь, а не весь экран.
//\\ Potato-режим (hg_potatopc) намеренно не проверяем, и это не самоуправство: в сборке
//\\ он размытие не выключает, а только вдвое ослабляет (hg.DrawBlur, amount * 0.5), а у
//\\ плашки голоса площадь крошечная, так что даже полная сила стоит копейки
//\\
//\\ Сила размытия вынесена отдельно: она и делает стекло гладким. На штатной пятёрке
//\\ сквозь плашку читалась текстура земли, и она выглядела пятнистой, а не стеклянной
local BLUR_STRENGTH = 14

local function DrawGlass(panel, x, y, w, h)
	if w <= 0 or h <= 0 then return end

	//; альфу панели подмешиваем и в размытие, и в затемнение: иначе уход плашки виден
	//; только по аватарке, а само стекло исчезает рывком
	local a = panel:GetAlpha() / 255

	local sx, sy = panel:LocalToScreen(0, 0)
	local sw, sh = ScrW(), ScrH()

	local u0, v0 = (sx + x) / sw, (sy + y) / sh
	local u1, v1 = (sx + x + w) / sw, (sy + y + h) / sh

	//; blurscreen рисуем БЕЛЫМ: с тёмным цветом выходит затемнение вместо размытия.
	//; Проходов три (0.34 / 0.67 / 1): каждый следующий берёт уже размытую картинку и
	//; размывает её сильнее — так подложка выходит ровной, без пятен. Больше проходов
	//; не надо: каждый — это захват всего экрана, а potato-режим тут стоит не зря
	surface.SetMaterial(blur_mat)
	surface.SetDrawColor(255, 255, 255, 255 * a)

	for i = 0.34, 1, 0.33 do
		blur_mat:SetFloat("$blur", i * BLUR_STRENGTH)
		blur_mat:Recompute()

		render.UpdateScreenEffectTexture()
		surface.DrawTexturedRectUV(x, y, w, h, u0, v0, u1, v1)
	end

	//; поверх размытия — лёгкое затемнение: чистый блюр на светлой карте почти не читается
	//; после SetMaterial(blur_mat) прямоугольники рисуются бы текущим материалом, поэтому
	//; сперва явно ставим белую текстуру: затемнение должно быть ровной заливкой
	draw.NoTexture()
	surface.SetDrawColor(CLR_TINT.r, CLR_TINT.g, CLR_TINT.b, CLR_TINT.a * a)
	surface.DrawRect(x, y, w, h)
end

//; шрифт под ником: первый из списка, который влезает в плашку
local function NameFont(txt, plate_w)
	local avail = math.max(plate_w - 24, 20)

	for i = 1, #NAME_FONTS do
		surface.SetFont(NAME_FONTS[i])

		if surface.GetTextSize(txt) <= avail then return NAME_FONTS[i] end
	end

	return NAME_FONTS[#NAME_FONTS]
end

//\\ Плашки складываются в контейнер base (g_VoicePanelList) и растягиваются по его ширине,
//\\ поэтому «длиннее» делается здесь: стоковые 250 px становятся CONTAINER_W, а отступ
//\\ справа и сверху отступы как в base, а высота считается от низа экрана (ширина на узких режется)
local function WidenVoicePanelList()
	if not IsValid(g_VoicePanelList) then return end

	local w = math.min(CONTAINER_W, math.floor(ScrW() * 0.34))
	local top = math.floor(ScrH() * CONTAINER_TOP)

	//; высоту берём от низа экрана: плашка стоит в самом низу стопки, так она и опускается
	g_VoicePanelList:SetPos(ScrW() - w - CONTAINER_RIGHT, top)
	g_VoicePanelList:SetSize(w, math.max(ScrH() - CONTAINER_BOTTOM - top, 1))
end

function PANEL:Init()
	self.ply = nil
	self.plyIndex = nil

	//; эти два поля читают аддоны — в base они помечены как «не переименовывать», поэтому оставляем
	self.Color = color_transparent
	self.VolumeColor = Color(0, 255, 0, 240)

	//; аватарка рисуется вручную (PaintOver ниже): только так её можно скруглить
	self.Avatar = vgui.Create("AvatarImage", self)
	self.Avatar:SetSize(AVATAR, AVATAR)
	self.Avatar:SetMouseInputEnabled(false)
	self.Avatar:SetPaintedManually(true)

	self:SetSize(PANEL_W, PANEL_H)
	self:DockMargin(2, 2, 2, 2)
	self:Dock(BOTTOM)

	WidenVoicePanelList()
end

//; аватарка ровно в высоту плашки
function PANEL:PerformLayout(w, h)
	self.Avatar:SetPos(AVATAR_X, math.floor(h / 2 - AVATAR / 2))
	self.Avatar:SetSize(AVATAR, AVATAR)
end

function PANEL:Setup(ply, playerIndex)
	self.ply = ply

	//; plyIndex нужен таймеру VoiceClean из base: он по нему спрашивает util.IsPlayerSpeaking
	self.plyIndex = playerIndex or (IsValid(ply) and ply:EntIndex() or nil)

	self:UpdatePlayerInfo()

	self:InvalidateLayout()
end

//; совместимость со стоковым классом: base и сторонние аддоны зовут этот метод
function PANEL:UpdatePlayerInfo(setColor)
	if IsValid(self.ply) then
		self.LastName = self.ply:Nick()
	else
		self.LastName = "Unknown Player " .. tostring(self.plyIndex)
	end

	if not IsValid(self.Avatar) then return end

	//; аватарку тянем в 64 px и уменьшаем до своего размера — так картинка чётче
	self.Avatar:SetPlayer(IsValid(self.ply) and self.ply or NULL, 64)

	if not setColor then
		self.Color = hook.Run("GetTeamColor", IsValid(self.ply) and self.ply or NULL)
	end
end

//; тоже для совместимости: в стоковом классе это SetText на подпись, у нас подписи нет
function PANEL:SetText(text)
	self.LastName = text
end

function PANEL:Think()
	//; игрок пропал (вышел / сменил карту) — плашку не ждём до VoiceClean
	if not IsValid(self.ply) then
		self:Remove()

		return
	end

	//; сперва крутим затухание, а потом тянем за ним альфу аватарки: она рисуется вручную
	//; (PaintManual) и сама вместе с плашкой не гаснет
	if self.fadeAnim then self.fadeAnim:Run() end

	if IsValid(self.Avatar) then
		self.Avatar:SetAlpha(self:GetAlpha())
	end
end

function PANEL:Paint(w, h)
	local plate_w = math.max(w - PLATE_X, 0)

	//; альфа панели: идёт затухание — и стекло, кромка и ник должны гаснуть вместе с ним.
	//; Раньше они рисовались своими непрозрачными цветами и альфу не слушали, из-за чего
	//; плавно уходила только аватарка, а вся плашка исчезала рывком в самом конце
	local a = self:GetAlpha() / 255

	//; подложка только под ником и со скруглением: аватарка стоит отдельно от плашки
	if plate_w > 0 then
		MaskRounded(PLATE_X, 0, plate_w, h, RADIUS, function()
			DrawGlass(self, PLATE_X, 0, plate_w, h)

			//; Кромку (белую обводку) выключили: вернуть её — одна строка ниже,
			//; DrawRoundedOutlineSmooth(PLATE_X, 0, plate_w, h, RADIUS, OUTLINE_W, CLR_OUTLINE)
			//; Сам хелпер и его константы оставлены в файле, иначе включать было бы нечего
		end)
	end

	if not IsValid(self.ply) then return end

	local txt = self.ply:Nick()

	if txt == nil or txt == "" then return end

	//; ник по центру плашки, со сдвинутой на пиксель тенью под ним
	local cx = PLATE_X + plate_w / 2
	local cy = h / 2
	local font = NameFont(txt, plate_w)

	//; TEXT_ALIGN_MIDDLE в этом билде нет — центр по обеим осям даёт TEXT_ALIGN_CENTER
	draw.SimpleText(txt, font, cx + 1, cy + 1, Color(0, 0, 0, CLR_SHADOW.a * a), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	draw.SimpleText(txt, font, cx, cy, Color(255, 255, 255, 255 * a), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

//; Аватарка со скруглением: vgui рисует панель целиком, поэтому кладём её в стенсил-маску.
//; PaintManual рисует панель на её собственном месте, смещать ничего не надо
function PANEL:PaintOver(w, h)
	MaskRounded(AVATAR_X, math.floor(h / 2 - AVATAR / 2), AVATAR, AVATAR, AVATAR_RADIUS, function()
		self.Avatar:PaintManual()
	end)
end

//; затухание — как в base, только снимаем плашку сами: таблица PlayerVoicePanels живёт
//; локально внутри файла base, из сборки её не достать (у base там была чистка записи).
//; Альфу аватарки подтягивает Think — заодно это возвращает её, когда база ставит 255
function PANEL:FadeOut(anim, delta, data)
	if not IsValid(self) then return end

	if anim.Finished then
		self:Remove()

		return
	end

	//; Считаем по своему времени, а не по delta из Derma_Anim: там delta уже перекошена
	//; стоковой кривой (возведение в переменную степень), из-за чего затухание шло
	//; рывком посередине. Начало замечаем по смене самого объекта анимации — base создаёт
	//; новый на каждый уход, — а альфу ведём по мягкой кривой: плавный вход и выход
	if self.FadeAnim ~= anim then
		self.FadeAnim = anim
		self.FadeStart = SysTime()
	end

	//; SysTime, а не счётчик кадров: при любом FPS затухание идёт с той же скоростью
	local t = math.Clamp((SysTime() - (self.FadeStart or SysTime())) / FADE_TIME, 0, 1)
	local ease = t * t * (3 - 2 * t)

	self:SetAlpha(255 * (1 - ease))

	if t >= 1 then
		self:Remove()
	end
end

//\\ Регистрация идёт дважды: сразу (zcity грузится после base) и ещё раз на InitPostEntity —
//\\ так класс гарантированно наш, даже если кто-то перерегистрирует "VoiceNotify" позже
local function RegisterVoicePanel()
	vgui.Register("VoiceNotify", PANEL, "DPanel")
end

MakeNameFont()
RegisterVoicePanel()

hook.Add("InitPostEntity", "zb_custom_voice", function()
	MakeNameFont()
	RegisterVoicePanel()
	WidenVoicePanelList()

	//; контейнер создаётся в своём InitPostEntity у base, порядок хуков не гарантирован,
	//; поэтому растягиваем ещё раз следующим кадром — на случай, если не успели
	timer.Simple(0, WidenVoicePanelList)
end)
