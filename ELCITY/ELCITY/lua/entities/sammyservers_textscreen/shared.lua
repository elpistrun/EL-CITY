--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: lua/entities/sammyservers_textscreen/shared.lua <
    > Callstack: lua/entities/sammyservers_textscreen/cl_init.lua:1 <
]]

ENT.Type = "anim"
ENT.Base = "base_entity"
ENT.PrintName = "SammyServers Textscreen"
ENT.Author = "SammyServers"
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

function ENT:SetupDataTables()
	self:NetworkVar("Bool", 0, "IsPersisted")
end

local function textScreenCanTool(ply, trace, tool)
	-- only allow textscreen, remover, and permaprops tool
	if IsValid(trace.Entity) and trace.Entity:GetClass() == "sammyservers_textscreen" and tool ~= "textscreen" and tool ~= "remover" and tool ~= "permaprops" then
		return false
	end
end
hook.Add("CanTool", "3D2DTextScreensPreventTools", textScreenCanTool)
