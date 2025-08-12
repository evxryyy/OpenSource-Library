--[[
	EnumType Module
	
	This module contains type definitions used by the Enum module.
	It provides type safety for enum creation and usage.
	
	To add a new enum type:
	1. Define a Keys type with all possible enum values
	2. Define an Enum type with the structure mapping keys to EnumIndex
]]

-- Base type for individual enum values
-- This matches the type defined in the main Enum module
type EnumIndex<Name = string> = {
	Value : number,      -- The numeric value of the enum item
	Name : string,       -- The string name of the enum item
	EnumType : string    -- The name of the enum this item belongs to
}

-- Example enum type definitions
-- These demonstrate how to create type-safe enum definitions

-- HelloKeys defines the allowed string values for the Hello enum
-- Using a union type ensures only these specific strings can be used
export type HelloKeys = "A" | "B" | "C"

-- HelloEnum defines the structure of the Hello enum
-- It maps each key to an EnumIndex with the appropriate enum name
-- The generic parameter EnumName allows flexibility in the enum type name
export type HelloEnum<EnumName = string> = {
	A: EnumIndex<EnumName>,  -- Enum item A
	B: EnumIndex<EnumName>,  -- Enum item B
	C: EnumIndex<EnumName>,  -- Enum item C
}

-- Return nil as this is a type definition module
-- The module is imported only for its type exports
return nil
