--[[
	ModuleLoader.luau

	author : evxry_ll

	ModuleLoader is a module that loads all ModuleScripts in a given folder and its subfolders.
	
	Each ModuleScript must return a table with the following functions:
		1. Init: (self) -> () --> Called when the module is initialized
		2. Start: (self) -> () --> Called when the module is started
		3. Cleaning: (self) -> () --> Called when the module is cleaned (Optional)

	You can set the priority of each module by adding a number to the ModuleScript attribute
		e.g : ModuleScript:SetAttribute("Priority",PRIORITY_NUMBER) or directly set from the children
	Modules with a higher priority will be started before modules with a lower priority
	Modules with the same priority will be started in the order they were loaded

	Settings:
		SHOW_DEBUG_PRINT : boolean --> true = show prints
		USE_DESCENDANT : boolean --> true = use :GetDescendants() to get all modules, false = only use :GetChildren()
	
	call .SetSettings(customSettings : Settings) before starting the module loader.
	ModuleLoader.SetSettings({SHOW_DEBUG_PRINT = false, USE_DESCENDANT = true})
]]

local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")

--static start variable
local started = false

--static loaded module variable
local loaded_module = {} :: Registery

--Debug print
local SERVER_PRINT = "[S] --> %s"
local CLIENT_PRINT = "[C] --> %s"

--Settings
--SHOW_DEBUG_PRINT --> true = show print
--USE_DESCENDANT -> true = use :GetDescendants() to get all modules, false = only use :GetChildren()
local SETTINGS = {
	SHOW_DEBUG_PRINT = true,
	USE_DESCENDANT = true,
} :: Settings

export type RegisteryIndex = {instance : ModuleScript,module : ModuleLoaderComponent,priority : number}
export type Registery = {[string] : {RegisteryIndex}}

export type Settings = {
	SHOW_DEBUG_PRINT : boolean,
	USE_DESCENDANT : boolean,	
}

export type ModuleLoader = {
	Load : (descendant : Instance) -> (),
	Start : () -> (),
	SetSettings : (customSettings : Settings) -> (),
	Each : (callback : (Module : ModuleScript) -> boolean) -> (),
	Clear : () -> (),
	Find : (ModulePath : ModuleScript | string) -> RegisteryIndex?,
	WaitUntilStarted : () -> number,
	IsStarted : () -> boolean,
	Stop : () -> (),
}

export type ModuleLoaderComponent = {
	Init : (...any)  -> (),
	Start : (...any)  -> (),
	Cleaning : (...any) -> (),
}


local ModuleLoader = {}
ModuleLoader.__index = ModuleLoader

--init all module and register the current one in the registery
local function initTargetModule(descendant : Instance,settings : Settings)
	if(settings.USE_DESCENDANT) then
		for i,module in pairs(descendant:GetDescendants()) do
			if(module:IsA("ModuleScript")) then
				table.insert(loaded_module,{
					instance = module,
					module = require(module),
					priority = module:GetAttribute("Priority") or 1
				} :: Registery)
			else
				ModuleLoader.Load(module)
				continue
			end
		end 
	else
		for i,module in pairs(descendant:GetChildren()) do
			if(module:IsA("ModuleScript")) then
				table.insert(loaded_module,{
					instance = module,
					module = require(module),
					priority = module:GetAttribute("Priority") or 1
				} :: Registery)
			else
				ModuleLoader.Load(module)
				continue
			end
		end 
	end
end

--sort all module depending on the priority attribute
local function sortRegistery()
	table.sort(loaded_module,function(a : RegisteryIndex,b : RegisteryIndex)
		return a.priority > b.priority
	end)
end

--[[
	Load all module from the descendant
    you can call that multiple times for loading different files.
   	please call this before :Start() or :Each()
--]]
function ModuleLoader.Load(descendant : Instance) : ()
	if(RunService:IsServer()) then
		if(SETTINGS.SHOW_DEBUG_PRINT) then
			warn((SERVER_PRINT):format(`Loading all modules`))
		end
		initTargetModule(descendant,SETTINGS)
		sortRegistery()
		if(SETTINGS.SHOW_DEBUG_PRINT) then
			warn((SERVER_PRINT):format(`Loaded all modules and sorted correctly.`))
		end
	else
		if(SETTINGS.SHOW_DEBUG_PRINT) then
			warn((CLIENT_PRINT):format(`Loading all modules`))
		end
		initTargetModule(descendant,SETTINGS)
		sortRegistery()
		if(SETTINGS.SHOW_DEBUG_PRINT) then
			warn((CLIENT_PRINT):format(`Loaded all modules and sorted correctly.`))
		end
	end
end

--[[
	Start all loaded module
	Each loaded module should have these callback
	:Init() -> called once when the module is loaded
	:Start() -> called when the module is initialized
	Do not YIELD these functions.
]]
function ModuleLoader.Start()
	assert(not started,"You can't start more than once the module loader.")
	if(RunService:IsServer()) then
		for i,registeryIndex : RegisteryIndex in pairs(loaded_module) do
			if(SETTINGS.SHOW_DEBUG_PRINT) then
				print((SERVER_PRINT):format(`Initializing module : "{registeryIndex.instance.Name}"`))
				registeryIndex.module:Init()
				print((SERVER_PRINT):format(`Initialized module : "{registeryIndex.instance.Name}"`))
				print((SERVER_PRINT):format(`Starting module {registeryIndex.instance.Name}`))
				registeryIndex.module:Start()
				print((SERVER_PRINT):format(`Started module {registeryIndex.instance.Name}`))
			else
				registeryIndex.module:Init()
				registeryIndex.module:Start()
			end
		end
		started = true
	else
		for i,registeryIndex : RegisteryIndex in pairs(loaded_module) do
			if(SETTINGS.SHOW_DEBUG_PRINT) then
				print((CLIENT_PRINT):format(`Initializing module : "{registeryIndex.instance.Name}"`))
				registeryIndex.module:Init()
				print((CLIENT_PRINT):format(`Initialized module : "{registeryIndex.instance.Name}"`))
				print((CLIENT_PRINT):format(`Starting module {registeryIndex.instance.Name}`))
				registeryIndex.module:Start()
				print((CLIENT_PRINT):format(`Started module {registeryIndex.instance.Name}`))
			else
				registeryIndex.module:Init()
				registeryIndex.module:Start()
			end
		end
		started = true
	end
end

--[[
	Loop through all loaded module and call the callback for each module
	if the callback return true, then initialize and start the module otherwise it skip it
	You can yield this function.
]]
function ModuleLoader.Each(callback : (module : ModuleScript) -> boolean)
	assert(not started,"You can't start more than once the module loader.")
	if(RunService:IsServer()) then
		for i,registeryIndex : RegisteryIndex in pairs(loaded_module) do
			local result = callback(registeryIndex.instance)
			if(not result) then continue end
			if(SETTINGS.SHOW_DEBUG_PRINT) then
				print((SERVER_PRINT):format(`Initializing module : "{registeryIndex.instance.Name}"`))
			end
			registeryIndex.module:Init()
			if(SETTINGS.SHOW_DEBUG_PRINT) then
				print((SERVER_PRINT):format(`Initialized module : "{registeryIndex.instance.Name}"`))
				print((SERVER_PRINT):format(`Starting module : "{registeryIndex.instance.Name}"`))
			end
			registeryIndex.module:Start()
			if(SETTINGS.SHOW_DEBUG_PRINT) then
				print((SERVER_PRINT):format(`Started module : "{registeryIndex.instance.Name}"`))
			end
		end
		started = true
	else
		for i,registeryIndex : RegisteryIndex in pairs(loaded_module) do
			local result = callback(registeryIndex.instance)
			if(not result) then continue end
			if(SETTINGS.SHOW_DEBUG_PRINT) then
				print((CLIENT_PRINT):format(`Initializing module : "{registeryIndex.instance.Name}`))
			end
			registeryIndex.module:Init()
			if(SETTINGS.SHOW_DEBUG_PRINT) then
				print((CLIENT_PRINT):format(`Initialized module : "{registeryIndex.instance.Name}"`))
				print((CLIENT_PRINT):format(`Starting module : "{registeryIndex.instance.Name}"`))
			end
			registeryIndex.module:Start()
			if(SETTINGS.SHOW_DEBUG_PRINT) then
				print((CLIENT_PRINT):format(`Started module : "{registeryIndex.instance.Name}"`))
			end
		end
		started = true
	end
end

--[[
	Assign new settings to the module loader settings
	You can't change the settings after the first start
]]
function ModuleLoader.SetSettings(customSettings : Settings)
	SETTINGS = customSettings
end

--[[
	Clear every module if the module has a Cleaning function it will call it
	please note that after every registered module is cleaned and it will no longer be used.
]]
function ModuleLoader.Clear()
	if(RunService:IsServer()) then
		for i,registeryIndex : RegisteryIndex in pairs(loaded_module) do
			if(registeryIndex.module.Cleaning) then
				if(SETTINGS.SHOW_DEBUG_PRINT) then
					print((SERVER_PRINT):format(`Cleaning module : "{registeryIndex.instance.Name}"`))
				end
				registeryIndex.module:Cleaning()
				if(SETTINGS.SHOW_DEBUG_PRINT) then
					print((SERVER_PRINT):format(`Cleaned module : "{registeryIndex.instance.Name}"`))
				end
			end
		end
	else
		for i,registeryIndex : RegisteryIndex in pairs(loaded_module) do
			if(registeryIndex.module.Cleaning) then
				if(SETTINGS.SHOW_DEBUG_PRINT) then
					print((CLIENT_PRINT):format(`Cleaning module : "{registeryIndex.instance.Name}"`))
				end
				registeryIndex.module:Cleaning()
				if(SETTINGS.SHOW_DEBUG_PRINT) then
					print((CLIENT_PRINT):format(`Cleaned module : "{registeryIndex.instance.Name}"`))
				end
			end
		end
	end
	table.clear(loaded_module)
end

--[[
	Stop the current module Loader and you will be able to start it again
	please note that it call .Clear() (see Clear callback for more info)
	You can't start it again if the module loader is already started
]]
function ModuleLoader.Stop()
	ModuleLoader.Clear()
	started = false
end

--[[
	Find the loaded module from the Instance or from the name
]]
function ModuleLoader.Find(ModulePath : ModuleScript | string)
	for i,registeryIndex : RegisteryIndex in pairs(loaded_module) do
		if(type(ModulePath) == "string") then
			if(registeryIndex.instance.Name == ModulePath) then
				return registeryIndex
			end
		else
			if(registeryIndex.instance == ModulePath) then
				return registeryIndex
			end
		end
	end
end

--[[
	Yield until the module loader is started
	You can use it to make sure that the module loader is started before using it
	this also return the ammount of seconds passed since the start
]]
function ModuleLoader.WaitUntilStarted()
	local secondsPassed = tick()
	repeat
		task.wait()
	until started == true
	return tick() - secondsPassed
end

--[[
	Return true if the module loader is started
	You can use it to check if the module loader is started
]]
function ModuleLoader.IsStarted()
	return started
end

--Constructor alias
ModuleLoader.load = ModuleLoader.Load
ModuleLoader.start = ModuleLoader.Start
ModuleLoader.setSettings = ModuleLoader.SetSettings
ModuleLoader.each = ModuleLoader.Each
ModuleLoader.clear = ModuleLoader.Clear
ModuleLoader.find = ModuleLoader.Find
ModuleLoader.waitUntilStarted = ModuleLoader.WaitUntilStarted
ModuleLoader.isStarted = ModuleLoader.IsStarted
ModuleLoader.stop = ModuleLoader.Stop

return ModuleLoader :: ModuleLoader
