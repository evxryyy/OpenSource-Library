--!optimize 1

local types = require("./.types")

export type ClientComponent = types.ClientComponent

--This timeout is configurable if you want.
local REMOTE_TIMEOUT = 25

-- Initializes and retrieves the remote object from the server with a timeout
local function init_remote(RemoteConfig : types.RemoteConfiguration) : RemoteEvent? | RemoteFunction? | UnreliableRemoteEvent?
	local remote = script.Parent:WaitForChild(".server"):WaitForChild(RemoteConfig.Name,REMOTE_TIMEOUT)
	if(not remote) then
		error(("%s doesn't exist (Child not found)"):format(RemoteConfig.Name))
	end
	return remote
end

local Client = {}
Client.__index = Client

local ClientComponent = {}
ClientComponent.__index = ClientComponent

-- Creates a new client component linked to the given RemoteConfiguration
function Client.new(RemoteConfig : types.RemoteConfiguration) : ClientComponent
	local self = setmetatable({
		remote = init_remote(RemoteConfig),
		config = RemoteConfig,
		client_event = false
	},ClientComponent)
	return self
end

-- Sets up a listener for the OnClientEvent of the remote
function ClientComponent.OnClientEvent(self : ClientComponent,callback : (...any) -> ()) : RBXScriptConnection
	if(not self.remote.OnClientEvent) then error("Current Remote doesn't have .OnClientEvent") end	
	self.client_event = self.remote.OnClientEvent:Connect(function(...)
		if(self.config.Validator) then
			if(not self.config.Validator(...)) then return end
		end
		callback(...)
	end)
	return self.client_event
end

-- Fires a message or data to the server using FireServer
function ClientComponent.FireServer(self : ClientComponent,...)
	if(not self.remote.FireServer) then error("Current Remote doesnt have .FireServer") end	
	self.remote:FireServer(...)
end

-- Invokes a server function and waits for a return value
function ClientComponent.InvokeServer(self : ClientComponent,...) : any
	if(not self.remote.InvokeServer) then error("Current Remote doesnt have .InvokeServer") end	
	return self.remote:InvokeServer(...)
end

-- Handles a client invoke request by setting a callback for OnClientInvoke
function ClientComponent.Handle(self : ServerComponent,callback : (Player : Player,...any) -> ())
	if(not self.remote.OnClientInvoke) then error("Current Remote doesn't have .OnClientInvoke") end	
	self.remote.OnClientInvoke = callback
end

-- Disconnects the OnClientEvent connection if it exists
function ClientComponent.Disconnect(self : ClientComponent)
	if(self.client_event and typeof(self.client_event) == "RBXScriptConnection") then
		self.client_event:Disconnect()
		self.client_event = false
	end
end

-- Cleans up the client component and disconnects any connections
function ClientComponent.Destroy(self : ClientComponent)
	self:Disconnect()
	setmetatable(self,nil)
	self = nil
end

return Client
