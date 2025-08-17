# SyncSignal

---

## Overview

---

A custom signal implementation that wraps Roblox's `BindableEvent` to provide a more controlled and feature-rich event system. This module ensures that only one callback can be connected to each signal at a time, making it ideal for synchronized operations where multiple listeners could cause conflicts.

## Features

---

- **Single listener enforcement** - Only one callback can be connected at a time
- **Global registry system** - Prevents duplicate signals with the same name
- **Memory management** - Proper cleanup methods included
- **Type-safe generic implementation** - Supports any number of arguments
- **Familiar API** - Similar to RBXScriptSignal

## Installation: [SyncSignal](https://github.com/evxryyy/OpenEvxEngine/releases/tag/bindableEvent)

## Quick example

=== "Script 1"

	```lua
	local ReplicatedStorage = game:GetService("ReplicatedStorage")

	local openEvxEngine = ReplicatedStorage.OpenEvxEngine

	local SyncSignal = require(openEvxEngine.SyncSignal)

	--Build a new SyncSignal instance
	local build = SyncSignal.new("Build")

	--connect the .Event of the BindableEvent
	build:Connect(function(...)
		print(...) -- prints the arguments passed to the .Fire
	end)
	```
=== "Script 2"

	```lua
	local ReplicatedStorage = game:GetService("ReplicatedStorage")

	local openEvxEngine = ReplicatedStorage.OpenEvxEngine

	local SyncSignal = require(openEvxEngine.SyncSignal)

	--Build a new SyncSignal instance
	local build = SyncSignal.new("Build")

	task.wait(1.5) -- wait a little bit to let the "Script1" script connect the bindable event

	--Fire with arguments (e.g a string)
	build:Fire("hello SyncSignal") -- will print "hello SyncSignal" in the "Script1" script
	```

## API

### Constructor

#### ```new<T...>() -> SyncSignalComponent<T...>```

Creates a new SyncSignal instance or returns an existing one with the same name
	
- @param Name - A unique string identifier for this signal
- @return SyncSignalComponent<T...> - The signal instance
	
This constructor implements a singleton pattern per signal name, ensuring that
multiple calls with the same name return the same signal instance. This is useful
for cross-script communication where different scripts need to access the same signal.

### Component

#### ```Connect<T...>(self : SyncSignalComponent<T...>, callback : (T...) -> ()) -> RBXScriptConnection```

Connects a callback function to this signal
	
- @param callback - The function to call when the signal is fired
- @return RBXScriptConnection - A connection object that can be used to disconnect
	
Important: This method enforces single-listener behavior. If a callback is already
connected, it returns the existing connection without replacing it. This prevents
multiple listeners from being attached to the same signal, ensuring synchronized behavior.

#### ```Once<T...>(self : SyncSignalComponent<T...>, callback : (T...) -> ()) -> ()```

Connects a callback that automatically disconnects after being fired once
	
- @param callback - The function to call when the signal is fired
	
This is useful for scenarios where you only need to respond to an event once,
such as waiting for initialization to complete or handling a one-time user action.
The connection is automatically cleaned up after the first fire

#### ```Fire<T...>(self : SyncSignalComponent<T...>,...) -> ()```

Fires the signal with the provided arguments
	
- @param ... - Any number of arguments to pass to connected callbacks
	
This method triggers all connected callbacks (though in this implementation,
there can only be one). The arguments are passed through the underlying
BindableEvent to any listening callbacks.

#### ```Wait<T...>(self : SyncSignalComponent<T...>) -> T...```

Yields the current thread until the signal is fired
	
- @return T... - The arguments that were passed to Fire()
	
This method is useful for synchronous code that needs to wait for an event
to occur before continuing. It will pause execution until Fire() is called
on this signal.

#### ```Disconnect<T...>(self : SyncSignalComponent<T...>) -> ()```

Disconnects the current callback without destroying the signal
	
This method removes the current listener but keeps the signal alive for future use.
After calling this, a new callback can be connected to the signal.

#### ```Destroy<T...>(self : SyncSignalComponent<T...>) -> ()```

Completely destroys the signal and cleans up all resources
	
This method should be called when the signal is no longer needed. It:

1. Disconnects any active connections
2. Removes the signal from the global registry
3. Destroys the underlying BindableEvent
4. Clears all references to help garbage collection
	
After calling Destroy(), this signal instance should not be used again.

### Component alias

```lua
-- Method aliases for different naming conventions
-- These provide flexibility in how users can call the methods

-- Lowercase aliases for users who prefer lowercase method names
SyncSignalComponent.destroy = SyncSignalComponent.Destroy
SyncSignalComponent.disconnect = SyncSignalComponent.Disconnect
SyncSignalComponent.fire = SyncSignalComponent.Fire
SyncSignalComponent.wait = SyncSignalComponent.Wait
SyncSignalComponent.connect = SyncSignalComponent.Connect
SyncSignalComponent.once = SyncSignalComponent.Once

-- Constructor aliases for different naming preferences
SyncSignalConstructor.New = SyncSignalConstructor.new
-- "From" aliases for a more semantic construction pattern
SyncSignalConstructor.From = SyncSignalConstructor.new
SyncSignalConstructor.from = SyncSignalConstructor.new
```
