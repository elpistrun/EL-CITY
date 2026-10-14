include("shared.lua")

function ENT:Draw()
	self:DrawModel()
end

function ENT:Initialize()
	self.HudHintMarkup = markup.Parse("<font=ZCity_Tiny>Граната\n<colour=200,0,0>БЕГИ, ИДИОТ!</colour></font>",450)
end