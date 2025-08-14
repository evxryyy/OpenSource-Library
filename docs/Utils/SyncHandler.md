# SyncHandler

---

## Overview

---

A sophisticated handler system built on top of Roblox's BindableFunction that provides
synchronous function invocation with timeout protection. This module ensures that only
one handler can be registered at a time, making it ideal for request-response patterns
where multiple handlers could cause conflicts or ambiguous behavior.

## Key Features

---

- Single handler enforcement (only one callback can handle invocations at a time)
- Configurable timeout system to prevent indefinite waiting
- Global registry to prevent duplicate handlers with the same name
- Type-safe generic implementation supporting any argument types
- Clean disconnection mechanism that returns a cleanup function

## Use cases

---

- Inter-script communication requiring responses
- Synchronous API implementations
- Request-response patterns between different parts of your game

## Installation: [SyncHandler](https://github.com/evxryyy/OpenEvxEngine/releases/tag/bindableFunction)

## Quick example

```lua
-- Script 1: Setting up the handler
local SyncHandler = require(path.to.SyncHandler)

-- Create a handler for calculator operations
local calculatorHandler = SyncHandler.new("Calculator")

-- Register a handler that performs calculations
local disconnect = calculatorHandler:OnInvoke(function(operation, a, b)
	print("Handler received:", operation, a, b)

	if operation == "add" then
		return a + b
	elseif operation == "multiply" then
		return a * b
	elseif operation == "divide" then
		if b == 0 then
			return nil, "Cannot divide by zero"
		end
		return a / b
	else
		return nil, "Unknown operation"
	end
end)

-- The handler is now ready to receive invocations
-- Invoke some calculations
local result1 = calculatorHandler:Invoke("add", 5, 3)
print("5 + 3 =", result1) -- Output: 5 + 3 = 8

local result2 = calculatorHandler:Invoke("multiply", 4, 7)
print("4 * 7 =", result2) -- Output: 4 * 7 = 28

local result3, error = calculatorHandler:Invoke("divide", 10, 2)
print("10 / 2 =", result3) -- Output: 10 / 2 = 5

-- Try dividing by zero
local result4, error = calculatorHandler:Invoke("divide", 10, 0)
if error then
	print("Error:", error) -- Output: Error: Cannot divide by zero
end
```

## API

### Constructor

#### ```new<T...>(Name : string) -> SyncHandlerComponent<T...>```

Creates a new SyncHandler instance or returns an existing one with the same name
	
- @param Name - A unique string identifier for this handler
- @return SyncHandlerComponent<T...> - The handler instance
	
This constructor implements a singleton pattern per handler name. If a handler
with the given name already exists, it returns that instance instead of creating
a new one. This is crucial for cross-script communication where different scripts
need to access the same handler.

### Component

#### ```OnInvoke<T...>(self : SyncHandlerComponent<T...>,callback : (T...) -> ()) : () -> ()```

Registers a callback function to handle invocations
	
- @param callback - The function that will process invocations and return results
- @return function - A cleanup function that disconnects the handler when called
	
This method enforces single-handler behavior. If a handler is already registered,
it returns a cleanup function for the existing handler without replacing it.
The returned cleanup function provides a convenient way to disconnect the handler
without needing to keep a reference to the handler object.

#### ```Invoke<T...>(self : SyncHandlerComponent<T...>,...) : ...any```

Invokes the handler with the provided arguments and waits for a response
	
- @param ... - Arguments to pass to the handler function
- @return ...any - The values returned by the handler, or nil if timeout occurs
	
This method implements a timeout-protected invocation system. It attempts to
invoke the handler and will wait up to the configured timeout duration for
a response. If no response is received within the timeout, it returns nil
and logs a warning.
	
The implementation uses a polling approach with task.defer to prevent blocking
while still providing synchronous-like behavior.

#### ```SetTimeout<T...>(self : SyncHandlerComponent<T...>,timeout : number)```

Sets the timeout duration for invoke operations
	
- @param timeout - The new timeout duration in seconds
	
This allows you to adjust how long Invoke will wait for a response before
giving up. Shorter timeouts can prevent long waits but may cause legitimate
operations to fail. Longer timeouts are more forgiving but can cause delays
when handlers are unresponsive.

#### ```Destroy<T...>(self : SyncHandlerComponent<T...>) : ()```

Completely destroys the handler and cleans up all resources
	
This method should be called when the handler is no longer needed. It:

1. Disconnects any registered handler function
2. Destroys the underlying BindableFunction
3. Clears all internal references
4. Removes metatable connections
	
After calling Destroy(), this handler instance should not be used again.

### Component alias

```lua
-- Method aliases for different naming conventions
-- These provide flexibility for users with different coding style preferences

-- Lowercase aliases
SyncHandlerComponent.setTimeout = SyncHandlerComponent.SetTimeout
SyncHandlerComponent.SetTimeOut = SyncHandlerComponent.SetTimeout  -- Alternative capitalization
SyncHandlerComponent.onInvoke = SyncHandlerComponent.OnInvoke
SyncHandlerComponent.invoke = SyncHandlerComponent.Invoke
SyncHandlerComponent.destroy = SyncHandlerComponent.Destroy

-- Constructor aliases for different naming preferences
SyncHandlerConstructor.New = SyncHandlerConstructor.new      -- Capital 'N' variant
SyncHandlerConstructor.from = SyncHandlerConstructor.new     -- Lowercase 'from' pattern
SyncHandlerConstructor.From = SyncHandlerConstructor.new     -- Capitalized 'From' pattern
```
