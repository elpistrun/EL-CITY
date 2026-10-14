-- "lua\\entities\\lvs_wheeldrive_t34_57\\cl_init.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
include("shared.lua")

function ENT:TankViewOverride( ply, pos, angles, fov, pod )
	if ply == self:GetDriver() and not pod:GetThirdPersonMode() then
		local ID = self:LookupAttachment( "muzzle_57" )

		local Muzzle = self:GetAttachment( ID )

		if Muzzle then
			pos =  Muzzle.Pos - Muzzle.Ang:Up() * 110 + Muzzle.Ang:Forward() * 12 - Muzzle.Ang:Right() * 5
		end

	end

	return pos, angles, fov
end
