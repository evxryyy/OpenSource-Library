--[[
	author : evxry_ll

	UserInput Component Module
	
	This module provides a unified interface for handling user input from both keyboard and gamepad.
	It abstracts the differences between input types and provides a consistent API for detecting
	key/button presses and releases.
	
	Main features:
	- Support for both Keyboard and Gamepad input types
	- Dynamic input type switching
	- Key registration system to filter which keys trigger events
	- Signal-based event system for key press/release events
	- Input type observation to detect when user switches between input methods
]]

-- Type definition for the UserInput component instance
-- This defines all properties and methods available on a UserInput object
export type UserInputComponent = {
	-- The underlying input handler (either GamepadStruct or KeyboardStruct)
	inputStruct :  GamepadStruct | KeyboardStruct;
	-- Array of KeyCodes that this component will respond to
	KeysRegistered : {Enum.KeyCode};
	-- Signal that fires when a registered key is pressed
	KeyPressed : SignalStruct;
	-- Signal that fires when a registered key is released
	KeyReleased : SignalStruct;
	-- Function reference for the input type observer (used for cleanup)
	InputObserver : () -> ()?;
	-- Internal method to set up key press detection
	__setUpInputStructKeyPressed : (self : UserInputComponent) -> ();
	-- Internal method to set up key release detection
	__setUpInputStructKeyReleased : (self : UserInputComponent) -> ();
	-- Connect a callback function to the key pressed event
	Pressed : (self : UserInputComponent,callback : (key : Enum.KeyCode) -> ()) -> SignalConnectionStruct;
	-- Connect a callback function to the key released event
	Released : (self : UserInputComponent,callback : (key : Enum.KeyCode) -> ()) -> SignalConnectionStruct;
	-- Switch between Gamepad and Keyboard input types
	ChangeInputType : (self : UserInputComponent,InputType : "Gamepad" | "Keyboard") -> ();
	-- Observe changes in the user's preferred input method
	Observe : (self : UserInputComponent,callback : (InputType : "Gamepad" | "MouseKeyboard" | "Touch") -> ()) -> () -> (),
	-- Replace all registered keys with a new set
	ChangeKey : (self : UserInputComponent,keys : {Enum.KeyCode}) -> (),
	-- Add additional keys to the registered set
	AddKey : (self : UserInputComponent,keys : {Enum.KeyCode}) -> (),
	-- Remove specific keys from the registered set
	RemoveKey : (self : UserInputComponent,keys : {Enum.KeyCode}) -> (),
	-- Disconnect all callbacks from the KeyPressed signal
	DisconnectPressed : (self : UserInputComponent) -> ();
	-- Disconnect all callbacks from the KeyReleased signal
	DisconnectReleased : (self : UserInputComponent) -> ();
	-- Clean up and destroy the component
	Destroy : (self : UserInputComponent) -> ();
}

-- Type annotation for the configuration object passed to UserInput.new()
export type UserInputConfiguration = {
	-- Array of KeyCodes that the component should respond to
	Keys : {Enum.KeyCode},
	-- Initial input type (either "Gamepad" or "Keyboard")
	InputType : "Gamepad" | "Keyboard",
}

-- Roblox service for handling user input
local UserInputService = game:GetService("UserInputService")

-- Import required modules using the @self path alias
local Signal = require("@self/_Signal")
local Input = require("@self/_Input")

-- Extract specific input handlers from the Input module
local Keyboard = Input.Keyboard
local Gamepad = Input.Gamepad
local PreferredInput = Input.PreferredInput

-- Import type annotations from other modules for type safety
type SignalConnectionStruct = Signal.SignalConnection
type SignalStruct = Signal.Signal<Enum.KeyCode>
type GamepadStruct = Input.GamepadType
type KeyboardStruct = Input.KeyboardType

-- Validates that the configuration object has all required fields
-- Returns true if config is valid, false otherwise
local function configGuard(config : UserInputConfiguration) : boolean
	-- Check if config exists
	if(not config) then return false end
	-- Check if both required fields are present
	if(not config.Keys or not config.InputType) then return false end
	return true
end

-- Factory function that creates the appropriate input handler based on InputType
-- Returns either a new Gamepad or Keyboard instance
local function inputGuard(config : UserInputConfiguration)
	if(config.InputType == "Gamepad") then return Gamepad.new() end
	if(config.InputType == "Keyboard") then return Keyboard.new() end
end

-- Main module table
local UserInput = {}
UserInput.__index = UserInput

-- Component metatable for instance methods
local Component = {}
Component.__index = Component

-- Constructor function that creates a new UserInput component
-- @param config: Configuration object specifying Keys and InputType
-- @return: A new UserInputComponent instance
function UserInput.new(config : UserInputConfiguration) : UserInputComponent
	-- Validate configuration
	assert(configGuard(config),"config is not valid")
	-- Create the component instance with initial properties
	local self = setmetatable({
		-- Create the appropriate input handler (Gamepad or Keyboard)
		inputStruct = inputGuard(config);
		-- Clone the keys array to prevent external modifications
		KeysRegistered = table.clone(config.Keys);
		-- Create signals for key press/release events
		KeyPressed = Signal.new();
		KeyReleased = Signal.new();
		-- Initialize InputObserver as false (will be set when Observe is called)
		InputObserver = false,
	},Component)
	-- Set up event listeners for key press and release
	self:__setUpInputStructKeyPressed()
	self:__setUpInputStructKeyReleased()
	return self
end

-- Internal method that sets up the key press detection
-- Connects to the appropriate event based on input type (KeyDown for Keyboard, ButtonDown for Gamepad)
function Component.__setUpInputStructKeyPressed(self : UserInputComponent)
	-- Handle Keyboard input
	if(self.inputStruct.KeyDown) then
		return self.inputStruct.KeyDown:Connect(function(key: Enum.KeyCode, wasProcessed: boolean)
			-- Ignore input that was already processed by GUI elements
			if(wasProcessed) then return end
			-- Only fire event if the key is registered
			if(not table.find(self.KeysRegistered,key)) then return end
			-- Fire the KeyPressed signal with the key that was pressed
			self.KeyPressed:Fire(key)
		end)
		-- Handle Gamepad input
	elseif(self.inputStruct.ButtonDown) then
		return self.inputStruct.ButtonDown:Connect(function(keycode: Enum.KeyCode, processed: boolean) 
			-- Ignore processed input
			if(processed) then return end
			-- Only fire event if the button is registered
			if(not table.find(self.KeysRegistered,keycode)) then return end
			-- Fire the KeyPressed signal with the button that was pressed
			self.KeyPressed:Fire(keycode)
		end)
	end
end

-- Internal method that sets up the key release detection
-- Connects to the appropriate event based on input type (KeyUp for Keyboard, ButtonUp for Gamepad)
function Component.__setUpInputStructKeyReleased(self : UserInputComponent)
	-- Handle Keyboard input
	if(self.inputStruct.KeyUp) then
		return self.inputStruct.KeyUp:Connect(function(key: Enum.KeyCode) 
			-- Only fire event if the key is registered
			if(not table.find(self.KeysRegistered,key)) then return end
			-- Fire the KeyReleased signal with the key that was released
			self.KeyReleased:Fire(key)
		end)
		-- Handle Gamepad input
	elseif(self.inputStruct.ButtonUp) then
		return self.inputStruct.ButtonUp:Connect(function(keycode: Enum.KeyCode) 
			-- Only fire event if the button is registered
			if(not table.find(self.KeysRegistered,keycode)) then return end
			-- Fire the KeyReleased signal with the button that was released
			self.KeyReleased:Fire(keycode)
		end)
	end
end

-- Public method to connect a callback to the key pressed event
-- @param callback: Function that will be called when a registered key is pressed
-- @return: SignalConnection that can be used to disconnect the callback
function Component.Pressed(self : UserInputComponent,callback : (key : Enum.KeyCode) -> ()) : SignalConnectionStruct
	return self.KeyPressed:Connect(callback)
end

-- Public method to connect a callback to the key released event
-- @param callback: Function that will be called when a registered key is released
-- @return: SignalConnection that can be used to disconnect the callback
function Component.Released(self : UserInputComponent,callback : (key : Enum.KeyCode) -> ()) : SignalConnectionStruct
	return self.KeyReleased:Connect(callback)
end

-- Observe changes in the user's preferred input method
-- @param callback: Function called when input type changes (Gamepad, MouseKeyboard, or Touch)
-- @return: Cleanup function to stop observing
function Component.Observe(self : UserInputComponent,callback : (InputType : "Gamepad" | "MouseKeyboard" | "Touch") -> ()) : () -> ()
	-- Set up the observer and store the cleanup function
	self.InputObserver = PreferredInput.Observe(callback)
	return self.InputObserver :: () -> ()
end

-- Dynamically change the input type between Gamepad and Keyboard
-- This will clear all registered keys and recreate the input handlers
-- @param InputType: Either "Gamepad" or "Keyboard"
function Component.ChangeInputType(self : UserInputComponent,InputType : "Gamepad" | "Keyboard")
	-- Clear all registered keys
	self:ChangeKey({})
	-- Destroy the current input handler
	self.inputStruct:Destroy()
	-- Create a new input handler of the specified type
	self.inputStruct = inputGuard({InputType = InputType,Keys = {}});
	-- Reconnect the event handlers
	self:__setUpInputStructKeyPressed()
	self:__setUpInputStructKeyReleased()
end

-- Replace all currently registered keys with a new set
-- @param Keys: Array of KeyCodes to register
function Component.ChangeKey(self : UserInputComponent,Keys : {Enum.KeyCode})
	-- Guard against nil input
	if(not Keys) then return end
	-- Clear the current registered keys
	table.clear(self.KeysRegistered)
	-- Clone the new keys to prevent external modifications
	local keyChanged = table.clone(Keys)
	-- Add each key to the registered set
	for i,key in pairs(keyChanged) do
		table.insert(self.KeysRegistered,key)
	end
end

-- Add new keys to the existing registered set
-- Duplicate keys are automatically ignored
-- @param Keys: Array of KeyCodes to add
function Component.AddKey(self : UserInputComponent,Keys : {Enum.KeyCode})
	-- Guard against nil input
	if(not Keys) then return end
	-- Iterate through each key to add
	for i,key in pairs(Keys) do
		-- Skip if key is already registered
		if(table.find(self.KeysRegistered,key)) then continue end
		-- Add the key to the registered set
		table.insert(self.KeysRegistered,key)
	end
end

-- Remove specific keys from the registered set
-- @param Keys: Array of KeyCodes to remove
function Component.RemoveKey(self : UserInputComponent,Keys : {Enum.KeyCode})
	-- Guard against nil input
	if(not Keys) then return end
	-- Iterate through each key to remove
	for i,key in pairs(Keys) do
		-- Skip if key is not registered
		if(not table.find(self.KeysRegistered,key)) then continue end
		-- Remove the key from the registered set
		table.remove(self.KeysRegistered,table.find(self.KeysRegistered,key))
	end
end

-- Disconnect all callbacks connected to the KeyPressed signal
-- Useful for temporarily disabling key press detection
function Component.DisconnectPressed(self : UserInputComponent)
	self.KeyPressed:DisconnectAll()
end

-- Disconnect all callbacks connected to the KeyReleased signal
-- Useful for temporarily disabling key release detection
function Component.DisconnectReleased(self : UserInputComponent)
	self.KeyReleased:DisconnectAll()
end

-- Complete cleanup of the UserInput component
-- This should be called when the component is no longer needed
function Component.Destroy(self : UserInputComponent)
	-- Clean up the input observer if it exists
	if(self.InputObserver) then
		self.InputObserver() -- Call the cleanup function
		self.InputObserver = nil
	end
	-- Destroy both signals
	self.KeyPressed:Destroy()
	self.KeyReleased:Destroy()
	-- Destroy the input handler
	self.inputStruct:Destroy()
	-- Clear all registered keys
	self.RemoveKey(self,self.KeysRegistered)
end

--Constructor alias
UserInput.New = UserInput.new

--Component alias
Component.pressed = Component.Pressed
Component.released = Component.Released
Component.changeInputType = Component.ChangeInputType
Component.changeInputtype = Component.ChangeInputType
Component.addKey = Component.AddKey
Component.addkey = Component.AddKey
Component.removeKey = Component.RemoveKey
Component.removekey = Component.RemoveKey
Component.disconnectPressed = Component.DisconnectPressed
Component.disconnectpressed = Component.DisconnectPressed
Component.disconnectReleased = Component.DisconnectReleased
Component.disconecctreleased = Component.DisconnectReleased
Component.observe = Component.Observe


return UserInput
