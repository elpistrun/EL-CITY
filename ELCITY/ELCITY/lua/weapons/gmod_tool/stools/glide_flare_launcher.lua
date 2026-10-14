--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: lua/weapons/gmod_tool/stools/glide_flare_launcher.lua <
    > Callstack: gamemodes/sandbox/entities/weapons/gmod_tool/stool.lua:159
[C]:-1
gamemodes/sandbox/entities/weapons/gmod_tool/shared.lua:389
[C]:-1
gamemodes/sandbox/entities/weapons/gmod_tool/cl_init.lua:11 <
]]

TOOL.Category = "Glide"
TOOL.Name = "#tool.glide_flare_launcher.name"

TOOL.Information = {
    { name = "left" },
    { name = "right" }
}

TOOL.ClientConVar = {
    delay = 1.0,
    force = 1000
}

local function IsGlideFlareLauncher( ent )
    return IsValid( ent ) and ent:GetClass() == "glide_flare_launcher"
end

if SERVER then
    function TOOL:Deploy()
        Glide.ToolCheckMissingWiremod( self:GetOwner() )
    end

    function TOOL:UpdateFlareLauncher( ent )
        local delay = self:GetClientNumber( "delay" )
        local force = self:GetClientNumber( "force" )

        ent:SetReloadDelay( delay )
        ent:SetLaunchForce( force )
    end
end

function TOOL:LeftClick( trace )
    local ent = trace.Entity

    if IsGlideFlareLauncher( ent ) then
        if SERVER then
            self:UpdateFlareLauncher( ent )
        end

        return true
    end

    local ply = self:GetOwner()
    if not ply:CheckLimit( "glide_flare_launchers" ) then return false end

    if SERVER then
        local normal = trace.HitNormal
        local pos = trace.HitPos + normal * 5

        ent = duplicator.CreateEntityFromTable( ply, {
            Class = "glide_flare_launcher",
            Pos = pos,
            Angle = normal:Angle() + Angle( 90, 0, 0 )
        } )

        if not IsValid( ent ) then return false end

        undo.Create( self.Name )
        undo.AddEntity( ent )
        undo.SetPlayer( ply )
        undo.Finish()

        self:UpdateFlareLauncher( ent )
    end

    return true
end

function TOOL:RightClick( trace )
    local ent = trace.Entity
    if not IsGlideFlareLauncher( ent ) then return false end

    if SERVER then
        local ply = self:GetOwner()
        local delay = ent.reloadDelay
        local force = ent.launchForce

        ply:ConCommand( "glide_flare_launcher_delay " .. delay )
        ply:ConCommand( "glide_flare_launcher_force " .. force )
    end

    return true
end

local cvarMinDelay = GetConVar( "glide_flare_launcher_min_delay" )
local cvarMaxForce = GetConVar( "glide_flare_launcher_max_force" )

local conVarsDefault = TOOL:BuildConVarList()

function TOOL.BuildCPanel( panel )
    panel:Help( "#tool.glide_flare_launcher.desc" )
    panel:ToolPresets( "glide_flare_launcher", conVarsDefault )

    panel:AddControl( "slider", {
        Label = "#tool.glide_flare_launcher.delay",
        command = "glide_flare_launcher_delay",
        type = "float",
        min = cvarMinDelay and cvarMinDelay:GetFloat() or 5.0,
        max = 30
    } )

    panel:AddControl( "slider", {
        Label = "#tool.glide_flare_launcher.force",
        command = "glide_flare_launcher_force",
        type = "float",
        min = 100,
        max = cvarMaxForce and cvarMaxForce:GetFloat() or 3000
    } )
end

