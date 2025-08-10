--!optimize 1

local types = require("./.types")

export type ServerComponent = types.ServerComponent

-- Initializes or creates a remote instance based on the RemoteConfiguration
local function init_remote(RemoteConfig : types.RemoteConfiguration) : RemoteEvent | RemoteFunction | UnreliableRemoteEvent
	if(script:FindFirstChild(RemoteConfig.Name)) then return script:FindFirstChild(RemoteConfig.Name) end
	local Remote = Instance.new(RemoteConfig.RemoteType)
	Remote.Name = RemoteConfig.Name
	Remote.Parent = script
	return Remote
end

local Server = {}
Server.__index = Server

local ServerComponent = {}
ServerComponent.__index = ServerComponent

-- Creates a new server component linked to the given RemoteConfiguration
function Server.new(RemoteConfig : types.RemoteConfiguration) : ServerComponent
	local self = setmetatable({
		remote = init_remote(RemoteConfig),
		config = RemoteConfig,
		server_event = false
	},ServerComponent)
	return self
end

-- Sets up a listener for the OnServerEvent of the remote
function ServerComponent.OnServerEvent(self : ServerComponent,callback : (Player : Player,...any) -> ()) : RBXScriptConnection
	if(not self.remote.OnServerEvent) then error("Current Remote doesnt have .OnServerEvent") end	
	self.server_event = self.remote.OnServerEvent:Connect(function(Player : Player,...)
		if(self.config.Validator) then
			if(not self.config.Validator(Player,...)) then return end
		end
		callback(Player,...)
	end)
	return self.server_event
end

-- Sends a message or data to a specific client using FireClient
function ServerComponent.FireClient(self : ServerComponent,Player : Player,...)
	if(not self.remote.FireClient) then error("Current Remote doesnt have .FireClient") end	
	self.remote:FireClient(Player,...)
end

-- Invokes a client function and waits for a return value
function ServerComponent.InvokeClient(self : ServerComponent,Player : Player,...) : any
	if(not self.remote.InvokeClient) then error("Current Remote doesnt have .InvokeClient") end	
	return self.remote:InvokeClient(Player,...)
end

-- Handles a server invoke request by setting a callback for OnServerInvoke
function ServerComponent.Handle(self : ServerComponent,callback : (Player : Player,...any) -> ())
	if(not self.remote.OnServerInvoke) then error("Current Remote doesnt have .OnServerInvoke") end	
	self.remote.OnServerInvoke = callback
end

-- Disconnects the OnServerEvent connection if it exists
function ServerComponent.Disconnect(self : ServerComponent)
	if(self.server_event and typeof(self.server_event) == "RBXScriptConnection") then
		self.server_event:Disconnect()
		self.server_event = false
	end
end

-- Cleans up the server component, disconnects events, and destroys the remote
function ServerComponent.Destroy(self : ServerComponent)
	self:Disconnect()
	self.remote:Destroy()
	setmetatable(self,nil)
	self = nil
end

return Server
