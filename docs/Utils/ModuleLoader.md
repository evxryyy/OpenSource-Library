# ModuleLoader

## Overview

---

ModuleLoader is a lightweight utility to load, initialize, start, and clean up your Roblox ModuleScripts in a folder and its subfolders. It supports:

- Per-module priorities (via the "Priority" attribute)
- Sorting modules by descending priority
- A consistent lifecycle: Init → Start → Cleaning
- Multiple load calls (you can call Load on multiple roots)
- Server and client execution with distinct logs

> Each ModuleScript must return a table with at least `Init` and `Start`, and optionally `Cleaning`.

---

## Module : [ModuleLoader](https://github.com/evxryyy/OpenEvxEngine/releases/tag/loader)

---

## Key features
- Recursive loading (depending on USE_DESCENDANT)
- Ordered start (higher priority first)
- API to filter/control startup (Each)
- Global cleanup (Clear/Stop)
- Find a loaded module (Find)

---

## Quick example

Assume ModuleLoader.luau is in ReplicatedStorage.

```lua
-- ServerScriptService/ServerMain.server.lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local ModuleLoader = require(ReplicatedStorage.ModuleLoader)

ModuleLoader.SetSettings({
    SHOW_DEBUG_PRINT = true,  -- Show logs
    USE_DESCENDANT    = true, -- Traverse all descendants
})

-- Load all modules under ServerScriptService/Modules
ModuleLoader.Load(ServerScriptService:WaitForChild("Modules"))

-- Start modules in priority order
ModuleLoader.Start()
```

---

## Installation
- Create a ModuleScript named `ModuleLoader` (or import the existing file) in `ReplicatedStorage` (recommended), or any shared location.
- Put your target ModuleScripts in a folder (e.g., `ServerScriptService/Modules`).

---

### Minimal module structure

```lua
local MyModule = {}

function MyModule:Init()
    -- Setup (must not yield)
end

function MyModule:Start()
    -- Start (must not yield)
end

function MyModule:Cleaning()
    -- Optional: cleanup
end

return MyModule
```

> Important: Init and Start must not yield (avoid waits that block execution).

### Server

---

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ModuleLoader = require(ReplicatedStorage.ModuleLoader)

ModuleLoader.SetSettings({
    SHOW_DEBUG_PRINT = true,
    USE_DESCENDANT = true,
})

ModuleLoader.Load(ServerScriptService.Modules)
ModuleLoader.Start()
```

---

### Client

```lua
-- StarterPlayerScripts/ClientMain.client.lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayerScripts = game:GetService("StarterPlayerScripts")

local ModuleLoader = require(ReplicatedStorage.ModuleLoader)

ModuleLoader.SetSettings({
    SHOW_DEBUG_PRINT = true,
    USE_DESCENDANT = true,
})

ModuleLoader.Load(StarterPlayerScripts:WaitForChild("ClientModules"))
ModuleLoader.Start()
```

---

## Attributes and priorities

---

Set a module’s priority via ModuleScript:SetAttribute("Priority", number).
Higher priority runs earlier.
If priorities are equal, load order is used.
text

### Settings (SetSettings)

---

```lua
ModuleLoader.SetSettings({
  SHOW_DEBUG_PRINT = boolean, -- true = show logs
  USE_DESCENDANT   = boolean, -- true = GetDescendants(), false = only GetChildren()
})
```

Call SetSettings before Start.
You can call Load multiple times to gather modules from different roots.

---

## Loading

---

```lua
ModuleLoader.Load(someFolderOrInstance)
```

If USE_DESCENDANT = true: collects all ModuleScripts under the instance.

Otherwise: only immediate children (you can Load subfolders yourself to recurse).

---

## Global start

---

```lua
ModuleLoader.Start()
```

Calls :Init() then :Start() on each module, sorted by descending priority.

Do not call twice (assertion).

---

## Selective start (Each)

---

```lua
ModuleLoader.Each(function(moduleScript)
  -- Return true to start this module, false to skip it
  return moduleScript:GetAttribute("Run") ~= false
end)
```

Each lets you filter which modules to run (e.g., by attribute, tag, or name).
Do not call after Start (assertion).

---

## Cleanup and restart

---

ModuleLoader.Clear() calls :Cleaning() on each module (if present) then wipes the registry.
ModuleLoader.Stop() calls Clear() and resets the started state so you can load/start again.

---

## Tips

---

Put ModuleLoader in ReplicatedStorage to share it between server and client.

Modules are required at Load time, so top-level code in your modules runs during loading.

Init/Start must not yield (no unbounded WaitForChild or network waits).

---

## API

---

### Types

---

- Settings
  - SHOW_DEBUG_PRINT: boolean
  - USE_DESCENDANT: boolean

- RegisteryIndex
  - instance: ModuleScript
  - module: ModuleLoaderComponent
  - priority: number

- ModuleLoaderComponent
  - Init: (...any) -> ()
  - Start: (...any) -> ()
  - Cleaning: (...any) -> () | nil

---

### Functions

---

#### ModuleLoader.SetSettings(customSettings: Settings) -> ()
- Sets the loader’s global settings.
- Call before `Start`.

---

#### ModuleLoader.Load(descendant: Instance) -> ()
- Finds and require()s all ModuleScripts under `descendant`.
- May be called multiple times with different roots.
- Sorts the registry by descending priority after loading.

---

#### ModuleLoader.Start() -> ()
- Starts all loaded modules:
  1) Calls `:Init()`
  2) Calls `:Start()`
- Asserts if already started.

---

#### ModuleLoader.Each(callback: (module: ModuleScript) -> boolean) -> ()
- Iterates over all loaded modules.
- For each module, if `callback(moduleScript)` returns true, calls `:Init()` and then `:Start()` for that module.
- Asserts if already started.

---

#### ModuleLoader.Clear() -> ()
- If a module exposes `Cleaning`, calls it.
- Clears the registry.

---

#### ModuleLoader.Stop() -> ()
- Calls `Clear()` and resets `started = false`. You can then `Load`/`Start` again.

---

#### ModuleLoader.Find(ModulePath: ModuleScript | string) -> RegisteryIndex?
- Locates a previously loaded module:
  - By name (string)
  - By instance (ModuleScript)
- Returns the `RegisteryIndex` entry (or nil if not found).

---

#### ModuleLoader.WaitUntilStarted() -> number
- return the elapsted time until the module loader start.

---

#### ModuleLoader.IsStarted() -> boolean
- return trued if the module loader is started.

---

#### Server/client logs

- Server messages are prefixed with `[S] -->`

- Client messages are prefixed with `[C] -->`

---

## Exemples

---

### 1) Priorities and multiple roots

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local ModuleLoader = require(ReplicatedStorage.ModuleLoader)

ModuleLoader.SetSettings({
  SHOW_DEBUG_PRINT = true,
  USE_DESCENDANT = true,
})

-- Load from multiple roots
ModuleLoader.Load(ServerScriptService.Modules)
ModuleLoader.Load(ServerScriptService.Features)

-- Set priorities in Studio using attributes
-- e.g., ClickerModule.Priority = 100, UIModule.Priority = 50

ModuleLoader.Start()
```
