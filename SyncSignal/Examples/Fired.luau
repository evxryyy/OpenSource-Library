local ReplicatedStorage = game:GetService("ReplicatedStorage")

local openEvxEngine = ReplicatedStorage.OpenEvxEngine

local SyncSignal = require(openEvxEngine.SyncSignal)

--Build a new SyncSignal instance
local build = SyncSignal.new("Build")

task.wait(1.5) -- wait a little bit to let the "Connected" script connect the bindable event

--Fire with arguments (e.g a string)
build:Fire("hello SyncSignal") -- will print "hello SyncSignal" in the "Connected" script
