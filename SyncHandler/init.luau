--[[
	author : evxry_ll

	SyncHandler Module (inspired from Signal)
	
	A sophisticated handler system built on top of Roblox's BindableFunction that provides
	synchronous function invocation with timeout protection. This module ensures that only
	one handler can be registered at a time, making it ideal for request-response patterns
	where multiple handlers could cause conflicts or ambiguous behavior.
	
	Key Features:
	- Single handler enforcement (only one callback can handle invocations at a time)
	- Configurable timeout system to prevent indefinite waiting
	- Global registry to prevent duplicate handlers with the same name
	- Type-safe generic implementation supporting any argument types
	- Clean disconnection mechanism that returns a cleanup function
	
	Use Cases:
	- Inter-script communication requiring responses
	- Synchronous API implementations
	- Request-response patterns between different parts of your game
]]

-- Type definition for the SyncHandlerComponent
-- This type represents a handler that can process invocations and return values
-- T... represents variadic generic types for the arguments passed to the handler
export type SyncHandlerComponent<T...> = {
	-- The underlying BindableFunction that handles the actual invocation mechanism
	-- BindableFunctions allow synchronous communication between scripts
	_object : BindableFunction,
	-- The currently registered handler function (or false if none is registered)
	-- This function will be called when Invoke is used
	_fn : (T...) -> ()?,
	-- Timeout duration in seconds for invoke operations
	-- If the handler doesn't respond within this time, the invoke will fail
	_invokeTimeOut : number,
	-- Thread management object tracking the handler state
	-- _connected: indicates if a handler is currently registered
	-- _handler: reference to the actual handler function
	_thread : {_connected : boolean,_handler : (T...) -> () | false},
	-- Invokes the handler with the provided arguments and waits for a response
	-- Returns the handler's response or nil if timeout occurs
	Invoke : (self : SyncHandlerComponent<T...>,T...) -> ...any,
	-- Registers a callback function to handle invocations
	-- Returns a cleanup function that can be called to disconnect the handler
	OnInvoke : (self : SyncHandlerComponent<T...>,callback : (T...) -> ()) -> () -> (),
	-- Sets the timeout duration for invoke operations
	SetTimeout : (self : SyncHandlerComponent<T...>,timeout : number) -> (), 
	-- Completely destroys the handler and cleans up resources
	Destroy : (self : SyncHandlerComponent<T...>) -> (),
}

-- Global registry storing all created SyncHandler instances by name
-- This prevents duplicate handlers and allows handlers to be retrieved by name
-- Key: handler name (string), Value: SyncHandlerComponent instance
local SyncRegistery = {} :: {[string] : SyncHandlerComponent<...any>}

-- Constructor table for creating new SyncHandler instances
-- Implements the factory pattern for object creation
local SyncHandlerConstructor = {}
SyncHandlerConstructor.__index = SyncHandlerConstructor

-- Component table defining methods available on SyncHandler instances
-- All handler instances inherit these methods through metatables
local SyncHandlerComponent = {}
SyncHandlerComponent.__index = SyncHandlerComponent

--[[
	Creates a new SyncHandler instance or returns an existing one with the same name
	
	@param Name - A unique string identifier for this handler
	@return SyncHandlerComponent<T...> - The handler instance
	
	This constructor implements a singleton pattern per handler name. If a handler
	with the given name already exists, it returns that instance instead of creating
	a new one. This is crucial for cross-script communication where different scripts
	need to access the same handler.
]]
function SyncHandlerConstructor.new<T...>(Name : string) : SyncHandlerComponent<T...>
	-- Validate that the name parameter is a string
	assert(type(Name) == "string", "SyncHandler.new() expects a string for the 'Name' parameter, but received " .. type(Name))
	-- Check if a handler with this name already exists
	-- Return the existing instance to maintain singleton behavior
	if(SyncRegistery[Name]) then return SyncRegistery[Name] end
	-- Create a new handler instance with default configuration
	local self = setmetatable({
		-- Create a new BindableFunction parented to this script
		-- BindableFunctions enable synchronous cross-script communication
		_object = Instance.new("BindableFunction",script),
		-- No handler function registered initially
		_fn = false,
		-- Default timeout of 10 seconds for invoke operations
		-- This prevents infinite waiting if the handler doesn't respond
		_invokeTimeOut = 10,
		-- Thread management with no active handler initially
		_thread = {_connected = false,_handler = false},
	},SyncHandlerComponent)
	-- Set the BindableFunction's name for debugging and identification
	self._object.Name = Name
	-- Register this handler in the global registry
	SyncRegistery[Name] = self
	return self
end

--[[
	Registers a callback function to handle invocations
	
	@param callback - The function that will process invocations and return results
	@return function - A cleanup function that disconnects the handler when called
	
	This method enforces single-handler behavior. If a handler is already registered,
	it returns a cleanup function for the existing handler without replacing it.
	The returned cleanup function provides a convenient way to disconnect the handler
	without needing to keep a reference to the handler object.
]]
function SyncHandlerComponent.OnInvoke<T...>(self : SyncHandlerComponent<T...>,callback : (T...) -> ()) : () -> ()
	-- Validate that the callback is a function
	assert(type(callback) == "function", "OnInvoke() expects a function for the 'callback' parameter, but received " .. type(callback))
	-- If a handler is already connected, return a cleanup function for it
	-- This maintains the single-handler constraint
	if(self._thread._connected) then
		return function()
			-- Double-check that we're still connected before cleaning up
			if(self._thread._connected == false :: any) then return end
			-- Clear the BindableFunction's OnInvoke callback
			self._object.OnInvoke = nil :: any
			-- Clear internal references
			self._fn = false :: any
			self._thread._connected = false
			self._thread._handler = false
		end
	end
	-- Register the new handler
	self._fn = callback
	self._thread._connected = true
	self._thread._handler = callback
	-- Set the BindableFunction's OnInvoke to our callback
	-- This is what actually handles incoming invocations
	self._object.OnInvoke = callback
	-- Return a cleanup function that can be called to disconnect this handler
	-- This follows the common pattern of returning unsubscribe functions
	return function()
		-- Only clean up if we're still connected
		if(self._thread._connected == false) then return end
		-- Clear the BindableFunction's callback
		self._object.OnInvoke = nil :: any
		-- Reset all internal state
		self._fn = false :: any
		self._thread._connected = false
		self._thread._handler = false
	end
end

--[[
	Invokes the handler with the provided arguments and waits for a response
	
	@param ... - Arguments to pass to the handler function
	@return ...any - The values returned by the handler, or nil if timeout occurs
	
	This method implements a timeout-protected invocation system. It attempts to
	invoke the handler and will wait up to the configured timeout duration for
	a response. If no response is received within the timeout, it returns nil
	and logs a warning.
	
	The implementation uses a polling approach with task.defer to prevent blocking
	while still providing synchronous-like behavior.
]]
function SyncHandlerComponent.Invoke<T...>(self : SyncHandlerComponent<T...>,...) : ...any
	-- Get the current timeout setting
	local time_out = self._invokeTimeOut
	-- Track when we started the invocation attempt
	local elasped_time = time()
	-- Variable to store the handler's response
	local value
	-- Capture the arguments to pass to the handler
	local args = ...
	-- Keep trying to invoke until we get a response or timeout
	repeat
		-- Use task.defer to attempt invocation without blocking
		task.defer(function()
			-- Check if we've already timed out
			if(elasped_time >= time_out) then return end
			-- Attempt to invoke the BindableFunction
			-- This will call the registered OnInvoke handler
			value = self._object:Invoke(args)
		end)
		-- Update elapsed time
		elasped_time = time()
		-- Yield briefly to allow other code to run
		task.wait()
		-- Continue until we get a value or exceed the timeout
	until value ~= nil or elasped_time >= time_out
	-- Check if we timed out
	if(elasped_time >= time_out) then
		-- Log a detailed warning about the timeout
		warn("SyncHandler '" .. self._object.Name .. "' invoke operation timed out after " .. time_out .. " seconds. No response received from handler.")
		return nil
	end
	-- Return the handler's response
	return value
end

--[[
	Sets the timeout duration for invoke operations
	
	@param timeout - The new timeout duration in seconds
	
	This allows you to adjust how long Invoke will wait for a response before
	giving up. Shorter timeouts can prevent long waits but may cause legitimate
	operations to fail. Longer timeouts are more forgiving but can cause delays
	when handlers are unresponsive.
]]
function SyncHandlerComponent.SetTimeout<T...>(self : SyncHandlerComponent<T...>,timeout : number)
	-- Validate that timeout is a number
	assert(type(timeout) == "number", "SetTimeout() expects a number for the 'timeout' parameter, but received " .. type(timeout))
	-- Update the timeout value
	self._invokeTimeOut = timeout	
end

--[[
	Completely destroys the handler and cleans up all resources
	
	This method should be called when the handler is no longer needed. It:
	1. Disconnects any registered handler function
	2. Destroys the underlying BindableFunction
	3. Clears all internal references
	4. Removes metatable connections
	
	After calling Destroy(), this handler instance should not be used again.
]]
function SyncHandlerComponent.Destroy<T...>(self : SyncHandlerComponent<T...>) : ()
	-- If a handler is connected, clean it up first
	if(self._thread._connected) then
		-- Clear the BindableFunction's OnInvoke
		self._object.OnInvoke = nil :: any
		-- Clear internal references
		self._fn = false :: any
		self._thread._connected = false
		self._thread._handler = false
	end
	-- Note: We don't remove from SyncRegistery here because the handler
	-- might be destroyed while other scripts still hold references to it
	-- The registry entry will be overwritten if a new handler is created with the same name
	-- Destroy the underlying BindableFunction
	self._object:Destroy()
	-- Clear the table to aid garbage collection
	table.clear(self)
	-- Remove the metatable
	setmetatable(self,nil)
	-- Nil out the reference (only affects local variable)
	self = nil :: any
end

-- Method aliases for different naming conventions
-- These provide flexibility for users with different coding style preferences

-- Lowercase aliases
SyncHandlerComponent.setTimeout = SyncHandlerComponent.SetTimeout
SyncHandlerComponent.SetTimeOut = SyncHandlerComponent.SetTimeout  -- Alternative capitalization
SyncHandlerComponent.onInvoke = SyncHandlerComponent.OnInvoke
SyncHandlerComponent.invoke = SyncHandlerComponent.Invoke
SyncHandlerComponent.destroy = SyncHandlerComponent.Destroy

-- Constructor aliases for different naming preferences
SyncHandlerConstructor.New = SyncHandlerConstructor.new      -- Capital 'N' variant
SyncHandlerConstructor.from = SyncHandlerConstructor.new     -- Lowercase 'from' pattern
SyncHandlerConstructor.From = SyncHandlerConstructor.new     -- Capitalized 'From' pattern

-- Return the constructor so users can create new handlers
return SyncHandlerConstructor
