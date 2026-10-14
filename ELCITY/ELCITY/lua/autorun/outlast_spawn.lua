-- "lua\\autorun\\outlast_spawn.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local function AddNPC(t, class) 
	list.Set("NPC", class or t.Class, t)
end

local Category = "Outlast"

AddNPC({
	Name = "Chris Walker",
	Class = "npc_chris_walker",
	Category = Category,
})