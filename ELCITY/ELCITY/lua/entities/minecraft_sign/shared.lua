--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: lua/entities/minecraft_sign/shared.lua <
    > Callstack: lua/entities/minecraft_sign/cl_init.lua:6 <
]]

//********************************//
//     Minecraft Sign Entity      //
//			 (c) McKay			  //
//********************************//

ENT.health			= 100
ENT.spawned 		= false
ENT.blockID			= 0
ENT.Type            = "anim"
ENT.Base            = "base_anim"
ENT.PrintName       = "Minecraft Sign"
ENT.Author          = "McKay"
ENT.Information		= "Press E to edit the text"
ENT.Category		= "Minecraft"

ENT.Spawnable			= true
ENT.AdminSpawnable		= true

util.PrecacheModel("models/MCModelPack/entities/sign.mdl")

function ENT:Use( activator, caller )
	umsg.Start( "MinecraftSignTextMenu", activator );
	umsg.Entity(self)
	umsg.End()
end

function ENT:SetupDataTables()
	self:NetworkVar( "String", 0, "Text" );
end

function SaveText( Player, Entity, Data )
	if (SERVER) then
		if (Data.text) then
			Entity:SetText(Data.text)
		end
		duplicator.StoreEntityModifier( Entity, "MinecraftSignText", Data )
	end
end
duplicator.RegisterEntityModifier( "MinecraftSignText", SaveText )

function GetAngleBetweenVectors( vector1, vector2 )
	vector1.z = 0;
	vector2.z = 0;
	local temp1 = vector1:Dot( vector2 );
	local temp2 = vector1:Length() * vector2:Length();
	local radians = math.acos(temp1 / temp2);
	local final = -radians/(math.pi/180);
	local angle = math.abs(math.atan2(vector2.y,vector2.x) - math.atan2(vector1.y,vector1.x));
	if (angle > math.pi) then
		final = -final;
	end
	return final;
end
