if SERVER then
    util.AddNetworkString("HG_HeadshotPlay")
    util.AddNetworkString("HG_KillPlay")
    util.AddNetworkString("HG_PistolKill")
    util.AddNetworkString("HG_KnifeKill")
    util.AddNetworkString("HG_KillFlash") 
end

HEADSHOT_SOUND = "funsound/headshot.mp3"
KNIFEKILL_SOUND = "funsound/melee.mp3"
ELPATRON_SOUND = "funsound/elpatron.mp3"

KILL_SOUNDS = {
    "funsound/1.mp3",
    "funsound/2.mp3",
    "funsound/3.mp3",
    "funsound/4.mp3",
    "funsound/5.mp3",
    "funsound/6.mp3",
    "funsound/7.mp3",
    "funsound/8.mp3",
}

if CLIENT then
    local convar_sound = CreateClientConVar("fun_sound", 1, true, false, "звук хедшота")
    local convar_flash = CreateClientConVar("fun_killflash", 1, true, false, "синий эффект")
    
    local killFlashTime = 0

    function HEADSHOT_PLAY()
        if not convar_sound:GetBool() then return end
        surface.PlaySound(HEADSHOT_SOUND)
    end

    function KILL_PLAY(typ)
        if not convar_sound:GetBool() then return end
        if KILL_SOUNDS[typ] then
            timer.Simple(0.5, function()
                surface.PlaySound(KILL_SOUNDS[typ])
            end)
        end
    end

    function KNIFE_KILL()
        if not convar_sound:GetBool() then return end
        timer.Simple(0.5, function()
            surface.PlaySound(KNIFEKILL_SOUND)
        end)
    end

    hook.Add("RenderScreenspaceEffects", "HG_KillFlashEffect", function()
        if convar_flash:GetBool() and killFlashTime > CurTime() then
            local remaining = killFlashTime - CurTime()
            local intensity = math.Clamp(remaining / 0.4, 0, 1)

            local tab = {
                [ "$pp_colour_addr" ]       = 0,
                [ "$pp_colour_addg" ]       = 0.01 * intensity,
                [ "$pp_colour_addb" ]       = 0.35 * intensity,
                [ "$pp_colour_brightness" ] = 0.04 * intensity,
                [ "$pp_colour_contrast" ]   = 1 + (0.08 * intensity),
                [ "$pp_colour_colour" ]     = 1,
                [ "$pp_colour_mulr" ]       = 0,
                [ "$pp_colour_mulg" ]       = 0,
                [ "$pp_colour_mulb" ]       = 0
            }
            DrawColorModify(tab)
        end
    end)

    net.Receive("HG_HeadshotPlay", function() HEADSHOT_PLAY() end)
    net.Receive("HG_KnifeKill", function() KNIFE_KILL() end)
    
    net.Receive("HG_KillFlash", function()
        killFlashTime = CurTime() + 0.4
    end)

    net.Receive("HG_KillPlay", function()
        local typ = net.ReadInt(8)
        KILL_PLAY(typ)
    end)
end

if SERVER then
    local convar_allowheadshot = CreateConVar("fun_headshotnotify", 1, FCVAR_ARCHIVE)
    local convar_allowkillstreak = CreateConVar("fun_killstreaknotify", 1, FCVAR_ARCHIVE)

    --; пистолет определяется по категории SWEP из сборки (lua/weapons/*: "Weapons - Pistols")
    local function IsPistolKill(infl, att)
        local wep = infl

        if IsValid(wep) and not wep.Category and wep.GetOwner then
            local owner = wep:GetOwner()
            wep = IsValid(owner) and owner:GetActiveWeapon() or nil
        end

        if not IsValid(wep) and IsValid(att) then
            wep = att:GetActiveWeapon()
        end

        return IsValid(wep) and wep.Category == "Weapons - Pistols"
    end

    resource.AddFile("sound/" .. HEADSHOT_SOUND)
    resource.AddFile("sound/" .. KNIFEKILL_SOUND)
    resource.AddFile("sound/" .. ELPATRON_SOUND)
    for _, snd in ipairs(KILL_SOUNDS) do
        resource.AddFile("sound/" .. snd)
    end

    hook.Add("HomigradDamage", "HEADSHOT_SOUND", function(ply, dmg, hit)
        if convar_allowheadshot:GetBool() then
            if (dmg:IsDamageType(DMG_BULLET) or dmg:IsDamageType(DMG_BUCKSHOT)) and 
               (IsValid(dmg:GetAttacker()) and dmg:GetAttacker():IsPlayer() and dmg:GetAttacker() != ply and hit == HITGROUP_HEAD) then
                
                local att = dmg:GetAttacker()

                --; Пистолетный хедшот: через мгновение уже понятно, был ли выстрел смертельным.
                --; Если жертва умерла — звук хедшота не играем: за этот килл отвечает ветка
                --; убийства ниже (elpatron вместо звука серии). Несмертельный хедшот из
                --; пистолета получает обычный звук хедшота, просто на 0.25 с позже.
                --; 0.25 с — это два тика организма (в этой сборке он тикает 10 раз в секунду,
                --; именно там наступает смерть от повреждения мозга). Если выстрел был несмертельным,
                --; звук просто чуть запаздывает; если смертельным — им занимается ветка убийства.
                --; Если уведомления серии выключены (/fun_killstreaknotify 0), elpatron не придёт —
                --; тогда ждать нечего и звук хедшота шлётся сразу.
                if IsPistolKill(dmg:GetInflictor(), att) and convar_allowkillstreak:GetBool() then
                    --; свой таймер на каждый выстрел: если к его срабатыванию жертва мертва,
                    --; все отложенные звуки хедшота отпадают сами — за убийство отвечает
                    --; ветка убийства (elpatron). Очередь в голову потому не глохнет: каждый
                    --; несмертельный выстрел отзвучит своим "дзынь".
                    timer.Simple(0.25, function()
                        if not IsValid(ply) or not ply:Alive() then return end

                        if IsValid(att) then
                            net.Start("HG_HeadshotPlay")
                            net.Send(att)
                        end
                    end)
                else
                    net.Start("HG_HeadshotPlay")
                    net.Send(att)
                end
            end
        end
    end)

    hook.Add("HomigradDamage", "KILL_SOUND", function(ply, dmg, hit)
        if IsValid(dmg:GetAttacker()) and dmg:GetAttacker():IsPlayer() then
            local att = dmg:GetAttacker()
            ply.ZAttackers = ply.ZAttackers or {}
            ply.ZAttackers[att] = (ply.ZAttackers[att] or 0) + dmg:GetDamage()

            if not IsValid(ply.ZBestAttacker) or (ply.ZAttackers[att] > ply.ZAttackers[ply.ZBestAttacker]) then
                ply.ZBestAttacker = att
            end

            if att == ply.ZBestAttacker then
                ply.LastDamageType = dmg:GetDamageType()
                ply.LastDamageWeapon = dmg:GetInflictor()
            end
        end
    end)

    hook.Add("PlayerDeath", "KILL_SOUND", function(ply, infl, att)
        if convar_allowkillstreak:GetBool() then
            if IsValid(ply.ZBestAttacker) then
                att = ply.ZBestAttacker
            end

            if IsValid(att) and att:IsPlayer() and att != ply then
                net.Start("HG_KillFlash")
                net.Send(att)

                att.ZKills = att.ZKills or 0
                att.ZKills = att.ZKills + 1
                
                local typ = att.ZKills

                if ply.LastDamageType == DMG_SLASH then
                    net.Start("HG_KnifeKill")
                    net.Send(att)
                elseif IsPistolKill(ply.LastDamageWeapon, att) then
                    net.Start("HG_PistolKill")
                    net.Send(att)
                else
                    net.Start("HG_KillPlay")
                    net.WriteInt(typ, 8)
                    net.Send(att)
                end
            end
        end

        ply.ZKills = 0
        ply.ZAttackers = {}
        ply.ZBestAttacker = nil
        ply.LastDamageWeapon = nil
    end)

    hook.Add("PlayerDisconnected", "KILL_SOUND_CLEANUP", function(ply)
        ply.ZKills = nil
        ply.ZAttackers = nil
        ply.ZBestAttacker = nil
        ply.LastDamageWeapon = nil
    end)

    hook.Add('PostCleanupMap', 'KILL_SOUND', function()
        for _, Ply in pairs(player.GetAll()) do
            Ply.ZKills = 0
            Ply.ZAttackers = {}
            Ply.ZBestAttacker = nil
            Ply.LastDamageWeapon = nil
        end
    end)
end