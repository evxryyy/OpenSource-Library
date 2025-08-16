local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local ModuleLoader = require(ReplicatedStorage.ModuleLoader)

ModuleLoader.SetSettings({
	SHOW_DEBUG_PRINT = false,
	USE_DESCENDANT = true,
})
local ElapsedTime = ModuleLoader.WaitUntilStarted()
print(ElapsedTime)
local Service = ModuleLoader.Find("PlayerService")
print(Service)

