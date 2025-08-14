local ReplicatedStorage = game:GetService("ReplicatedStorage")

local openEvxEngine = ReplicatedStorage.OpenEvxEngine

local SyncSignal = require(openEvxEngine.SyncSignal)

--Build a new SyncSignal instance
local build = SyncSignal.new("Build")

--connect the .Event of the BindableEvent
build:Connect(function(...)
	print(...) -- prints the arguments passed to the .Fire
end)

--Fire with arguments (e.g a string)
build:Fire("hello SyncSignal")
