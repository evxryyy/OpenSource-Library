-- Script 1: Setting up the handler
local SyncHandler = require(path.to.SyncHandler)

-- Create a handler for calculator operations
local testHandler = SyncHandler.new("Test")

--no .OnIvoke wich mean that will print the "Timeout error message" after 10 seconds
local result = testHandler:Invoke(...)
