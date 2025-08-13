# Enum

---

## Overview

---

This module provides a system for creating and managing enums in Lua/Luau.
Enums are useful for creating named constants that represent specific values,
making code more readable and maintainable.
	
Features:

- Create enums with string keys and numeric values
- Automatic value assignment based on order
- Enum caching to prevent duplicate creation
- Type-safe enum access
- Frozen enums to prevent modification

## Installation

### Module : [Enum](https://github.com/evxryyy/OpenEvxEngine/releases/tag/enum)

## Quick example

---

```lua
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
```

## API

---

### Constructors

---

- `new<Name, Keys>(EnumName : Name,Items : {Keys}) -> : {[string] : EnumIndex<Name>}`

Creates a new enum with the given name and items.
	
If an enum with the same name already exists, returns the existing enum.
Otherwise, creates a new enum with auto-assigned numeric values.
	
- @param EnumName The unique name for this enum

- @param items Array of string keys for the enum values

- @return A frozen table mapping keys to EnumIndex objects

```lua
local Colors = EnumConstructor.new("Colors", {"Red", "Green", "Blue"})
-- Colors.Red = {Value = 1, Name = "Red", EnumType = "Colors"}
```

- `from<Name>(EnumName : Name) -> : {[string] : EnumIndex<Name>}`

Creates a new enum with the given name and items.
	
If an enum with the same name already exists, returns the existing enum.
Otherwise, creates a new enum with auto-assigned numeric values.
	
- @param EnumName The unique name for this enum

- @param items Array of string keys for the enum values

- @return A frozen table mapping keys to EnumIndex objects

```lua
local Colors = EnumConstructor.new("Colors", {"Red", "Green", "Blue"})
-- Colors.Red = {Value = 1, Name = "Red", EnumType = "Colors"}
```

- `RemoveEnum<Name>(EnumName : Name) -> ()`

Removes an enum from the registry.
	
This clears the enum table and removes it from the registry,
allowing a new enum with the same name to be created.
	
- @param EnumName The name of the enum to remove

```lua
EnumConstructor.RemoveEnum("Colors")
```

### Types

---

To add a new enum type open the EnumType module inside the Enum folder:

1. Define a Keys type with all possible enum values
2. Define an Enum type with the structure mapping keys to EnumIndex

---

#### Default inserted enum

Example enum type definitions
These demonstrate how to create type-safe enum definitions

HelloKeys defines the allowed string values for the Hello enum
Using a union type ensures only these specific strings can be used

```lua
export type HelloKeys = "A" | "B" | "C"
```

HelloEnum defines the structure of the Hello enum
It maps each key to an EnumIndex with the appropriate enum name
The generic parameter EnumName allows flexibility in the enum type name

```lua
export type HelloEnum<EnumName = string> = {
	A: EnumIndex<EnumName>,  -- Enum item A
	B: EnumIndex<EnumName>,  -- Enum item B
	C: EnumIndex<EnumName>,  -- Enum item C
}
```

now you can see <b>Quick example</b> for testing the enum with your own type.
