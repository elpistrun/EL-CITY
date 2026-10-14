CreateClientConVar("surrender_text",   "0", true, false, "Show surrender / kneel chat messages (1 = on, 0 = off)")
CreateClientConVar("surrender_voicel", "0", true, false, "Play a scared voice line when you start surrendering (1 = on, 0 = off)")
hook.Add("PopulateToolMenu", "hg_surrender_options", function()
	spawnmenu.AddToolMenuOption("Options", "Z-City", "hg_surrender", "Surrender", "", "", function(panel)
		if not IsValid(panel) then return end
		panel:ClearControls()
		panel:CheckBox("Chat messages", "surrender_text")
		panel:ControlHelp("Prints what your character is doing and how long the hold has left.")

		panel:CheckBox("Scared voice line", "surrender_voicel")
		panel:ControlHelp("Plays a panicked line when you raise your hands.")

		panel:Help("Minimum hold time is set by the server through surrender_min_time.")
	end)
end)
