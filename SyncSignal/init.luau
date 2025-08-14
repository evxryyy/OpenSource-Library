--[[
	author : evxry_ll

	SyncSignal Module (inspired from Signal)
	
	A custom signal implementation that wraps Roblox's BindableEvent to provide a more controlled
	and feature-rich event system. This module ensures that only one callback can be connected
	to each signal at a time, making it ideal for synchronized operations where multiple listeners
	could cause conflicts.
	
	Key Features:
	- Single listener enforcement (only one callback can be connected at a time)
	- Global registry system to prevent duplicate signals with the same name
	- Memory management with proper cleanup methods
	- Type-safe generic implementation supporting any number of arguments
	- Familiar API similar to RBXScriptSignal
]]

-- Type definition for the SyncSignalComponent
-- This type represents a signal that can have only one connected callback at a time
-- T... represents variadic generic types that define the arguments passed through the signal
export type SyncSignalComponent<T...> = {
	-- The underlying BindableEvent instance that handles the actual event firing
	_object : BindableEvent,
	-- The currently connected callback function (or false if none is connected)
	-- This ensures we can track what function is listening to this signal
	_fn : (T...) -> ()?,
	-- Thread management object that tracks connection state
	-- _connected: boolean flag indicating if a callback is currently connected
	-- _signal: the actual RBXScriptConnection or false if not connected
	_thread : {_connected : boolean,_signal : RBXScriptConnection | false},
	-- Connects a callback function to this signal
	-- If a callback is already connected, returns the existing connection without replacing it
	Connect : (self : SyncSignalComponent<T...>,callback : (T...) -> ()) -> RBXScriptConnection,
	-- Connects a callback that will automatically disconnect after being fired once
	-- Useful for one-time event handling
	Once : (self : SyncSignalComponent<T...>,callback : (T...) -> ()) -> (),
	-- Fires the signal with the provided arguments
	-- All connected callbacks will receive these arguments
	Fire : (self : SyncSignalComponent<T...>,T...) -> (),
	-- Yields the current thread until the signal is fired
	-- Returns the arguments that were passed to Fire()
	Wait : (self : SyncSignalComponent<T...>,T...) -> T...,
	-- Completely destroys the signal, removing it from the registry and cleaning up memory
	Destroy : (self : SyncSignalComponent<T...>) -> (),
	-- Disconnects the current callback without destroying the signal
	-- The signal can be reused after disconnection
	Disconnect : (self : SyncSignalComponent<T...>) -> (),
}

-- Global registry that stores all created SyncSignal instances by name
-- This prevents duplicate signals with the same name and allows for signal reuse
-- Key: signal name (string), Value: SyncSignalComponent instance
local SyncRegistery = {} :: {[string] : SyncSignalComponent<...any>}

-- Constructor table for creating new SyncSignal instances
-- Uses metatables to provide object-oriented behavior
local SyncSignalConstructor = {}
SyncSignalConstructor.__index = SyncSignalConstructor

-- Component table that defines the methods available on SyncSignal instances
-- All signal instances will have these methods through metatable inheritance
local SyncSignalComponent = {}
SyncSignalComponent.__index = SyncSignalComponent

--[[
	Creates a new SyncSignal instance or returns an existing one with the same name
	
	@param Name - A unique string identifier for this signal
	@return SyncSignalComponent<T...> - The signal instance
	
	This constructor implements a singleton pattern per signal name, ensuring that
	multiple calls with the same name return the same signal instance. This is useful
	for cross-script communication where different scripts need to access the same signal.
]]
function SyncSignalConstructor.new<T...>(Name : string) : SyncSignalComponent<T...>
	-- Validate that the name parameter is a string
	assert(type(Name) == "string","Name must be a string")
	-- Check if a signal with this name already exists in the registry
	-- If it does, return the existing instance instead of creating a new one
	if(SyncRegistery[Name]) then return SyncRegistery[Name] end
	-- Create a new signal instance with default values
	local self = setmetatable({
		-- Create a new BindableEvent parented to this script
		-- BindableEvents allow communication between scripts in the same context
		_object = Instance.new("BindableEvent",script),
		-- Initially no callback function is connected
		_fn = false,
		-- Thread management structure to track connection state
		_thread = {
			_connected = false,  -- No connection active initially
			_signal = false,     -- No RBXScriptConnection initially
		},
	},SyncSignalComponent)
	-- Set the name of the BindableEvent for debugging purposes
	self._object.Name = Name
	-- Register this signal in the global registry
	SyncRegistery[Name] = self
	return self
end

--[[
	Connects a callback function to this signal
	
	@param callback - The function to call when the signal is fired
	@return RBXScriptConnection - A connection object that can be used to disconnect
	
	Important: This method enforces single-listener behavior. If a callback is already
	connected, it returns the existing connection without replacing it. This prevents
	multiple listeners from being attached to the same signal, ensuring synchronized behavior.
]]
function SyncSignalComponent.Connect<T...>(self : SyncSignalComponent<T...>,callback : (T...) -> ()) : RBXScriptConnection
	-- If a callback is already connected, return the existing connection
	-- This is the key feature that makes this a "Sync" signal - only one listener at a time
	if(self._thread._connected) then return self._thread._signal :: RBXScriptConnection end
	-- Store the callback function for reference
	self._fn = callback
	-- Mark the signal as having an active connection
	self._thread._connected = true
	-- Connect the callback to the underlying BindableEvent
	self._thread._signal = self._object.Event:Connect(callback)
	-- Return the connection object
	return self._thread._signal :: RBXScriptConnection
end

--[[
	Connects a callback that automatically disconnects after being fired once
	
	@param callback - The function to call when the signal is fired
	
	This is useful for scenarios where you only need to respond to an event once,
	such as waiting for initialization to complete or handling a one-time user action.
	The connection is automatically cleaned up after the first fire.
]]
function SyncSignalComponent.Once<T...>(self : SyncSignalComponent<T...>,callback : (T...) -> ()) : ()
	-- If already connected, don't replace the existing connection
	if(self._thread._connected) then return end
	-- Store the callback function
	self._fn = callback
	-- Mark as connected
	self._thread._connected = true
	-- Create a connection that will self-destruct after first use
	local connection
	connection = self._object.Event:Once(function(... : T...)
		-- Call the user's callback with all arguments
		callback(...)
		-- Disconnect the connection
		connection:Disconnect()
		-- Reset the internal state to allow new connections
		self._fn = false :: any
		self._thread._connected = false
	end)
end

--[[
	Fires the signal with the provided arguments
	
	@param ... - Any number of arguments to pass to connected callbacks
	
	This method triggers all connected callbacks (though in this implementation,
	there can only be one). The arguments are passed through the underlying
	BindableEvent to any listening callbacks.
]]
function SyncSignalComponent.Fire<T...>(self : SyncSignalComponent<T...>,...) : ()
	-- Fire the underlying BindableEvent with all provided arguments
	self._object:Fire(...)
end

--[[
	Yields the current thread until the signal is fired
	
	@return T... - The arguments that were passed to Fire()
	
	This method is useful for synchronous code that needs to wait for an event
	to occur before continuing. It will pause execution until Fire() is called
	on this signal.
]]
function SyncSignalComponent.Wait<T...>(self : SyncSignalComponent<T...>) : T...
	-- Delegate to the BindableEvent's Wait method
	return self._object.Event:Wait()
end

--[[
	Disconnects the current callback without destroying the signal
	
	This method removes the current listener but keeps the signal alive for future use.
	After calling this, a new callback can be connected to the signal.
]]
function SyncSignalComponent.Disconnect<T...>(self : SyncSignalComponent<T...>) : ()
	-- If nothing is connected, there's nothing to disconnect
	if(self._thread._connected == false) then return end
	-- Mark as disconnected
	self._thread._connected = false
	-- Clear the stored callback function
	self._fn = false :: any
	-- Disconnect the RBXScriptConnection if it exists
	if(self._thread._signal) then
		self._thread._signal:Disconnect()
	end
	-- Clear the connection reference
	self._thread._signal = false
end

--[[
	Completely destroys the signal and cleans up all resources
	
	This method should be called when the signal is no longer needed. It:
	1. Disconnects any active connections
	2. Removes the signal from the global registry
	3. Destroys the underlying BindableEvent
	4. Clears all references to help garbage collection
	
	After calling Destroy(), this signal instance should not be used again.
]]
function SyncSignalComponent.Destroy<T...>(self : SyncSignalComponent<T...>)
	-- First disconnect any active connections
	self:Disconnect()
	-- Remove this signal from the global registry if it exists
	-- This allows a new signal with the same name to be created later
	if(SyncRegistery[self._object.Name]) then
		SyncRegistery[self._object.Name] = nil
	end
	-- Destroy the underlying BindableEvent instance
	self._object:Destroy()
	-- Clear the table to help garbage collection
	table.clear(self)
	-- Remove the metatable
	setmetatable(self,nil)
	-- Nil out the reference (though this only affects the local variable)
	self = nil :: any
end

-- Method aliases for different naming conventions
-- These provide flexibility in how users can call the methods

-- Lowercase aliases for users who prefer lowercase method names
SyncSignalComponent.destroy = SyncSignalComponent.Destroy
SyncSignalComponent.disconnect = SyncSignalComponent.Disconnect
SyncSignalComponent.fire = SyncSignalComponent.Fire
SyncSignalComponent.wait = SyncSignalComponent.Wait
SyncSignalComponent.connect = SyncSignalComponent.Connect
SyncSignalComponent.once = SyncSignalComponent.Once

-- Constructor aliases for different naming preferences
SyncSignalConstructor.New = SyncSignalConstructor.new
-- "From" aliases for a more semantic construction pattern
SyncSignalConstructor.From = SyncSignalConstructor.new
SyncSignalConstructor.from = SyncSignalConstructor.new

-- Return the constructor so users can create new signals
return SyncSignalConstructor
