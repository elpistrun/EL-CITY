--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: lua/autorun/sevynxinblink.lua <
    > Callstack:  <
]]

--[[---------------------------------------------------------
    ShouldBlink Material Proxy
        Determines whether an entity is alive and should blink or not 
		Credit: anonymous_moose
-----------------------------------------------------------]]

if matproxy then
    matproxy.Add( {
        name = "ShouldBlink",

        init = function( self, mat, values )
            -- Store the name of the variable we want to set
            self.ResultTo = values.resultvar
        end,

        bind = function( self, mat, ent )
            if ( !IsValid( ent ) ) then return end

            -- If entity is a ragdoll, do not blink
            -- ( this applies to their corpses )
            if ( ent:IsRagdoll() ) then
                mat:SetInt( self.ResultTo, 0 )
            else
                mat:SetInt( self.ResultTo, 1 )
            end
        end
    } )
end
