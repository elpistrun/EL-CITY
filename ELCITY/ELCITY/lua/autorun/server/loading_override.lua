-- Send map PNG backgrounds to clients
local mapPngs = file.Find("html/mappng/*.png", "MOD")
for _, name in ipairs(mapPngs) do
	resource.AddSingleFile("html/mappng/" .. name)
end

-- Set loading screen URL (change IP/port to match your server)
-- For local testing: http://localhost:8080
-- For production: http://YOUR_SERVER_IP:8080
RunConsoleCommand("sv_loadingurl", "http://localhost:8080")
