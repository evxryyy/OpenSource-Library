--[[
	This script demonstrates the usage of the Enum module.
	It imports required modules and creates a sample enum.
]]

-- Get reference to ReplicatedStorage service where modules are stored
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Import the main Enum module that provides enum creation functionality
local EnumModule = require(ReplicatedStorage.Enum.Enum)

-- Import the EnumType module that contains type definitions for enums
local EnumType = require(ReplicatedStorage.Enum.EnumType)

--[[
	Creates a new enum called "Hello-World" with three values: A, B, and C
	
	The type casting :: {EnumType.HelloKeys} ensures type safety by specifying
	that the items array should match the HelloKeys type definition.
	
	The final type cast :: EnumType.HelloEnum<"Hello"> ensures the returned
	enum matches the expected HelloEnum type structure.
	
	This creates an enum where:
	- HelloEnum.A = {Value = 1, Name = "A", EnumType = "Hello-World"}
	- HelloEnum.B = {Value = 2, Name = "B", EnumType = "Hello-World"}
	- HelloEnum.C = {Value = 3, Name = "C", EnumType = "Hello-World"}
]]
local HelloEnum = EnumModule.new("Hello-World",{"A","B","C"} :: {EnumType.HelloKeys}) :: EnumType.HelloEnum<"Hello">
