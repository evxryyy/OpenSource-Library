# Option

## Overview

This module implements a Rust-like `Option<T>`:

- `Some(value)` holds a value of type `T`
- `None` represents the absence of a value

It helps you avoid nil checks sprinkled across your code and centralizes handling via:

- Safe accessors (`GetOr`, `GetOrElse`, `UnwrapOr`, `Expect`, …)
- Transformations (`Map`, `AndThen`)
- Predicates (`IsSome`, `IsNone`, `Contains`, `Filter`)
- Combinators (`XOR`)
- Pattern matching (`Match`)
- Serialization (`Serialize`, `Deserialize`)

Lowercase aliases are provided (e.g., `unwrap`, `getOr`, `andThen`, …) in addition to PascalCase.

## Getting started

---

## Installation

### Download : [Option](https://github.com/evxryyy/OpenEvxEngine/releases/tag/option)

- Place the Option module (this file) in a shared location like `ReplicatedStorage`.
- Require it where you need it:

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Option = require(ReplicatedStorage.Option)
```

## Quick example

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Option = require(ReplicatedStorage.Option)

-- Wrap a possibly-nil value (Some if not nil, otherwise None)
local maybePart = Option.Wrap(workspace:FindFirstChild("SpawnLocation"))

-- Access with default:
local part = maybePart:GetOr(workspace.Terrain)

-- Filter + transform + default:
local displayName =
    Option.Wrap(game.Players.LocalPlayer and game.Players.LocalPlayer.DisplayName)
        :Filter(function(n) return #n > 0 end)
        :Map(function(n) return n:upper() end) -- Map keeps the same type
        :GetOr("GUEST")

print("Display:", displayName)

-- Pattern match:
maybePart:Match({
  Some = function(p) print("Found part:", p.Name); return nil end,
  None = function() print("No part found"); return nil end,
})

-- Unwrap with message (throws if None)
local requiredPart = maybePart:Expect("SpawnLocation is required!")
```

## API

---

### Types

---

- Some<T> = T
- None = () -> ()
- Callback<T> = () -> T
- MappedCallback<T> = (value: T) -> T
- FilterCallback<T> = (value: T) -> boolean
- AndThenCallback<T, K> = (value: T) -> any

- OptionComponent<T> (metatable-backed)
  - Fields:
    - Tag: "Some" | "None"
    - Some: T
    - None: nil
  - Methods: see below

### Constructors

---

- Option.Some<T>(value: T): OptionComponent<T>
- Option.None(): OptionComponent<nil>
- Option.IsOption<T>(value: any): boolean
- Option.Wrap<T>(value: T?): OptionComponent<T> | OptionComponent<nil>
- Option.Deserialize<T>(data: { Tag: "Some" | "None", Value: T }): OptionComponent<T>

### Option methods

---

- IsSome<<T>T>(self): boolean
- IsNone<<T>T>(self): boolean
- Match<<T>T>(self, opts: { Some: (T) -> any, None: () -> any }) : any
- Assert<<T>T>(self, errorMessage: string) : ()
- GetOr<<T, K>T, k>(self, defaultValue: K) : T | K
- Map<<T>T>(self, fn: (T) -> T) : OptionComponent<<T>T>
- Filter<<T>T>(self, pred: (T) -> boolean) : OptionComponent<<T>T> | OptionComponent<<T>T>
- GetOrElse<<T, K>T, k>(self, fn: () -> K) : T | K
- XOR<<T>T>(self, other: OptionComponent<<T>T>) : OptionComponent<<T>T> | OptionComponent<<T>T>
- AndThen<<T, K>T, k>(self, fn: (T) -> OptionComponent<<K>K>) : OptionComponent<<T>T> | OptionComponent<<K>K>
- Expect<<T>T>(self, msg: string): T
- ExpectNone<<T>T>(self, msg: string) : ()
- UnWrap<<T>T>(self) : T
- UnWrapOr<<T, K>T, k>(self, defaultValue: K) : T | K
- UnWrapOrElse<<T, K>T, k>(self, fn: () -> K) : T | K
- Contains<<T, K>T, k>(self, value: K) : boolean
- Serialize<<T>T>(self) : { Tag: "Some" | "None", Value?: T }

### Metamethods

---

- __tostring(self): string
- __eq(self, other): boolean

### Aliases

---

```lua
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
```

## Troubleshooting

---

#### "Called UnWrap() on None"

- You called `UnWrap()`/`Unwrap()` on a `None`. Use `GetOr`, `GetOrElse`, or `Expect` with a message.

---

#### My `Map` lost the type I wanted

- `Map` is monomorphic: `(T) -> T`. To change type (e.g., string → number), use `AndThen` and return another `Option`.

---

#### "current callback must return a OptionComponent."

- Your `AndThen` callback must return an `Option` (i.e., `Option.Some(...)` or `Option.None()`).

---

#### `Match` signature confusion

- `Match` executes either `opts.None()` or `opts.Some(value)`. It returns whatever your callback returns. Keep callbacks side-effect-safe.

---

#### `Option.IsOption` returned false

- `IsOption` checks for a `Tag` field. Ensure you're passing an `Option` created by this module.

---

#### Equality not behaving as expected

- `Some(a) == Some(b)` uses `a == b`. If `a` and `b` are tables, that’s reference equality by default in Luau.

---

#### Serialization pitfalls

- `Serialize` stores raw `Value`. Ensure the value is serializable (no cyclic references, userdata, etc.).

---

## <b>Design notes</b>

---

- The Option is represented as a table with a `Tag`:
  - `Tag = "Some"` and a `Some` field containing the value
  - `Tag = "None"` (and an internal `None = true` field)
- `IsOption` uses a structural check (`option and option.Tag`)—simple and fast.

### <b>Map vs. AndThen</b>

---

- `Map` keeps the type: `(T) -> T`.
- `AndThen` allows changing type: `(T) -> Option<K>`; it asserts that the callback returns an `Option`.

### <b>Pattern matching</b>

---

- `Match` expects a table with `Some` and `None` callbacks:
  ```lua
  opt:Match({
    Some = function(v) ... end,
    None = function() ... end,
  })
