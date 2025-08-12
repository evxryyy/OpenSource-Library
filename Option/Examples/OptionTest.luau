--[[
	This script demonstrates the usage of the Option module,
	specifically showing how to chain operations using AndThen.
]]

-- Get reference to ReplicatedStorage service
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Get reference to the OpenEvxEngine folder within ReplicatedStorage
local openEvxEngine = ReplicatedStorage.OpenEvxEngine

-- Import the Option module which provides safe nullable value handling
local Option = require(openEvxEngine.Option)

--[[
	Create an Option containing a string value "PlayerName"
	This creates a Some variant of Option<string>
	
	At this point:
	- data.Tag = "Some"
	- data.Some = "PlayerName"
]]
local data = Option.Some("PlayerName")

--[[
	Use AndThen to chain an operation that transforms the Option's value
	
	AndThen only executes the callback if the Option is Some (contains a value)
	If the Option was None, it would return None without executing the callback
	
	The callback:
	1. Receives the string value "PlayerName"
	2. Calculates its length (10 characters)
	3. Wraps the length in a new Option using Option.Some
	
	This transforms Option<string> into Option<number>
]]
local convertDataIntoNumber = data:AndThen(function(value)
	-- Calculate the length of the string
	local len = string.len(value)  -- len = 10 (length of "PlayerName")

	-- Return a new Option containing the length
	-- AndThen requires the callback to return an Option
	return Option.Some(len)
end)

--[[
	At this point:
	- convertDataIntoNumber is an Option<number>
	- convertDataIntoNumber.Tag = "Some"
	- convertDataIntoNumber.Some = 10
	
	The comment indicates the type: convertDataIntoNumber.Some :: number
]]

-- Print the unwrapped value (10)
-- Note: This directly accesses .Some which could be nil if the Option was None
-- A safer approach would be to use :UnWrap() or :GetOr()
print(convertDataIntoNumber.Some)  -- Output: 10
