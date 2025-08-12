--[[
	author : evxry_ll
	
	This module implements the Option type pattern, similar to Rust's Option<T>.
	It provides a way to handle nullable values in a type-safe manner.
	
	Option<T> can be either:
	- Some(value): Contains a value of type T
	- None: Contains no value
]]

-- Type aliases for better readability
type Some<T> = T
type None = () -> ()

-- Callback type definitions used throughout the module
type Callback<T> = () -> T                           -- Function that returns a value of type T
type MappedCallback<T> = (value : T) -> T           -- Function that transforms a value of type T
type FilterCallback<T> = (value : T) -> boolean     -- Function that tests if a value meets criteria
type AndThenCallback<T, K> = (value : T) -> any     -- Function that chains operations

-- Constructor table for creating Option instances
local OptionConstructor = {}
OptionConstructor.__index = OptionConstructor

-- Component table containing all Option methods
local OptionComponent = {}
OptionComponent.__index = OptionComponent

-- Export type definition for Option<T>
-- An Option can have either a "Some" tag with a value, or a "None" tag with nil
export type OptionComponent<T> = typeof(setmetatable({} :: {
	Tag : "Some" | "None",
	Some : T,
	None : nil,
},OptionComponent))

--[[
	Creates a Some variant of Option containing a value
	@param SomeOption The value to wrap in Some
	@return An Option containing the provided value
]]
function OptionConstructor.Some<SomeType>(SomeOption : Some<SomeType>) : OptionComponent<SomeType>
	local self = setmetatable({
		Some = SomeOption,
		Tag = "Some",
	},OptionComponent)
	return self
end

--[[
	Creates a None variant of Option containing no value
	@return An empty Option
]]
function OptionConstructor.None() : OptionComponent<nil>
	local self = setmetatable({
		None = true,
		Tag = "None"
	},OptionComponent)
	return self
end

--[[
	Checks if a value is a valid Option instance
	@param option The value to check
	@return true if the value is an Option, false otherwise
]]
function OptionConstructor.IsOption<T>(option : OptionComponent<T>?)
	if(option and option.Tag) then
		return true
	else
		return false
	end
end

--[[
	Wraps a nullable value in an Option
	If the value is nil, returns None; otherwise returns Some(value)
	@param value The nullable value to wrap
	@return Option<T> or Option<nil>
]]
function OptionConstructor.Wrap<T>(value : T?)
	if(value ~= nil) then
		return OptionConstructor.Some(value :: T) :: OptionComponent<T>
	else
		return OptionConstructor.None() :: OptionComponent<nil>
	end
end

--[[
	Deserializes data back into an Option
	Used to reconstruct Options from stored/transmitted data
	@param data Serialized Option data with Tag and Value fields
	@return The reconstructed Option
]]
function OptionConstructor.Deserialize<T>(data : {Tag : "Some" | "None",Value : T})
	return data.Value == nil and OptionConstructor.None() or OptionConstructor.Some(data.Value)
end

--[[
	Checks if this Option contains a value (is Some variant)
	@return true if Option contains a value, false if None
]]
function OptionComponent.IsSome<T>(self : OptionComponent<T>)
	return self.Tag == "Some" or self.Some ~= nil
end

--[[
	Checks if this Option is empty (is None variant)
	@return true if Option is None, false if it contains a value
]]
function OptionComponent.IsNone<T>(self : OptionComponent<T>)
	return self.Tag == "None" or self.None ~= nil
end

--[[
	Pattern matching for Option - executes different code based on variant
	@param Options Table with Some and None callbacks
	@return Result of the executed callback
]]
function OptionComponent.Match<T>(self : OptionComponent<T>,Options : {Some : (T) -> T,None : None,})
	if(self:IsNone()) then
		return Options.None()
	else
		return Options.Some(self.Some :: T)
	end
end

--[[
	Asserts that the Option contains a value, throwing error if None
	@param error_message Custom error message to display if assertion fails
]]
function OptionComponent.Assert<T>(self : OptionComponent<T>,error_message : string)
	assert(self:IsSome(),error_message)
end

--[[
	Returns the contained value or a default if None
	@param value Default value to return if Option is None
	@return The contained value or the default
]]
function OptionComponent.GetOr<T, K>(self : OptionComponent<T>,value : K) : T | K
	if(self:IsSome()) then
		return self.Some :: T
	else
		return value
	end
end

--[[
	Transforms the contained value using a callback function
	If None, returns None without calling the callback
	@param callback Function to transform the value
	@return New Option with transformed value or None
]]
function OptionComponent.Map<T>(self : OptionComponent<T>,callback : MappedCallback<T>)
	if(self:IsSome()) then
		return OptionConstructor.Some(callback(self.Some :: T))
	else
		return OptionConstructor.None()
	end
end

--[[
	Filters the Option based on a predicate function
	Returns None if the predicate returns false or if already None
	@param callback Predicate function to test the value
	@return Self if predicate passes, None otherwise
]]
function OptionComponent.Filter<T>(self : OptionComponent<T>,callback : FilterCallback<T>)
	if(self:IsSome() and callback(self.Some :: T)) then
		return self
	else
		return OptionConstructor.None()
	end
end

--[[
	Returns the contained value or computes a default using a callback
	@param callback Function to compute default value if None
	@return The contained value or computed default
]]
function OptionComponent.GetOrElse<T, K>(self : OptionComponent<T>,callback : Callback<K>) : T | K
	if(self:IsSome()) then
		return self.Some :: T
	else
		return callback()
	end
end

--[[
	Exclusive OR operation between two Options
	Returns Some if exactly one Option is Some, None if both are Some or both are None
	@param OptionB The other Option to XOR with
	@return Result of XOR operation
]]
function OptionComponent.XOR<T>(self : OptionComponent<T>,OptionB : OptionComponent<T>)
	local ValidOptionB = OptionConstructor.IsOption(OptionB)
	if(not ValidOptionB) then return self :: OptionComponent<T> end
	if(self:IsSome() and OptionB:IsSome()) then
		return OptionConstructor.None() :: OptionComponent<nil>
	elseif(self:IsSome()) then
		return self :: OptionComponent<T>
	else
		return OptionB :: OptionComponent<T>
	end
end

--[[
	Chains Option operations - applies callback only if Some
	The callback must return another Option
	@param callback Function that takes the value and returns an Option
	@return Result of the callback or None
]]
function OptionComponent.AndThen<T, K>(self : OptionComponent<T>,callback : (value : T) -> OptionComponent<K>)
	if(self:IsSome()) then
		local outOption = callback(self.Some :: T)
		assert(OptionConstructor.IsOption(outOption),"current callback must return a OptionComponent.")
		return outOption
	else
		return OptionConstructor.None()
	end
end

--[[
	Unwraps the value with a custom panic message if None
	@param msg Error message to display if Option is None
	@return The contained value
	@error Throws if Option is None
]]
function OptionComponent.Expect<T>(self : OptionComponent<T>,msg : string) : T
	assert(self:IsSome(),msg)
	return self.Some :: T
end

--[[
	Asserts that the Option is None, throwing error if Some
	@param msg Error message to display if Option contains a value
	@error Throws if Option is Some
]]
function OptionComponent.ExpectNone<T>(self : OptionComponent<T>,msg : string)
	assert(self:IsNone(),msg)
end

--[[
	Unwraps the contained value, panicking with default message if None
	@return The contained value
	@error Throws "Called UnWrap() on None" if Option is None
]]
function OptionComponent.UnWrap<T>(self : OptionComponent<T>)
	return self:Expect("Called UnWrap() on None")
end

--[[
	Unwraps the value or returns a default if None
	Alias for GetOr
	@param value Default value to return if None
	@return The contained value or default
]]
function OptionComponent.UnWrapOr<T, K>(self : OptionComponent<T>,value : K) : T | K
	return self:GetOr(value)
end

--[[
	Unwraps the value or computes a default if None
	Alias for GetOrElse
	@param callback Function to compute default if None
	@return The contained value or computed default
]]
function OptionComponent.UnWrapOrElse<T, K>(self : OptionComponent<T>,callback : Callback<K>) : T | K
	return self:GetOrElse(callback)
end

--[[
	Checks if the Option contains a specific value
	@param value The value to check for
	@return true if Option contains the exact value, false otherwise
]]
function OptionComponent.Contains<T, K>(self : OptionComponent<T>,value : K)
	return self:IsSome() and self.Some == value
end

--[[
	String representation of the Option
	@return "Option(value)" for Some, "Option(None)" for None
]]
function OptionComponent.__tostring<T>(self : OptionComponent<T>)
	if(self:IsSome()) then
		return "Option("..`{self.Some}`..")"
	else
		return "Option(None)"
	end
end

--[[
	Serializes the Option for storage or transmission
	@return Table with Tag and optional Value fields
]]
function OptionComponent.Serialize<T>(self : OptionComponent<T>)
	if(self:IsSome()) then
		return {
			Tag = self.Tag,
			Value = self.Some :: T,
		}
	end
	return {Tag = self.Tag}
end

--[[
	Equality comparison between two Options
	Two Options are equal if:
	- Both are None, or
	- Both are Some and contain equal values
	@param b The other Option to compare with
	@return true if Options are equal, false otherwise
]]
function OptionComponent.__eq<T>(self : OptionComponent<T>,b : OptionComponent<T>)
	local aIsOption = OptionConstructor.IsOption(self)
	local bIsOption = OptionConstructor.IsOption(b)
	if(not aIsOption or not bIsOption) then return false end
	if(self:IsSome() and b:IsSome()) then
		return self.Some == b.Some
	elseif(self:IsSome() and b:IsNone()) then
		return false
	elseif(self:IsNone() and b:IsNone()) then
		return true
	else
		return false
	end
end

-- Lowercase aliases for methods (alternative naming convention)
-- These provide the same functionality with camelCase naming
OptionComponent.Unwrap = OptionComponent.UnWrap
OptionComponent.UnwrapOr = OptionComponent.UnWrapOr
OptionComponent.getOr = OptionComponent.GetOr
OptionComponent.getOrElse = OptionComponent.GetOrElse
OptionComponent.expectNone = OptionComponent.ExpectNone
OptionComponent.andThen = OptionComponent.AndThen
OptionComponent.map = OptionComponent.Map
OptionComponent.filter = OptionComponent.Filter
OptionComponent.assert = OptionComponent.Assert
OptionComponent.match = OptionComponent.Match
OptionComponent.contains = OptionComponent.Contains
OptionComponent.isNone = OptionComponent.IsNone
OptionComponent.isSome = OptionComponent.IsSome
OptionComponent.serialize = OptionComponent.Serialize

-- OptionConstructor lowercase aliases
OptionConstructor.isOption = OptionConstructor.IsOption
OptionConstructor.deserialize = OptionConstructor.Deserialize

-- Export the constructor table to create Options
return OptionConstructor
