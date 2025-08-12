--!strict
--!native

--[[
	author : evxry_ll
	
	Enum Module V1.0.0
	
	This module provides a system for creating and managing enums in Lua/Luau.
	Enums are useful for creating named constants that represent specific values,
	making code more readable and maintainable.
	
	Features:
	- Create enums with string keys and numeric values
	- Automatic value assignment based on order
	- Enum caching to prevent duplicate creation
	- Type-safe enum access
	- Frozen enums to prevent modification
]]

-- Type definition for individual enum values
-- Each enum value contains:
-- - Value: The numeric value (auto-assigned based on position)
-- - Name: The string name of the enum item
-- - EnumType: The name of the enum this item belongs to
export type EnumIndex<Name = string> = {
	Value : number,
	Name : string,
	EnumType : Name,
}

-- Static registry to store all created enums
-- This prevents duplicate enum creation and allows enum retrieval by name
local EnumList = {} :: {[string] : any}

-- Constructor table for the Enum module
local EnumConstructor = {}
EnumConstructor.__index = EnumConstructor

--[[
	Creates a new enum with the given name and items.
	
	If an enum with the same name already exists, returns the existing enum.
	Otherwise, creates a new enum with auto-assigned numeric values.
	
	@param EnumName The unique name for this enum
	@param items Array of string keys for the enum values
	@return A frozen table mapping keys to EnumIndex objects
	
	Example:
		local Colors = EnumConstructor.new("Colors", {"Red", "Green", "Blue"})
		-- Colors.Red = {Value = 1, Name = "Red", EnumType = "Colors"}
]]
function EnumConstructor.new<Name,Keys>(EnumName : Name,items : {Keys}) : {[string] : EnumIndex<Name>}
	-- Validate that EnumName is a string
	assert(type(EnumName) == "string","EnumName must be a string.")
	-- Check if enum already exists to prevent duplicates
	if(EnumList[EnumName]) then
		return EnumList[EnumName]
	else
		-- Create new enum table
		local enum = {} :: {[string] : EnumIndex<Name>}
		-- Iterate through items and create enum values
		for i,v in pairs(items) do
			-- Skip non-string values with warning
			if(type(v) ~= "string") then
				warn(("%s is not a string, skipped"):format(type(v)))
				continue	
			end
			-- Create enum index entry with auto-assigned value
			enum[v] = {
				Value = i,           -- Numeric value based on position
				Name = v,            -- String name of the enum item
				EnumType = EnumName, -- Reference to parent enum
			} :: EnumIndex<Name>
		end
		-- Store enum in registry
		EnumList[EnumName] = enum
	end
	-- Return a frozen clone to prevent modification
	return table.freeze(table.clone(EnumList[EnumName]))
end

--[[
	Retrieves an existing enum by name from the registry.
	
	@param EnumName The name of the enum to retrieve
	@return A frozen copy of the enum table
	@error Throws if the enum doesn't exist
	
	Example:
		local Colors = EnumConstructor.from("Colors")
]]
function EnumConstructor.from<Name>(EnumName : Name) : {[string] : EnumIndex<Name>}
	-- Validate that EnumName is a string
	assert(type(EnumName) == "string","EnumName must be a string.")
	-- Check if enum exists
	if(not EnumList[EnumName]) then
		error(("%s is not found in EnumList"):format(tostring(EnumName)))
	end
	-- Return a frozen clone to prevent modification
	return table.freeze(table.clone(EnumList[EnumName]))
end

--[[
	Removes an enum from the registry.
	
	This clears the enum table and removes it from the registry,
	allowing a new enum with the same name to be created.
	
	@param EnumName The name of the enum to remove
	
	Example:
		EnumConstructor.RemoveEnum("Colors")
]]
function EnumConstructor.RemoveEnum<Name>(EnumName : Name)
	-- Validate that EnumName is a string
	assert(type(EnumName) == "string","EnumName must be a string.")
	-- Exit early if enum doesn't exist
	if(not EnumList[EnumName]) then return end
	-- Clear the enum table and remove from registry
	table.clear(EnumList[EnumName])
	EnumList[EnumName] = nil
end

-- Alias for backward compatibility or alternative naming preference
-- GetEnumItems provides the same functionality as 'from'
EnumConstructor.GetEnumItems = EnumConstructor.from

-- Export the constructor table
return EnumConstructor
