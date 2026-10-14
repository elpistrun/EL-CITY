--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: lua/autorun/client/saxton_vannacci_v4_firstperson.lua <
    > Callstack:  <
]]

-- Client-only body view. Custom hands are handled separately by AddValidHands.
local playerModel = "models/player/aarmy/saxton_vannacci_v4.mdl"
local bodyModel = "models/player/aarmy/saxton_vannacci_v4_fpbody.mdl"
local enabled = CreateClientConVar("saxton_v4_firstperson_body", "1", true, false,
    "Mostra busto e gambe di Saxton Vannacci V4 in prima persona.", 0, 1)

SaxtonVannacciV4 = SaxtonVannacciV4 or {}
if IsValid(SaxtonVannacciV4.BodyView) then SaxtonVannacciV4.BodyView:Remove() end
SaxtonVannacciV4.BodyView = nil

local function removeBody()
    if IsValid(SaxtonVannacciV4.BodyView) then SaxtonVannacciV4.BodyView:Remove() end
    SaxtonVannacciV4.BodyView = nil
end

hook.Add("PostDrawOpaqueRenderables", "SaxtonVannacciV4_FirstPersonBody", function(depth, skybox)
    if depth or skybox then return end
    local ply = LocalPlayer()
    if not enabled:GetBool() or not IsValid(ply) or not ply:Alive()
        or string.lower(ply:GetModel() or "") ~= playerModel then
        removeBody()
        return
    end
    -- Respect third-person cameras, vehicles and spectator views.
    if GetViewEntity() ~= ply or ply:ShouldDrawLocalPlayer() or ply:InVehicle()
        or EyePos():DistToSqr(ply:EyePos()) > 64 then return end

    local body = SaxtonVannacciV4.BodyView
    if not IsValid(body) then
        body = ClientsideModel(bodyModel, RENDERGROUP_OPAQUE)
        if not IsValid(body) then return end
        SaxtonVannacciV4.BodyView = body
        body:SetNoDraw(true)
        body:DrawShadow(false)
        body:SetParent(ply)
        body:SetLocalPos(vector_origin)
        body:SetLocalAngles(angle_zero)
        body:AddEffects(EF_BONEMERGE)
    elseif body:GetParent() ~= ply then
        body:SetParent(ply)
    end
    body:SetSkin(ply:GetSkin())
    body:SetupBones()
    body:DrawModel()
end)

hook.Add("PopulateToolMenu", "SaxtonVannacciV4_Options", function()
    spawnmenu.AddToolMenuOption("Options", "Saxton Vannacci V4", "SaxtonV4FirstPerson",
        "Prima persona", "", "", function(panel)
            panel:ClearControls()
            panel:CheckBox("Mostra busto e gambe", "saxton_v4_firstperson_body")
            panel:Help("Si attiva con il playermodel Saxton Vannacci V4. Le mani personalizzate restano disponibili anche disattivando questa opzione.")
        end)
end)

hook.Add("PostCleanupMap", "SaxtonVannacciV4_BodyCleanup", removeBody)
hook.Add("ShutDown", "SaxtonVannacciV4_BodyShutdown", removeBody)
cvars.AddChangeCallback("saxton_v4_firstperson_body", function(_, _, value)
    if tonumber(value) == 0 then removeBody() end
end, "SaxtonVannacciV4_BodyToggle")

