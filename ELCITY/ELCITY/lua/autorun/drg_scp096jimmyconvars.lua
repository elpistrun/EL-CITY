-- "lua\\autorun\\drg_scp096jimmyconvars.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
if SERVER then

hook.Add("PostPlayerDeath", "drg_scp096_HandleDeath", function(ply)
	for i, self in ipairs(ents.FindByClass("drg_scp096jimmy")) do
		self:SetEntityRelationship(ply,D_NU)
		self:LoseEntity(ply)
	end
end)

--CreateConVar( "scp096j_vision", 2000, {FCVAR_ARCHIVE,FCVAR_NOTIFY}, "affects how far he can see" )
CreateConVar( "scp096j_screamvolume", 1, {FCVAR_ARCHIVE}, "affects how loud 096's scream is",0 )
CreateConVar( "scp096j_chasevolume", 0, {FCVAR_ARCHIVE}, "affects how loud 096's chase music is",0 )
CreateConVar( "scp096j_opendoors", 1, {FCVAR_ARCHIVE,FCVAR_NOTIFY}, "should 096 open or break doors",0,1 )
CreateConVar( "scp096j_graceperiod", 1, {FCVAR_ARCHIVE,FCVAR_NOTIFY}, "affects how long before he can kill you",0 )
CreateConVar( "scp096j_limited_anger", 0, {FCVAR_ARCHIVE,FCVAR_NOTIFY}, "scp sl mode",0,1 )

end