--[[
	@Dummy
	UserInput.
	
	advanced way to control user input like InputContext but use UserInputService instead of Instance
	if you want to learn more you will probably need to see the Input Framework from sleitnick
	
	local Input = UserInput.new({
		Keys = {Enum.KeyCode.A,Enum.KeyCode.B}
		InputType = "Keyboard" or "Gamepad" -- This will allow you to swap at any moment during runTime
	})
	
	Input:Pressed:Connect(function(key : KeyCode)
		print(key) -- -> print the actual pressed key
	end)
	
	Some signal exist but i recommend to use .Pressed and .Released for your own functions
	
	API:
		__PUBLIC__
		.KeysRegistered : {ArrayOfKeyCode} -> this is the actual table of all the keys registered
		.ChangeInputType : ("Gamepad" | "Keyboard") -> change the input type at runtime (keys are also cleared during this call)
		.AddKey : (keys : {Enum.KeyCode}) -> add a key at runtime (if key are already here they will not be added)
		.RemoveKey : (keys : {Enum.KeyCode}) -> remove a key at runtime
		.Pressed : (callback : (key : Enum.KeyCode) -> ()) -> Signal.Connection (callback is called each time a correct key is pressed)
		.Released : (callback : (key : Enum.KeyCode) -> ()) -> Signal.Connection (callback is called each time a correct key is released)
		.DisconnectPressed() -> Disconnect the pressed signal
		.DisconnectReleased() -> Disconnect the released signal
		.Destroy() -> Destroy Signals and everything related to the Input
		__PRIVATE__
		.KeyPressed : Signal<key : KeyCode> -> the signal that fire each time a correct key is pressed
		.KeyReleased : Signal<key : KeyCode> -> the signal that fire each time a correct key is released
		.__setUpInputStructKeyPressed() -> automaticly called to init the input pressed capture DO NOT CALL THIS FUNCTION
		.__setUpInputStructKeyReleased() -> automaticly called to init the input released capture DO NOT CALL THIS FUNCTION
		.inputStruct :  GamepadStruct | KeyboardStruct -> determinate wich input is used (see Input Framework from sleitnick)
]]

export type UserInputComponent = {
	inputStruct :  GamepadStruct | KeyboardStruct;
	KeysRegistered : {Enum.KeyCode};
	KeyPressed : SignalStruct;
	KeyReleased : SignalStruct;
	__setUpInputStructKeyPressed : (self : UserInputComponent) -> ();
	__setUpInputStructKeyReleased : (self : UserInputComponent) -> ();
	Pressed : (self : UserInputComponent,callback : (key : Enum.KeyCode) -> ()) -> SignalConnectionStruct;
	Released : (self : UserInputComponent,callback : (key : Enum.KeyCode) -> ()) -> SignalConnectionStruct;
	ChangeInputType : (self : UserInputComponent,InputType : "Gamepad" | "Keyboard") -> ();
	ChangeKey : (self : UserInputComponent,keys : {Enum.KeyCode}) -> (),
	AddKey : (self : UserInputComponent,keys : {Enum.KeyCode}) -> (),
	RemoveKey : (self : UserInputComponent,keys : {Enum.KeyCode}) -> (),
	DisconnectPressed : (self : UserInputComponent) -> ();
	DisconnectReleased : (self : UserInputComponent) -> ();
	Destroy : (self : UserInputComponent) -> ();
}

--Type annotation for Input.new(config)
export type UserInputConfiguration = {
	Keys : {Enum.KeyCode},
	InputType : "Gamepad" | "Keyboard",
}

local UserInputService = game:GetService("UserInputService")

--require module using path
local Signal = require("@self/Signal")
local Input = require("@self/Input")

local Keyboard = Input.Keyboard
local Gamepad = Input.Gamepad

--Annotation type from other modules
type SignalConnectionStruct = Signal.Connection
type SignalStruct = Signal.Signal<Enum.KeyCode>
type GamepadStruct = Input.GamepadType
type KeyboardStruct = Input.KeyboardType

--Check if the current config is correct
local function configGuard(config : UserInputConfiguration) : boolean
	if(not config) then return false end
	if(not config.Keys or not config.InputType) then return false end
	return true
end

--determine wich support to use.
local function inputGuard(config : UserInputConfiguration)
	if(config.InputType == "Gamepad") then return Gamepad.new() end
	if(config.InputType == "Keyboard") then return Keyboard.new() end
end

local UserInput = {}
UserInput.__index = UserInput

local Component = {}
Component.__index = Component

--Return a new UserInput Component
function UserInput.new(config : UserInputConfiguration) : UserInputComponent
	assert(configGuard(config),"config is not valid")
	local self = setmetatable({
		inputStruct = inputGuard(config);
		KeysRegistered = table.clone(config.Keys);
		KeyPressed = Signal.new();
		KeyReleased = Signal.new();
	},Component)
	self:__setUpInputStructKeyPressed()
	self:__setUpInputStructKeyReleased()
	return self
end

--Set up the input key pressed
function Component.__setUpInputStructKeyPressed(self : UserInputComponent)
	if(self.inputStruct.KeyDown) then
		return self.inputStruct.KeyDown:Connect(function(key: Enum.KeyCode, wasProcessed: boolean)
			if(wasProcessed) then return end
			if(not table.find(self.KeysRegistered,key)) then return end
			self.KeyPressed:Fire(key)
		end)
	elseif(self.inputStruct.ButtonDown) then
		return self.inputStruct.ButtonDown:Connect(function(keycode: Enum.KeyCode, processed: boolean) 
			if(processed) then return end
			if(not table.find(self.KeysRegistered,keycode)) then return end
			self.KeyPressed:Fire(keycode)
		end)
	end
end

--Set up the input key released
function Component.__setUpInputStructKeyReleased(self : UserInputComponent)
	if(self.inputStruct.KeyUp) then
		return self.inputStruct.KeyUp:Connect(function(key: Enum.KeyCode) 
			if(not table.find(self.KeysRegistered,key)) then return end
			self.KeyReleased:Fire(key)
		end)
	elseif(self.inputStruct.ButtonUp) then
		return self.inputStruct.ButtonUp:Connect(function(keycode: Enum.KeyCode) 
			if(not table.find(self.KeysRegistered,keycode)) then return end
			self.KeyReleased:Fire(keycode)
		end)
	end
end

--Signal events connect with given callback (.Pressed)
function Component.Pressed(self : UserInputComponent,callback : (key : Enum.KeyCode) -> ())
	return self.KeyPressed:Connect(callback)
end

--Signal events connect with given callback (.Released)
function Component.Released(self : UserInputComponent,callback : (key : Enum.KeyCode) -> ())
	return self.KeyPressed:Connect(callback)
end

--Change the actual InputType (see API)
function Component.ChangeInputType(self : UserInputComponent,InputType : "Gamepad" | "Keyboard")
	self:ChangeKey({})
	self.inputStruct:Destroy()
	self.inputStruct = inputGuard({InputType = InputType,Keys = {}});
	self:__setUpInputStructKeyPressed()
	self:__setUpInputStructKeyReleased()
end

--Replace all keys with new ones.
function Component.ChangeKey(self : UserInputComponent,Keys : {Enum.KeyCode})
	if(not Keys) then return end
	table.clear(self.KeysRegistered)
	local keyChanged = table.clone(Keys)
	for i,key in pairs(keyChanged) do
		table.insert(self.KeysRegistered,key)
	end
end

--Add new keys to the existing keys
function Component.AddKey(self : UserInputComponent,Keys : {Enum.KeyCode})
	if(not Keys) then return end
	for i,key in pairs(Keys) do
		if(table.find(self.KeysRegistered,key)) then continue end
		table.insert(self.KeysRegistered,key)
	end
end

--Remove keys from the existing keys
function Component.RemoveKey(self : UserInputComponent,Keys : {Enum.KeyCode})
	if(not Keys) then return end
	for i,key in pairs(Keys) do
		if(not table.find(self.KeysRegistered,key)) then continue end
		table.remove(self.KeysRegistered,table.find(self.KeysRegistered,key))
	end
end

--Disconnect .KeyPressed signal
function Component.DisconnectPressed(self : UserInputComponent)
	self.KeyPressed:DisconnectAll()
end

--Disconnect .KeyReleased signal
function Component.DisconnectReleased(self : UserInputComponent)
	self.KeyReleased:DisconnectAll()
end

--Destroy the actual UserInput Component
function Component.Destroy(self : UserInputComponent)
	self.KeyPressed:Destroy()
	self.KeyReleased:Destroy()
	self.inputStruct:Destroy()
	self.RemoveKey(self,self.KeysRegistered)
end

return UserInput
