# Nexus

## Overview

This library provides a structured way to manage **RemoteEvents** and **RemoteFunctions** between client and server in Roblox.  
It introduces two main components:

Nexus include two components

- **Client Component** — Handles client-side communication with server remotes.
- **Server Component** — Handles server-side communication with client remotes.

Both components include validation support, event binding, safe connection handling, and clean-up mechanisms.

---

## Module: [Nexus](https://github.com/evxryyy/OpenEvxEngine/releases/tag/remote)

---

## Nexus.Client Component

---

## Creating a Client Component

```lua
local Nexus = require(path.to.Nexus)

local client = Nexus.Client.new({
    Name = "MyRemoteEvent",
    RemoteType = "RemoteEvent",
    Validator = function(...)
        -- Optional: Validate incoming data
        return true
    end
})
```

### Methods

`Client.new(RemoteConfig: RemoteConfiguration) : ClientComponent`

Creates and initializes a new client component, connecting to the specified remote.

---

``` ClientComponent:OnClientEvent(callback: (...any) -> ()) : RBXScriptConnection```
Registers a function to handle events received from the server.

Example:
```lua
client:OnClientEvent(function(message)
    print("Received from server:", message)
end)
```

---

`ClientComponent:FireServer(...: any)`

Sends data to the server through `FireServer`.

Example:
```lua
client:FireServer("Hello from client!")
```

---

`ClientComponent:InvokeServer(...: any) : any`

Calls a server-side RemoteFunction and returns the response.

Example:
```lua
local result = client:InvokeServer("RequestData")
print("Server replied:", result)
```

---

`ClientComponent:Handle(callback: (Player: Player, ...any) -> ())`

Assigns a callback for `OnClientInvoke` (rarely used for client components; typically server-side).

---

`ClientComponent:Disconnect()`

Disconnects the registered `OnClientEvent` listener.

---

`ClientComponent:Destroy()`

Cleans up the component and removes event listeners.

---

## Server Component

### Creating a Server Component

```lua
local Nexus = require(path.to.Nexus)

local server = Nexus.Server.new({
    Name = "MyRemoteEvent",
    RemoteType = "RemoteEvent",
    Validator = function(player, ...)
        -- Example: allow only specific players
        return player.UserId == 123456
    end
})
```

### Methods

`Server.new(RemoteConfig: RemoteConfiguration) : ServerComponent`

Creates and initializes a new server component, creating the remote if it does not exist.

---

`ServerComponent:OnServerEvent(callback: (Player: Player, ...any) -> ()) : RBXScriptConnection`

Registers a function to handle events received from clients.

Example:
```lua
server:OnServerEvent(function(player, message)
    print(player.Name .. " says:", message)
end)
```

---

`ServerComponent:FireClient(player: Player, ...: any)`

Sends data to a specific client.

Example:
```lua
server:FireClient(game.Players.JohnDoe, "Hello from server!")
```

---

`ServerComponent:InvokeClient(player: Player, ...: any) : any`

Calls a client-side RemoteFunction and waits for a return value.

Example:
```lua
local response = server:InvokeClient(game.Players.JohnDoe, "Ping")
print("Client replied:", response)
```

---

`ServerComponent:Handle(callback: (Player: Player, ...any) -> ())`

Assigns a callback for `OnServerInvoke` to handle client RemoteFunction calls.

Example:
```lua
server:Handle(function(player, data)
    return "Data received: " .. tostring(data)
end)
```

---

`ServerComponent:Disconnect()`

Disconnects the registered `OnServerEvent` listener.

---

`ServerComponent:Destroy()`

Cleans up the component, disconnects events, and destroys the remote instance.

---

### Best Practices

- Always use `Validator` functions to filter and validate incoming data.
- Always `Disconnect()` or `Destroy()` components when no longer needed.
- Keep `RemoteConfiguration.Name` unique per remote to avoid conflicts.
- Use `InvokeServer`/`InvokeClient` only for request-response logic; prefer `FireServer`/`FireClient` for standard events.

---

# Example Full Usage

**Server-side**
```lua
local Server = require(path.to.Nexus).Server

local chatServer = Server.new({
    Name = "ChatMessage",
    RemoteType = "RemoteEvent",
    Validator = function(player, message)
        return typeof(message) == "string" and #message > 0
    end
})

chatServer:OnServerEvent(function(player, message)
    print(player.Name .. ": " .. message)
    -- Send message to all players
    for _, p in ipairs(game.Players:GetPlayers()) do
        chatServer:FireClient(p, player.Name .. ": " .. message)
    end
end)
```

**Client-side**
```lua
local Client = require(path.to.Nexus).Client

local chatClient = Client.new({
    Name = "ChatMessage",
    RemoteType = "RemoteEvent"
})

chatClient:OnClientEvent(function(message)
    print("[Chat] " .. message)
end)

-- Send message to server
chatClient:FireServer("Hello everyone!")
```
