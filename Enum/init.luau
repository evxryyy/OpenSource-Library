--!strict
--!native

--[[
	author : evxry_ll
	
	Enum Module V1.0.0
	Enum Module is a module that helps you create and manage enums.
]]

--EnumIndex is the actual enum value
export type EnumIndex<Name = string> = {
	Value : number,
	Name : string,
	EnumType : Name,
}

--static Enum Registery
local EnumList = {} :: {[string] : any}

local EnumConstructor = {}
EnumConstructor.__index = EnumConstructor

--[[
	Creates a new enum with the given name and items.
	param 1: EnumName string -- The name of the enum.
	param 2: items table -- A table containing the items of the enum.
	return table -- The created enum.
]]
function EnumConstructor.new<Name,Keys>(EnumName : Name,items : {Keys}) : {[string] : EnumIndex<Name>}
	assert(type(EnumName) == "string","EnumName must be a string.")
	if(EnumList[EnumName]) then
		return EnumList[EnumName]
	else
		local enum = {} :: {[string] : EnumIndex<Name>}
		for i,v in pairs(items) do
			if(type(v) ~= "string") then
				warn(("%s is not a string, skipped"):format(type(v)))
				continue	
			end
			enum[v] = {
				Value = i,
				Name = v,
				EnumType = EnumName,
			} :: EnumIndex<Name>
		end
		EnumList[EnumName] = enum
	end
	return table.freeze(table.clone(EnumList[EnumName]))
end

--Returns an enum with the given name.
function EnumConstructor.from<Name>(EnumName : Name) : {[string] : EnumIndex<Name>}
	assert(type(EnumName) == "string","EnumName must be a string.")
	if(not EnumList[EnumName]) then
		error(("%s is not found in EnumList"):format(tostring(EnumName)))
	end
	return table.freeze(table.clone(EnumList[EnumName]))
end

--Removes an enum with the given name.
function EnumConstructor.RemoveEnum<Name>(EnumName : Name)
	assert(type(EnumName) == "string","EnumName must be a string.")
	if(not EnumList[EnumName]) then return end
	table.clear(EnumList[EnumName])
	EnumList[EnumName] = nil
end

--alias for .from
EnumConstructor.GetEnumItems = EnumConstructor.from

return EnumConstructor
