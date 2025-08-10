--Nexus Library (Networking library.)
--author : evxry_ll

local RunService = game:GetService("RunService")

local types = require("@self/.types")

export type RemoteConfiguration = types.RemoteConfiguration

local server
local client = require("@self/.client")

--if required by the server you are allowed to create and use remote event
if(RunService:IsServer()) then
	server = require("@self/.server")
end

--- Server and Client module
return {
	Server = server,
	Client = client,
}
