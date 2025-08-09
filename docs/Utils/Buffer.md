## Getting Started

### Module : [Buffer](https://github.com/evxryyy/OpenEvxEngine/releases/tag/buffer)

Overview

The Buffer library is a powerful extension of Roblox's native buffer type that adds new data types and functionality for binary data manipulation. This library is particularly useful for data serialization, network communication, and optimized storage.

- 24-bit interger (3 byte)
- 40-bit interger (5 byte)
- 48-bit interger (6 byte)
- 54-bit interger (7 byte)
- 16-bit float (2 byte)

you will discover everything about it in this documentation.

## Constructor API

Lets write a create a simple buffer from the library

=== "Using .create()"

    ```lua linenums="1"
    local Buffer = require(somewhere.Buffer)

    local myData = Buffer.create(size : number)
    ```

    with the created BufferComponent Object you can write or read any type of value.

=== "Using .from()"

    .from accept a buffer and return a new BufferComponent Object
    please note that all data inside are not lost.

    ```lua linenums="1"
    local Buffer = require(somewhere.Buffer)

    local myOldData = buffer.create(10) -- basic buffer creation

    local myNewData = Buffer.from(myOldData)
    ```

=== "Using .fromString()"
    .fromString accept a string and return a new BufferComponent Object
    please note that all data inside the converted string are not lost.

    ```lua linenums="1"
    local Buffer = require(somewhere.Buffer)

    local myOldData = buffer.tostring(buffer.create(10)) -- basic buffer creation

    local myNewData = Buffer.fromString(myOldData)
    ```

=== "Convert the BufferComponent into a string"

    ```lua linenums="1"
    local Buffer = require(somewhere.Buffer)

    local myOldData = Buffer.create(10)

    local stringData = Buffer.tostring(myOldData)
    ```

now that you know how to create a BufferComponent Object let me show how to use it.

## Allocating Memory

from the created BufferComponent Object you can allocate memory when needed.

```lua linenums="1"
local Buffer = require(somewhere.Buffer)

local myData = Buffer.create(size : number)

myData:allocate(sizeToAllocate : number)
```

this will allocate new memory space to buffer for exemple if the buffer has a size of 10 and you allocate 5 the new buffer size will be 15 bytes

## Writing Data

for writing data inside the buffer i recommend you to look at the Constants module inside the BufferModule to look at min and max interger value

=== "Writing Number"

    ```lua linenums="1"
    local Buffer = require(somewhere.Buffer)

    local myData = Buffer.create(size : number)

    myData:WriteI24(value : number) -- min : -8388608 max : 8388607
    ```

    this will write a Signed Interger 24-bit (3 byte) to the buffer

=== "Writing String"

    ```lua linenums="1"
    local Buffer = require(somewhere.Buffer)

    local myData = Buffer.create(size : number)

    myData:WriteString("Hello World !") 
    ```

    other type exist for writing string such as:
    
    - String8 - (max 8 len)
    - String16 - (max 16 len)
    - String32 - (max 32 len)
    - String64 - (max 64 len)

    please note that these function need a len argument after passing the string to write.

## Component API

### Write Methods

```lua linenums="1"
-- Signed integers
Buffer:WriteI8(number)
Buffer:WriteI16(number)
Buffer:WriteI24(number)
Buffer:WriteI32(number)
Buffer:WriteI40(number)
Buffer:WriteI48(number)
Buffer:WriteI54(number)

-- Unsigned integers
Buffer:WriteU1(number)
Buffer:WriteU8(number)
Buffer:WriteU16(number)
Buffer:WriteU24(number)
Buffer:WriteU32(number)
Buffer:WriteU40(number)
Buffer:WriteU48(number)
Buffer:WriteU54(number)

-- Float
Buffer:WriteF16(number)
Buffer:WriteF32(number)
Buffer:WriteF64(number)

-- String with limited length
Buffer:WriteString8(value, length)
Buffer:WriteString16(value, length)
Buffer:WriteString32(value, length)
Buffer:WriteString64(value, length)

-- Full string
Buffer:WriteString(value)

-- Single boolean
Buffer:WriteBool1(value)

-- Array of 8 booleans
Buffer:WriteBool8({true, false, true, ...})

-- Roblox Types
Buffer:WriteVector2(vector2)
Buffer:WriteVector3(vector3)
Buffer:WriteVector2Int16(vector2int16)
Buffer:WriteVector3Int16(vector3int16)
Buffer:WriteCFrame(cframe)
Buffer:WriteLossyCFrame(cframe)
Buffer:WriteUdim(udim)
Buffer:WriteUdim2(udim2)
Buffer:WriteColor3(color3)
Buffer:WriteRect(rect)
Buffer:WriteRegion3(region3)
Buffer:WriteRegion3int16(region3int16)
Buffer:WriteInstance(instance)
```

### Read Methods

```lua linenums="1"
-- Signed integers
local value = Buffer:ReadI8(offset?)
local value = Buffer:ReadI16(offset?)
local value = Buffer:ReadI24(offset?)
local value = Buffer:ReadI32(offset?)
local value = Buffer:ReadI40(offset?)
local value = Buffer:ReadI48(offset?)
local value = Buffer:ReadI54(offset?)

-- Unsigned integers
local value = Buffer:ReadU8(offset?)
local value = Buffer:ReadU16(offset?)
local value = Buffer:ReadU24(offset?)
local value = Buffer:ReadU32(offset?)
local value = Buffer:ReadU40(offset?)
local value = Buffer:ReadU48(offset?)
local value = Buffer:ReadU54(offset?)

-- Floats
local value = Buffer:ReadF16(offset?)
local value = Buffer:ReadF32(offset?)
local value = Buffer:ReadF64(offset?)

-- Strings
local str = Buffer:ReadString(length?, offset?)

-- Booleans
-- Single boolean
local bool = Buffer:ReadBool1(offset?)

-- Array of 8 booleans
local boolData = Buffer:ReadBool8(offset?)
local bools = boolData.value -- Array of booleans
local majority = boolData:majority() -- Returns true if more true than false

-- Roblox Types
local vector2 = Buffer:ReadVector2(offset?)
local vector3 = Buffer:ReadVector3(offset?)
local vector2int16 = Buffer:ReadVector2int16(offset?)
local vector3int16 = Buffer:ReadVector3int16(offset?)
local cframe = Buffer:ReadCFrame(offset?)
local cframe = Buffer:ReadLossyCFrame(offset?)
local udim = Buffer:ReadUdim(offset?)
local udim2 = Buffer:ReadUdim2(offset?)
local color3 = Buffer:ReadColor3(offset?)
local rect = Buffer:ReadRect(offset?)
local region3 = Buffer:ReadRegion3(offset?)
local region3int16 = Buffer:ReadRegion3int16(offset?)
local instance = Buffer:ReadInstance(instance_offset?)
```

### Utility Methods

<b>allocate(size: number)</b>

Allocates additional memory space to the buffer.

```lua linenums="1"
Buffer:allocate(512) -- Adds 512 bytes
```

<b>GetOffset()</b>

Returns the current write cursor position.

```lua linenums="1"
local offset = Buffer:GetOffset()
```

<b>GetInstanceOffset()</b>

Returns the current position in the instance buffer.

```lua linenums="1"
local instanceOffset = Buffer:GetInstanceOffset()
```

<b>GetBuffer()</b>

Returns the underlying native buffer.

```lua linenums="1"
local nativeBuffer = Buffer:GetBuffer()
```

<b>GetInstanceBuffer()</b>

Returns the array of stored instances.

```lua linenums="1"
local instances = Buffer:GetInstanceBuffer()
```

<b>GetBufferSize()</b>

Returns the total size of the buffer.

```lua linenums="1"
local size = Buffer:GetBufferSize()
```

<b>clear()</b>

Resets the buffer while maintaining its size.

```lua linenums="1"
Buffer:clear()
```

<b>Destroy()</b>

Destroys the BufferComponent and frees memory.

```lua linenums="1"
Buffer:Destroy()
```

## Usages

### Player Data Serialization

```lua linenums="1"
local Buffer = require(path.to.Buffer)

-- Create a buffer to store data
local playerData = Buffer.create(256)

-- Write data
playerData:WriteString32("evxry_ll", #"evxry_ll") -- 8 byte len
playerData:WriteI32(1500) -- Score
playerData:WriteF32(100.5) -- Health
playerData:WriteVector3(Vector3.new(10, 20, 30)) -- Position
playerData:WriteBool1(true) -- Is alive

-- Convert to string for storage
local serialized = Buffer.tostring(playerData)
```

### Reading Serialized Data

```lua linenums="1"
local Buffer = require(path.to.Buffer)

-- Reconstruct from string
local loadedData = Buffer.fromString(serialized)

-- Read data
local name = loadedData:ReadString(#"evxry_ll", 0) -- 8 byte len
local score = loadedData:ReadI32(8)
local health = loadedData:ReadF32(12)
local position = loadedData:ReadVector3(16)
local isAlive = loadedData:ReadBool1(40)

print(name)
print(score)
print(health)
print(position)
print(isAlive)
```

### CFrame Compression

```lua linenums="1"
local buffer = Buffer.create(100)

-- Use LossyCFrame to save space
buffer:WriteLossyCFrame(workspace.Part.CFrame) -- 48 bytes
-- vs
buffer:WriteCFrame(workspace.Part.CFrame) -- 92 bytes
```

## Supported Data Types

Signed Integers

- I8: -128 to 127 (1 byte)
- I16: -32,768 to 32,767 (2 bytes)
- I24: -8,388,608 to 8,388,607 (3 bytes)
- I32: -2,147,483,648 to 2,147,483,647 (4 bytes)
- I40: -549,755,813,888 to 549,755,813,887 (5 bytes)
- I48: -140,737,488,355,328 to 140,737,488,355,327 (6 bytes)
- I54: -9,007,199,254,740,992 to 9,007,199,254,740,991 (7 bytes)

Unsigned Integers

- U1: 0 to 1 (1 byte)
- U8: 0 to 255 (1 byte)
- U16: 0 to 65,535 (2 bytes)
- U24: 0 to 16,777,215 (3 bytes)
- U32: 0 to 4,294,967,295 (4 bytes)
- U40: 0 to 1,099,511,627,775 (5 bytes)
- U48: 0 to 281,474,976,710,655 (6 bytes)
- U54: 0 to 18,014,398,509,481,984 (7 bytes)

Roblox Types

- Vector2 (16 bytes)
- Vector3 (24 bytes)
- Vector2int16 (4 bytes)
- Vector3int16 (6 bytes)
- CFrame (92 bytes)
- LossyCFrame (48 bytes) - Compressed version with precision loss
- UDim (8 bytes)
- UDim2 (16 bytes)
- Color3 (12 bytes)
- Rect (32 bytes)
- Region3 (116 bytes)
- Region3int16 (12 bytes)

Other Types

- String (variable length)
- String8/16/32/64 (limited length)
- Bool1 (1 byte)
- Bool8 (1 byte for 8 booleans)
- Instance (stored separately)

## Important Notes

- Memory Management: Numeric values are automatically clamped to the min/max values of the type.

- Offset: The offset is automatically incremented after each write. For reading, you can specify a custom offset.

- Instances: Instances are stored in a separate buffer and are not serialized in the main buffer.

- Performance: Custom types (I24, I40, I48, I54, etc.) are less performant than native types as they require multiple bitwise operations.

- Precision: F16 and LossyCFrame sacrifice precision to save space.

## License

See the LICENSE file for information about using and redistributing this library.
