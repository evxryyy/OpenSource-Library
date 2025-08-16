local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local ModuleLoader = require(ReplicatedStorage.ModuleLoader)

ModuleLoader.SetSettings({
	SHOW_DEBUG_PRINT = false,
	USE_DESCENDANT = true,
})
ModuleLoader.Load(ServerScriptService.Services)
ModuleLoader.Start()
