--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: lua/weapons/gmod_tool/stools/glide_repair_ray.lua <
    > Callstack: gamemodes/sandbox/entities/weapons/gmod_tool/stool.lua:159
[C]:-1
gamemodes/sandbox/entities/weapons/gmod_tool/shared.lua:389
[C]:-1
gamemodes/sandbox/entities/weapons/gmod_tool/cl_init.lua:11 <
]]

TOOL.Category = "Glide"
TOOL.Name = "#tool.glide_repair_ray.name"

TOOL.Information = {
    { name = "left" },
    { name = "right" }
}

TOOL.ClientConVar = {
    distance = 50,
}

local function IsGlideRepairRay( ent )
    return IsValid( ent ) and ent:GetClass() == "glide_repair_ray"
end

if SERVER then
    function TOOL:Deploy()
        Glide.ToolCheckMissingWiremod( self:GetOwner() )
    end

    function TOOL:UpdateRepairRay( ent )
        ent:TriggerInput( "Distance", self:GetClientNumber( "distance" ) )
    end
end

function TOOL:LeftClick( trace )
    local ent = trace.Entity

    if IsGlideRepairRay( ent ) then
        if SERVER then
            self:UpdateRepairRay( ent )
        end

        return true
    end

    local ply = self:GetOwner()

    if not ply:CheckLimit( "glide_repair_rays" ) then
        return false
    end

    if SERVER then
        local normal = trace.HitNormal
        local pos = trace.HitPos + normal * 5

        ent = duplicator.CreateEntityFromTable( ply, {
            Class = "glide_repair_ray",
            Pos = pos,
            Angle = normal:Angle() + Angle( 90, 0, 0 )
        } )

        if not IsValid( ent ) then return false end

        undo.Create( self.Name )
        undo.AddEntity( ent )
        undo.SetPlayer( ply )
        undo.Finish()

        self:UpdateRepairRay( ent )
    end

    return true
end

function TOOL:RightClick( trace )
    local ent = trace.Entity
    if not IsGlideRepairRay( ent ) then return false end

    if SERVER then
        self:GetOwner():ConCommand( "glide_repair_ray_distance " .. ent:GetRepairDistance() )
    end

    return true
end

function TOOL.BuildCPanel( panel )
    panel:Help( "#tool.glide_repair_ray.desc" )

    panel:AddControl( "slider", {
        Label = "#tool.lamp.distance",
        command = "glide_repair_ray_distance",
        type = "float",
        min = 10,
        max = 200
    } )
end

