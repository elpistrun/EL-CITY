if not wOS or not wOS.DynaBase then return end
local MALE   = "models/surrender_anim/m_surrender.mdl"
local FEMALE = "models/surrender_anim/f_surrender.mdl"
wOS.DynaBase:RegisterSource({
	Name   = "ZCity | Surrender animations",
	Type   = WOS_DYNABASE.EXTENSION,
	Male   = MALE,
	Female = FEMALE,
})

hook.Add("PreLoadAnimations", "wOS.DynaBase.MountZCitySurrender", function(gender)
	if gender == WOS_DYNABASE.MALE then
		IncludeModel(MALE)
	elseif gender == WOS_DYNABASE.FEMALE then
		IncludeModel(FEMALE)
	end
end)
