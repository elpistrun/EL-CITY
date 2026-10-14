-- "lua\\autorun\\postal_dude.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
sound.AddSoundOverrides( "lua/playermodel_dude_sounds.lua" )

postaldude = "models/player/postal2_dude.mdl"

player_manager.AddValidModel( "Postal 2 - Postal Dude", postaldude )

player_manager.AddValidHands( "Postal 2 - Postal Dude", "models/player/postal2_dude_hands.mdl", 0, "0" )

concommand.Add( "postaldude_getdown", function( ply )
	if (ply:GetModel() == postaldude)then
		ply:EmitSound("playermodel_dude.getdown") 
	end
end)

hook.Add("PlayerHurt","postaldude_PlayerHurt",function(ply,velocity)	
	if(ply:GetModel() == postaldude)then
		ply:EmitSound("playermodel_dude.hurt")
		return true
	end
end)

	
