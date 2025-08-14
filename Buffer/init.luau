--!native
--!nonstrict

--[[
	Author : evxry_ll

	Buffer : A powerfull library to write data with the "buffer" type

    Supported Data Types:
    
    ================ INTEGER TYPES ================
    Signed Integers:
    - I8  (8-bit)   : -128 to 127
    - I16 (16-bit)  : -32,768 to 32,767
    - I24 (24-bit)  : -8,388,608 to 8,388,607
    - I32 (32-bit)  : -2,147,483,648 to 2,147,483,647
    - I40 (40-bit)  : -549,755,813,888 to 549,755,813,887
    - I48 (48-bit)  : -140,737,488,355,328 to 140,737,488,355,327
    - I54 (54-bit)  : -9,007,199,254,740,992 to 9,007,199,254,740,991
    
    Unsigned Integers:
    - U1  (1-bit)   : 0 to 1
    - U8  (8-bit)   : 0 to 255
    - U16 (16-bit)  : 0 to 65,535
    - U24 (24-bit)  : 0 to 16,777,215
    - U32 (32-bit)  : 0 to 4,294,967,295
    - U40 (40-bit)  : 0 to 1,099,511,627,775
    - U48 (48-bit)  : 0 to 281,474,976,710,655
    - U54 (54-bit)  : 0 to 18,014,398,509,481,984
    
    ================ FLOATING POINT TYPES ================
    - F16 (16-bit) : Half-precision float
    - F32 (32-bit) : Single-precision float
    - F64 (64-bit) : Double-precision float
    
    ================ OTHER DATA TYPES ================
    - Boolean (1-bit and 8-bit packed)
    - Strings (with various length limits: 8, 16, 32, 64 chars or unlimited)
    - Color3
    - Vector2, Vector3
    - Vector2int16, Vector3int16
    - CFrame (both regular and lossy compressed versions)
    - UDim, UDim2
    - Rect
    - Region3, Region3int16
    - Instances (stored in a separate instance buffer)

	you are free to edit this has you want but if you want to publish it PLEASE READ LICENSE.

	fore more control of this library go take a look of Constants inside this module for number and float precisions
	or you can also read the documentation.
	
	note:
	the buffer inside can be encrypted for security purpose.
--]]

--Types
local Types = require("@self/Utils/Types")

--Constants
local Constants = require("@self/Constants")

--Constructor
local BufferConstructor = {}
BufferConstructor.__index = BufferConstructor

local BufferComponent = {}
BufferComponent.__index = BufferComponent

--[[
	create a BufferComponentClass with the given size
]]
function BufferConstructor.create(size : number) : Types.BufferComponentClass
	if(not size or (size) <= 0) then size = 1 end
	local self = setmetatable({
		offset = 0,
		instance_offset = 1,
		buffer = buffer.create(size),
	},BufferComponent)
	return self
end

--[[
	from the given buffer it will transform it into a BufferComponentClass
	all data written in the buffer will not be lost and you will be able to read it with :Read[DataTypeName] methods.
]]
function BufferConstructor.from(b : buffer) : Types.BufferComponentClass
	if(not b and type(b) ~= "buffer") then error("please insert a valid buffer") end
	local self = setmetatable({
		offset = buffer.len(b),
		instance_offset = 0,
		instance_buffer = {},
		buffer = b,
	},BufferComponent)
	return self
end

--[[
	convert the actual BufferComponentClass.buffer into a string
	can only be called by the constructor not the component
]]
function BufferConstructor.tostring(BufferComponent : Types.BufferComponentClass)
	return buffer.tostring(BufferComponent.buffer)
end

--[[
	from the given string it will transform it into a BufferComponentClass
]]
function BufferConstructor.fromString(str : string) : Types.BufferComponentClass
	if(not str or type(str) ~= "string") then error("please insert a valid string") end
	return BufferConstructor.from(buffer.fromstring(str))
end

--[[
	__tostring metamethod
]]
function BufferComponent.__tostring(self : Types.BufferComponentClass)
	return `BufferComponent(Size:{buffer.len(self.buffer)})`
end

--[[
	allocate new memory space to the actual BufferComponentClass.buffer
]]
function BufferComponent.allocate(self : Types.BufferComponentClass,size : number) : ()
	local new_buffer = buffer.create(buffer.len(self.buffer)+size)
	buffer.copy(new_buffer,0,self.buffer,0,buffer.len(self.buffer))
	self.buffer = new_buffer
end

--[[
	Write a Signed Interger 8-bit (-128,127)
	if the number exit the allowed value the number is automaticly clamped.
]]
function BufferComponent.WriteI8(self : Types.BufferComponentClass,number : number) : ()
	if(not number or type(number) ~= "number") then warn(`{type(number)} is not a number.`) return end
	number = math.clamp(math.modf(number),Constants.MIN_INT8,Constants.MAX_INT8)
	local bytes = 1
	if(buffer.len(self.buffer) < bytes) then warn("1 bytes is required to write an SignedInteger8") return end
	local success,outOfBounds = pcall(buffer.writei8,self.buffer,self.offset,number)
	if(outOfBounds) then warn(outOfBounds) return end
	self.offset += 1
end

--[[
	Write a Signed Interger 16-bit (-32768,32767)
	if the number exit the allowed value the number is automaticly clamped.
]]
function BufferComponent.WriteI16(self : Types.BufferComponentClass,number : number) : ()
	if(not number or type(number) ~= "number") then warn(`{type(number)} is not a number.`) return end
	number = math.clamp(math.modf(number),Constants.MIN_INT16,Constants.MAX_INT16)
	local bytes = 2
	if(buffer.len(self.buffer) < bytes) then warn("2 bytes is required to write an SignedInteger16") return end
	local success,outOfBounds = pcall(buffer.writei16,self.buffer,self.offset,number)
	if(outOfBounds) then warn(outOfBounds) return end
	self.offset += 2
end

--[[
	Write a Signed Interger 24-bit (-8388608,8388607)
	if the number exit the allowed value the number is automaticly clamped.
]]
function BufferComponent.WriteI24(self : Types.BufferComponentClass,number : number)
	if(not number or type(number) ~= "number") then warn(`{type(number)} is not a number.`) return end
	number = math.max(Constants.MIN_INT24,math.min(Constants.MAX_INT24,number))
	number = math.modf(number)
	local bytes = 3
	if(buffer.len(self.buffer) < bytes) then warn("3 bytes is required to write an SignedInteger24") return end
	local success,outOfBounds = pcall(function()
		--Compressing all bytes to the buffer to a unsigned int 8 bits
		buffer.writeu8(self.buffer,self.offset + 0,bit32.extract(number,16,8))
		buffer.writeu8(self.buffer,self.offset + 1,bit32.extract(number,8,8))
		buffer.writeu8(self.buffer,self.offset + 2,bit32.extract(number,0,8))
	end)
	if(outOfBounds) then warn(outOfBounds) return end
	self.offset += 3
end

--[[
	Write a Signed Interger 32-bit (-2147483648,2147483647)
	if the number exit the allowed value the number is automaticly clamped.
]]
function BufferComponent.WriteI32(self : Types.BufferComponentClass,number : number) : ()
	if(not number or type(number) ~= "number") then warn(`{type(number)} is not a number.`) return end
	number = math.clamp(math.modf(number),Constants.MIN_INT32,Constants.MAX_INT32)
	local bytes = 4
	if(buffer.len(self.buffer) < bytes) then warn("4 bytes is required to write an SignedInteger32") return end
	local success,outOfBounds = pcall(buffer.writei32,self.buffer,self.offset,number)
	if(outOfBounds) then warn(outOfBounds) return end
	self.offset += 4
end

--[[
	Write a Signed Interger 40-bit (-549755813888,549755813887)
	if the number exit the allowed value the number is automaticly clamped.
]]
function BufferComponent.WriteI40(self : Types.BufferComponentClass,number : number) : ()
	if(not number or type(number) ~= "number") then warn(`{type(number)} is not a number.`) return end
	number = math.clamp(math.modf(number),Constants.MIN_INT40,Constants.MAX_INT40)
	if(number < 0) then
		--[[
			if the number became negative we add 2^40 to it this will avoid the negative number to be positive
		]]
		number += 0x10000000000
	end
	local bytes = 5
	if(buffer.len(self.buffer) < bytes) then warn("5 bytes is required to write an SignedInteger40") return end
	local succes,outOfBounds = pcall(function()
		--0x100000000 is the actual max of a unsigned int 32 4294967296 (not 4294967295 to avoid formatting error)
		--0x100 is the actual max of unsigned int 8 = 256 (not 255 to avoid formatting error)
		--we write 5 bytes with compressing each byte to the buffer
		buffer.writeu8(self.buffer,self.offset,math.floor(number / 0x100000000) % 0x100)
		buffer.writeu8(self.buffer,self.offset + 1,bit32.extract(number % 0x100000000, 24, 8))
		buffer.writeu8(self.buffer,self.offset + 2,bit32.extract(number % 0x100000000, 16, 8))
		buffer.writeu8(self.buffer,self.offset + 3,bit32.extract(number % 0x100000000, 8, 8))
		buffer.writeu8(self.buffer,self.offset + 4,bit32.extract(number % 0x100000000, 0, 8))
	end)
	self.offset += 5
end

--[[
	Write a Signed Interger 48-bit (-140737488355328,140737488355327)
	if the number exit the allowed value the number is automaticly clamped.
]]
function BufferComponent.WriteI48(self : Types.BufferComponentClass,number : number) : ()
	if(not number or type(number) ~= "number") then warn(`{type(number)} is not a number.`) return end
	number = math.clamp(math.modf(number),Constants.MIN_INT48,Constants.MAX_INT48)
	if(number < 0) then
		--if the number became negative we add 2^48 to it this will avoid the negative number to be positive
		number += 0x1000000000000 -- 2^48
	end
	local bytes = 6
	if(buffer.len(self.buffer) < bytes) then warn("6 bytes is required to write an SignedInteger48") return end
	local success,outOfBounds = pcall(function()
		--0x10000000000 is 2^40 (UnsignedInt40)
		--0x10000000000 is 2^32 (UnsignedInt32)
		--0x100 is 2^8 (UnsignedInt8)
		--compressing all bytes and write them as unsigned int 8 to the buffer.
		local byte6 = math.floor(number / 0x10000000000) % 0x100  -- Bits 40-47
		local byte5 = math.floor(number / 0x100000000) % 0x100    -- Bits 32-39
		local byte4 = bit32.extract(number % 0x100000000, 24, 8)  -- Bits 24-31
		local byte3 = bit32.extract(number % 0x100000000, 16, 8)  -- Bits 16-23
		local byte2 = bit32.extract(number % 0x100000000, 8, 8)   -- Bits 8-15
		local byte1 = bit32.extract(number % 0x100000000, 0, 8)   -- Bits 0-7
		buffer.writeu8(self.buffer,self.offset,byte6)
		buffer.writeu8(self.buffer,self.offset + 1,byte5)
		buffer.writeu8(self.buffer,self.offset + 2,byte4)
		buffer.writeu8(self.buffer,self.offset + 3,byte3)
		buffer.writeu8(self.buffer,self.offset + 4,byte2)
		buffer.writeu8(self.buffer,self.offset + 5,byte1)
	end)
	if(outOfBounds) then warn(outOfBounds) return end
	self.offset += 6
end

--[[
	Write a Signed Interger 54-bit (-9007199254740992,9007199254740991)
	if the number exit the allowed value the number is automaticly clamped.
]]
function BufferComponent.WriteI54(self : Types.BufferComponentClass,number : number) : ()
	if(not number or type(number) ~= "number") then warn(`{type(number)} is not a number.`) return end
	number = math.clamp(math.modf(number),Constants.MIN_INT54,Constants.MAX_INT54)
	if(number < 0) then
		--if the number became negative we add 2^54 to it this will avoid the negative number to be positive
		number += Constants.MAX_UINT54
	end
	local bytes = 7
	if(buffer.len(self.buffer) < bytes) then warn("7 bytes is required to write an SignedInteger54") return end
	local success,outOfBounds = pcall(function()
		--0x1000000000000 is 2^48 (UnsignedInt48)
		--0x10000000000 is 2^40 (UnsignedInt40)
		--0x10000000000 is 2^32 (UnsignedInt32)
		--0x100 is 2^8 (UnsignedInt8)
		--compressing all bytes and write them as unsigned int 8 to the buffer.
		local byte7 = math.floor(number / 0x1000000000000) % 0x100 -- Bits 48-53
		local byte6 = math.floor(number / 0x10000000000) % 0x100   -- Bits 40-47
		local byte5 = math.floor(number / 0x100000000) % 0x100     -- Bits 32-39
		local byte4 = bit32.extract(number % 0x100000000, 24, 8)   -- Bits 24-31
		local byte3 = bit32.extract(number % 0x100000000, 16, 8)   -- Bits 16-23
		local byte2 = bit32.extract(number % 0x100000000, 8, 8)    -- Bits 8-15
		local byte1 = bit32.extract(number % 0x100000000, 0, 8)    -- Bits 0-7
		buffer.writeu8(self.buffer, self.offset, byte7)
		buffer.writeu8(self.buffer, self.offset + 1, byte6)
		buffer.writeu8(self.buffer, self.offset + 2, byte5)
		buffer.writeu8(self.buffer, self.offset + 3, byte4)
		buffer.writeu8(self.buffer, self.offset + 4, byte3)
		buffer.writeu8(self.buffer, self.offset + 5, byte2)
		buffer.writeu8(self.buffer, self.offset + 6, byte1)
	end)
	self.offset += 7
end

--[[
	Write a Unsigned Interger 8-bit (0,255)
	if the number exit the allowed value the number is automaticly clamped.
]]
function BufferComponent.WriteU8(self : Types.BufferComponentClass,number : number) : ()
	if(not number or type(number) ~= "number") then warn(`{type(number)} is not a number.`) return end
	number = math.clamp(math.modf(number),Constants.MIN_UINT,Constants.MAX_UINT8)
	local bytes = 1
	if(buffer.len(self.buffer) < bytes) then warn("1 bytes is required to write an UnsignedInteger8") return end
	local success,outOfBounds = pcall(buffer.writeu8,self.buffer,self.offset,number)
	if(outOfBounds) then warn(outOfBounds) return end
	self.offset += 1
end

--[[
	Write a Unsigned Interger 16-bit (0,65535)
	if the number exit the allowed value the number is automaticly clamped.
]]
function BufferComponent.WriteU16(self : Types.BufferComponentClass,number : number) : ()
	if(not number or type(number) ~= "number") then warn(`{type(number)} is not a number.`) return end
	number = math.clamp(math.modf(number),Constants.MIN_UINT,Constants.MAX_UINT16)
	local bytes = 2
	if(buffer.len(self.buffer) < bytes) then warn("2 bytes is required to write an UnsignedInteger16") return end
	local success,outOfBounds = pcall(buffer.writeu16,self.buffer,self.offset,number)
	if(outOfBounds) then warn(outOfBounds) return end
	self.offset += 2
end

--[[
	Write a Unsigned Interger 24-bit (0,16777215)
	if the number exit the allowed value the number is automaticly clamped.
]]
function BufferComponent.WriteU24(self : Types.BufferComponentClass,number : number)
	if(not number or type(number) ~= "number") then warn(`{type(number)} is not a number.`) return end
	number = math.max(Constants.MIN_UINT,math.min(Constants.MAX_UINT24,number))
	number = math.modf(number)
	local bytes = 3
	if(buffer.len(self.buffer) < bytes) then warn("3 bytes is required to write an UnsignedInteger24") return end
	local success,outOfBounds = pcall(function()
		--compressing all bytes and write them as unsigned int 8 to the buffer.
		buffer.writeu8(self.buffer,self.offset + 0,bit32.extract(number,16,8))
		buffer.writeu8(self.buffer,self.offset + 1,bit32.extract(number,8,8))
		buffer.writeu8(self.buffer,self.offset + 2,bit32.extract(number,0,8))
	end)
	if(outOfBounds) then warn(outOfBounds) return end
	self.offset += 3
end

--[[
	Write a Unsigned Interger 32-bit (0,4294967296)
	if the number exit the allowed value the number is automaticly clamped.
]]
function BufferComponent.WriteU32(self : Types.BufferComponentClass,number : number) : ()
	if(not number or type(number) ~= "number") then warn(`{type(number)} is not a number.`) return end
	number = math.clamp(math.modf(number),Constants.MIN_UINT,Constants.MAX_UINT32)
	local bytes = 4
	if(buffer.len(self.buffer) < bytes) then warn("4 bytes is required to write an UnsignedInteger32") return end
	local success,outOfBounds = pcall(buffer.writeu32,self.buffer,self.offset,number)
	if(outOfBounds) then warn(outOfBounds) return end
	self.offset += 4
end

--[[
	Write a Unsigned Interger 40-bit (0,1099511627775)
	if the number exit the allowed value the number is automaticly clamped.
]]
function BufferComponent.WriteU40(self : Types.BufferComponentClass,number : number) : ()
	if(not number or type(number) ~= "number") then warn(`{type(number)} is not a number.`) return end
	number = math.clamp(number,Constants.MIN_UINT,Constants.MAX_UINT40)
	--0x100000000 is the representation of 2^32 (e.g 4 bytes)
	--0x100 is the representation of 2^8 (e.g 1 bytes)
	local byte5 = math.floor(number / 0x100000000) % 0x100 
	local remainder = number % 0x100000000 -- % to get the remainder (e.g number % (2^32))
	local bytes = 5
	if(buffer.len(self.buffer) < bytes) then warn("5 bytes is required to write an UnsignedInteger40") return end
	local success,outOfBounds = pcall(function()
		--compressing all bytes and write them as unsigned int 8 to the buffer.
		buffer.writeu8(self.buffer, self.offset, byte5)
		buffer.writeu8(self.buffer, self.offset + 1, bit32.extract(remainder, 24, 8))
		buffer.writeu8(self.buffer, self.offset + 2, bit32.extract(remainder, 16, 8))
		buffer.writeu8(self.buffer, self.offset + 3, bit32.extract(remainder, 8, 8))
		buffer.writeu8(self.buffer, self.offset + 4, bit32.extract(remainder, 0, 8))
	end)
	if(outOfBounds) then warn(outOfBounds) return end
	self.offset += 5
end

--[[
	Write a Unsigned Interger 48-bit (0,281474976710655)
	if the number exit the allowed value the number is automaticly clamped.
]]
function BufferComponent.WriteU48(self : Types.BufferComponentClass,number : number) : ()
	if(not number or type(number) ~= "number") then warn(`{type(number)} is not a number.`) return end
	number = math.clamp(math.modf(number),Constants.MIN_UINT,Constants.MAX_UINT48)
	local bytes = 6
	if(buffer.len(self.buffer) < bytes) then warn("6 bytes is required to write an SignedInteger48") return end
	local success,outOfBounds = pcall(function()
		--0x10000000000 is 2^40 (UnsignedInt40)
		--0x10000000000 is 2^32 (UnsignedInt32)
		--0x100 is 2^8 (UnsignedInt8)
		--compressing all bytes and write them as unsigned int 8 to the buffer.
		local byte6 = math.floor(number / 0x10000000000) % 0x100  -- Bits 40-47
		local byte5 = math.floor(number / 0x100000000) % 0x100    -- Bits 32-39
		local byte4 = bit32.extract(number % 0x100000000, 24, 8)  -- Bits 24-31
		local byte3 = bit32.extract(number % 0x100000000, 16, 8)  -- Bits 16-23
		local byte2 = bit32.extract(number % 0x100000000, 8, 8)   -- Bits 8-15
		local byte1 = bit32.extract(number % 0x100000000, 0, 8)   -- Bits 0-7
		buffer.writeu8(self.buffer,self.offset,byte6)
		buffer.writeu8(self.buffer,self.offset + 1,byte5)
		buffer.writeu8(self.buffer,self.offset + 2,byte4)
		buffer.writeu8(self.buffer,self.offset + 3,byte3)
		buffer.writeu8(self.buffer,self.offset + 4,byte2)
		buffer.writeu8(self.buffer,self.offset + 5,byte1)
	end)
	if(outOfBounds) then warn(outOfBounds) return end
	self.offset += 6
end

--[[
	Write a Unsigned Interger 54-bit (0,18014398509481984)
	if the number exit the allowed value the number is automaticly clamped.
]]
function BufferComponent.WriteU54(self : Types.BufferComponentClass,number : number) : ()
	if(not number or type(number) ~= "number") then warn(`{type(number)} is not a number.`) return end
	number = math.clamp(math.modf(number),Constants.MIN_UINT,Constants.MAX_UINT54)
	local bytes = 7
	if(buffer.len(self.buffer) < bytes) then warn("7 bytes is required to write an SignedInteger54") return end
	local success,outOfBounds = pcall(function()
		--0x1000000000000 is 2^48 (UnsignedInt48)
		--0x10000000000 is 2^40 (UnsignedInt40)
		--0x10000000000 is 2^32 (UnsignedInt32)
		--0x100 is 2^8 (UnsignedInt8)
		--compressing all bytes and write them as unsigned int 8 to the buffer.
		local byte7 = math.floor(number / 0x1000000000000) % 0x100 -- Bits 48-53
		local byte6 = math.floor(number / 0x10000000000) % 0x100   -- Bits 40-47
		local byte5 = math.floor(number / 0x100000000) % 0x100     -- Bits 32-39
		local byte4 = bit32.extract(number % 0x100000000, 24, 8)   -- Bits 24-31
		local byte3 = bit32.extract(number % 0x100000000, 16, 8)   -- Bits 16-23
		local byte2 = bit32.extract(number % 0x100000000, 8, 8)    -- Bits 8-15
		local byte1 = bit32.extract(number % 0x100000000, 0, 8)    -- Bits 0-7
		buffer.writeu8(self.buffer, self.offset, byte7)
		buffer.writeu8(self.buffer, self.offset + 1, byte6)
		buffer.writeu8(self.buffer, self.offset + 2, byte5)
		buffer.writeu8(self.buffer, self.offset + 3, byte4)
		buffer.writeu8(self.buffer, self.offset + 4, byte3)
		buffer.writeu8(self.buffer, self.offset + 5, byte2)
		buffer.writeu8(self.buffer, self.offset + 6, byte1)
	end)
	self.offset += 7
end

--[[
	Write a String clamped to max 8 characters
	if the number exit the allowed value the number is automaticly clamped.
]]
function BufferComponent.WriteString8(self : Types.BufferComponentClass,value : string,len : number)
	assert(type(value) == "string" and type(len) == "number",`{type(value)} and {type(len)} is not valid please include a string and a number`)
	value = string.sub(value,1,math.clamp(len,Constants.MIN_STRING,Constants.MAX_STRING8))
	if(buffer.len(self.buffer) < len) then warn(`{len} bytes is required to write a String8`) return end
	local success,outOfBounds = pcall(buffer.writestring,self.buffer,self.offset,value,len)
	if(outOfBounds) then warn(outOfBounds) return end
	self.offset += len
end

--[[
	Write a String clamped to max 16 characters
	if the number exit the allowed value the number is automaticly clamped.
]]
function BufferComponent.WriteString16(self : Types.BufferComponentClass,value : string,len : number)
	assert(type(value) == "string" and type(len) == "number",`{type(value)} and {type(len)} is not valid please include a string and a number`)
	value = string.sub(value,1,math.clamp(len,Constants.MIN_STRING,Constants.MAX_STRING16))
	if(buffer.len(self.buffer) < len) then warn(`{len} bytes is required to write a String16`) return end
	local success,outOfBounds = pcall(buffer.writestring,self.buffer,self.offset,value,len)
	if(outOfBounds) then warn(outOfBounds) return end
	self.offset += len
end

--[[
	Write a String clamped to max 32 characters
	if the number exit the allowed value the number is automaticly clamped.
]]
function BufferComponent.WriteString32(self : Types.BufferComponentClass,value : string,len : number)
	assert(type(value) == "string" and type(len) == "number",`{type(value)} and {type(len)} is not valid please include a string and a number`)
	value = string.sub(value,1,math.clamp(len,Constants.MIN_STRING,Constants.MAX_STRING32))
	if(buffer.len(self.buffer) < len) then warn(`{len} bytes is required to write a String32`) return end
	local success,outOfBounds = pcall(buffer.writestring,self.buffer,self.offset,value,len)
	if(outOfBounds) then warn(outOfBounds) return end
	self.offset += len
end

--[[
	Write a String clamped to max 64 characters
	if the number exit the allowed value the number is automaticly clamped.
]]
function BufferComponent.WriteString64(self : Types.BufferComponentClass,value : string,len : number)
	assert(type(value) == "string" and type(len) == "number",`{type(value)} and {type(len)} is not valid please include a string and a number`)
	value = string.sub(value,1,math.clamp(len,Constants.MIN_STRING,Constants.MAX_STRING64))
	if(buffer.len(self.buffer) < len) then warn(`{len} bytes is required to write a String64`) return end
	local success,outOfBounds = pcall(buffer.writestring,self.buffer,self.offset,value,len)
	if(outOfBounds) then warn(outOfBounds) return end
	self.offset += len
end

--[[
	Write a String without taking care of the len this mean you can write a long string to buffer and it will write it entirely
	if the number exit the allowed value the number is automaticly clamped.
]]
function BufferComponent.WriteString(self : Types.BufferComponentClass,value : string)
	assert(type(value) == "string","please insert a string to write")
	if(buffer.len(self.buffer) < #value) then warn(`{#value} bytes is required to write a String`) return end
	local success,outOfBounds = pcall(buffer.writestring,self.buffer,self.offset,value,#value)
	if(outOfBounds) then warn(outOfBounds) return end
	self.offset += #value
end

--[[
	Write a boolean to buffer 
	this take only 1 byte for the buffer to write a boolean
	if you pass nill this mean false but if you pass other than false or nil it will mean true
]]
function BufferComponent.WriteBool1(self : Types.BufferComponentClass,value : any)
	if(buffer.len(self.buffer) < 1) then warn(`1 bytes is required to write a Bool1`) return end
	local success,outOfBounds = pcall(buffer.writebits,self.buffer,0,1,if(value) then 1 else 0)
	if(outOfBounds) then warn(outOfBounds) return end
end

--[[
	Write a 8 boolean to buffer 
	this take only 1 byte for the buffer to write a 8 boolean
	PLEASE THIS FUNCTION ONLY ACCEPT ARRAY LIKE : {10,false,15,...}
]]
function BufferComponent.WriteBool8(self : Types.BufferComponentClass,value : {any})
	assert(type(value) == "table","please insert an array")
	if(buffer.len(self.buffer) < 1) then warn(`1 bytes is required to write a Bool8`) return end
	local success,outOfBounds = pcall(function()
		for i = 1,8 do
			buffer.writebits(self.buffer,i-1,1,if(value[i]) then 1 else 0)
		end
	end)
	if(outOfBounds) then warn(outOfBounds) return end
end

--[[
	Write a Float 16-bit Interger to the buffer
	this can lost precisions for more precisions use F32 or F64
]]
function BufferComponent.WriteF16(self : Types.BufferComponentClass,number : number)
	if(not number or type(number) ~= "number") then warn(`{type(number)} is not a number.`) return end
	local bytes = 2
	if(buffer.len(self.buffer) < bytes) then warn(`2 bytes is required to write a Float16`) return end
	local success,outOfBounds = pcall(function()
		local uint16
		if number == 0 then
			uint16 = 0
		elseif number ~= number then  -- NaN
			uint16 = 0x7E00
		elseif number == math.huge then -- inf
			uint16 = 0x7C00
		elseif number == -math.huge then -- -inf
			uint16 = 0xFC00
		else
			--check the sign
			local sign = 0
			if number < 0 then
				sign = 1
				number = -number
			end
			--scientist representation.
			local exponent = math.floor(math.log(number, 2))
			local mantissa = number / (2 ^ exponent) - 1
			--adding the exponent to the float
			exponent = exponent + 15
			if exponent <= 0 then
				--denormalize the number
				mantissa = number / (2 ^ -14)
				exponent = 0
			elseif exponent >= 31 then
				--write inf
				uint16 = bit32.bor(bit32.lshift(sign, 15), 0x7C00)
				buffer.writeu16(self.buffer, self.offset, uint16)
				return
			end
			--construct the number into a float 16 bits
			uint16 = bit32.bor(
				bit32.lshift(sign, 15),
				bit32.lshift(exponent, 10),
				bit32.band(math.floor(mantissa * 1024), 0x3FF)
			)
		end
		--writing the number to the buffer
		buffer.writeu16(self.buffer, self.offset, uint16)
	end)
	if(outOfBounds) then warn(outOfBounds) return end
	self.offset += 2
end

--[[
	Write a Float 32-bit Interger to the buffer
]]
function BufferComponent.WriteF32(self : Types.BufferComponentClass,number : number)
	if(not number or type(number) ~= "number") then warn(`{type(number)} is not a number.`) return end
	number = math.clamp(number,Constants.MIN_FLOAT32,Constants.MAX_FLOAT32)
	local bytes = 4
	if(buffer.len(self.buffer) < bytes) then warn(`4 bytes is required to write a Float32`) return end
	local success,outOfBounds = pcall(buffer.writef32,self.buffer,self.offset,number)
	if(outOfBounds) then warn(outOfBounds) return end
	self.offset += 4
end

--[[
	Write a Float 64-bit Interger to the buffer
]]
function BufferComponent.WriteF64(self : Types.BufferComponentClass,number : number)
	if(not number or type(number) ~= "number") then warn(`{type(number)} is not a number.`) return end
	number = math.clamp(number,Constants.MIN_FLOAT64,Constants.MAX_FLOAT64)
	local bytes = 8
	if(buffer.len(self.buffer) < bytes) then warn(`8 bytes is required to write a Float64`) return end
	local success,outOfBounds = pcall(buffer.writef64,self.buffer,self.offset,number)
	if(outOfBounds) then warn(outOfBounds) return end
	self.offset += 8
end

--[[
	Write a 1-bit (0,1)
	this need 1 byte to buffer
]]
function BufferComponent.WriteU1(self : Types.BufferComponentClass,number : number)
	if(not number or type(number) ~= "number") then warn(`{type(number)} is not a number.`) return end
	number = math.clamp(math.modf(number),Constants.MIN_UINT,Constants.MAX_UINT1)
	local bytes = 1
	if(buffer.len(self.buffer) < bytes) then warn(`1 bytes is required to write a Unsigned Interger 1`) return end
	local success,outOfBounds = pcall(buffer.writebits,self.buffer,self.offset,1,number)
	if(outOfBounds) then warn(outOfBounds) return end
	self.offset += bytes
end

--[[
	Write a Instance to the instance_buffer.
]]
function BufferComponent.WriteInstance(self : Types.BufferComponentClass,Instance : Instance)
	if(not Instance or not Instance:IsA("Instance")) then warn(`{Instance} is not a Instance.`) return end
	table.insert(self.instance_buffer,Instance)
	self.instance_offset += 1
end

--[[
	Write a Vector2 to buffer.
]]
function BufferComponent.WriteVector2(self : Types.BufferComponentClass,vector2 : Vector2)
	assert(typeof(vector2) == "Vector2","vector2 must be a Vector2")
	local x = math.clamp(vector2.X,Constants.MIN_FLOAT64,Constants.MAX_FLOAT64)
	local y = math.clamp(vector2.Y,Constants.MIN_FLOAT64,Constants.MAX_FLOAT64)
	local bytes = 16
	if(buffer.len(self.buffer) < bytes) then warn(`16 bytes is required to write a Vector2`) return end
	local success,outOfBounds = pcall(function()
		buffer.writef64(self.buffer,self.offset,x)
		buffer.writef64(self.buffer,self.offset + 8,y)
	end)
	if(outOfBounds) then warn(outOfBounds) return end
	self.offset += bytes
end

--[[
	Write a Vector3 to buffer.
]]
function BufferComponent.WriteVector3(self : Types.BufferComponentClass,vector3 : Vector3)
	assert(typeof(vector3) == "Vector3","vector3 must be a Vector3")
	local x = math.clamp(vector3.X,Constants.MIN_FLOAT64,Constants.MAX_FLOAT64)
	local y = math.clamp(vector3.Y,Constants.MIN_FLOAT64,Constants.MAX_FLOAT64)
	local z = math.clamp(vector3.Z,Constants.MIN_FLOAT64,Constants.MAX_FLOAT64)
	local bytes = 24
	if(buffer.len(self.buffer) < bytes) then warn(`24 bytes is required to write a Vector3`) return end
	local success,outOfBounds = pcall(function()
		buffer.writef64(self.buffer,self.offset,x)
		buffer.writef64(self.buffer,self.offset + 8,y)
		buffer.writef64(self.buffer,self.offset + 16,z)
	end)
	if(outOfBounds) then warn(outOfBounds) return end
	self.offset += bytes
end

--[[
	Write a WriteVector2Int16 to buffer.
]]
function BufferComponent.WriteVector2Int16(self : Types.BufferComponentClass,vector2int16 : Vector2int16)
	assert(typeof(vector2int16) == "Vector2int16","vector2int16 must be a Vector2int16")
	local x = math.clamp(vector2int16.X,Constants.MIN_INT16,Constants.MAX_INT16)
	local y = math.clamp(vector2int16.Y,Constants.MIN_INT16,Constants.MAX_INT16)
	local bytes = 4
	if(buffer.len(self.buffer) < bytes) then warn(`4 bytes is required to write a Vector2Int16`) return end
	local success,outOfBounds = pcall(function()
		buffer.writei16(self.buffer,self.offset,x)
		buffer.writei16(self.buffer,self.offset + 2,y)
	end)
	if(outOfBounds) then warn(outOfBounds) return end
	self.offset += bytes
end

--[[
	Write a WriteVector3Int16 to buffer.
]]
function BufferComponent.WriteVector3Int16(self : Types.BufferComponentClass,vector3int16 : Vector3int16)
	assert(typeof(vector3int16) == "Vector3int16","vector3int16 must be a Vector3int16")
	local x = math.clamp(vector3int16.X,Constants.MIN_INT16,Constants.MAX_INT16)
	local y = math.clamp(vector3int16.Y,Constants.MIN_INT16,Constants.MAX_INT16)
	local z = math.clamp(vector3int16.Z,Constants.MIN_INT16,Constants.MAX_INT16)
	local bytes = 6
	if(buffer.len(self.buffer) < bytes) then warn(`6 bytes is required to write a Vector3Int16`) return end
	local success,outOfBounds = pcall(function()
		buffer.writei16(self.buffer,self.offset,x)
		buffer.writei16(self.buffer,self.offset + 2,y)
		buffer.writei16(self.buffer,self.offset + 4,z)
	end)
	if(outOfBounds) then warn(outOfBounds) return end
	self.offset += bytes
end

--[[
	Write a WriteCFrame to buffer.
]]
function BufferComponent.WriteCFrame(self : Types.BufferComponentClass,CF : CFrame)
	assert(typeof(CF) == "CFrame","CF must be a CFrame")
	local bytes = 92
	if(buffer.len(self.buffer) < bytes) then warn(`92 bytes is required to write a CFrame`) return end
	local success,outOfBounds = pcall(function()
		local components = {CF:GetComponents()}
		for i = 0, 11 do
			buffer.writef64(self.buffer, self.offset + (i * 8), components[i + 1])
		end
	end)
	if(outOfBounds) then warn(outOfBounds) return end
	self.offset += bytes
end

--[[
	Write a WriteLossyCFrame to buffer.
	this cframe have less precisions but allow compressions if needed.
]]
function BufferComponent.WriteLossyCFrame(self : Types.BufferComponentClass,CF : CFrame)
	assert(typeof(CF) == "CFrame","CF must be a CFrame")
	local bytes = 48
	if(buffer.len(self.buffer) < bytes) then warn(`48 bytes is required to write a LossyCFrame`) return end
	local success,outOfBounds = pcall(function()
		local components = {CF:GetComponents()}
		for i = 0, 11 do
			buffer.writef32(self.buffer, self.offset + (i * 4), components[i + 1])
		end
	end)
	if(outOfBounds) then warn(outOfBounds) return end
	self.offset += bytes
end

--[[
	Write a Udim to buffer.
]]
function BufferComponent.WriteUdim(self : Types.BufferComponentClass,udim : UDim)
	assert(typeof(udim) == "UDim","Udim must be a Udim")
	local Scale = math.clamp(udim.Scale,Constants.MIN_FLOAT32,Constants.MAX_FLOAT32)
	local Offset = math.clamp(udim.Offset,Constants.MIN_FLOAT32,Constants.MAX_FLOAT32)
	local bytes = 8
	if(buffer.len(self.buffer) < bytes) then warn(`8 bytes is required to write a Udim`) return end
	local success,outOfBounds = pcall(function()
		buffer.writef32(self.buffer,self.offset,Scale)
		buffer.writef32(self.buffer,self.offset + 4,Offset)
	end)
	if(outOfBounds) then warn(outOfBounds) return end
	self.offset += bytes
end

--[[
	Write a Udim2 to buffer.
]]
function BufferComponent.WriteUdim2(self : Types.BufferComponentClass,udim2 : UDim2)
	assert(typeof(udim2) == "UDim2","Udim2 must be a Udim2")
	local ScaleX,ScaleY = math.clamp(udim2.X.Scale,Constants.MIN_FLOAT32,Constants.MAX_FLOAT32),math.clamp(udim2.Y.Scale,Constants.MIN_FLOAT32,Constants.MAX_FLOAT32)
	local OffsetX,OffsetY = math.clamp(udim2.X.Offset,Constants.MIN_FLOAT32,Constants.MAX_FLOAT32),math.clamp(udim2.Y.Offset,Constants.MIN_FLOAT32,Constants.MAX_FLOAT32)
	local bytes = 16
	if(buffer.len(self.buffer) < bytes) then warn(`16 bytes is required to write a Udim2`) return end
	local success,outOfBounds = pcall(function()
		buffer.writef32(self.buffer,self.offset,ScaleX)
		buffer.writef32(self.buffer,self.offset + 4,ScaleY)
		buffer.writef32(self.buffer,self.offset + 8,OffsetX)
		buffer.writef32(self.buffer,self.offset + 12,OffsetY)
	end)
	if(outOfBounds) then warn(outOfBounds) return end
	self.offset += bytes
end

--[[
	Write a Color3 to buffer.
]]
function BufferComponent.WriteColor3(self : Types.BufferComponentClass,color : Color3)
	assert(typeof(color) == "Color3","color must be a Color3")
	local bytes = 12
	local r = math.clamp(color.R,Constants.MIN_FLOAT32,Constants.MAX_FLOAT32)
	local g = math.clamp(color.G,Constants.MIN_FLOAT32,Constants.MAX_FLOAT32)
	local b = math.clamp(color.B,Constants.MIN_FLOAT32,Constants.MAX_FLOAT32)
	if(buffer.len(self.buffer) < bytes) then warn(`12 bytes is required to write a Color3`) return end
	local success,outOfBounds = pcall(function()
		buffer.writef32(self.buffer,self.offset,r)
		buffer.writef32(self.buffer,self.offset + 4,g)
		buffer.writef32(self.buffer,self.offset + 8,b)
	end)
	if(outOfBounds) then warn(outOfBounds) return end
	self.offset += bytes
end

--[[
	Write a Rect to buffer.
]]
function BufferComponent.WriteRect(self : Types.BufferComponentClass,rect : Rect)
	assert(typeof(rect) == "Rect","rect must be a Rect")
	local bytes = 32
	if(buffer.len(self.buffer) < bytes) then warn(`32 bytes is required to write a Rect`) return end
	self:WriteVector2(rect.Min)
	self:WriteVector2(rect.Max)
end

--[[
	Write a Region3 to buffer.
]]
function BufferComponent.WriteRegion3(self : Types.BufferComponentClass,region3 : Region3)
	assert(typeof(region3) == "Region3","region3 must be a Region3")
	local bytes = 116
	if(buffer.len(self.buffer) < bytes) then warn(`116 bytes is required to write a Region3`) return end
	local cframe = region3.CFrame
	local size = region3.Size
	self:WriteCFrame(cframe)
	self:WriteVector3(size)
end

--[[
	Write a Region3int16 to buffer.
]]
function BufferComponent.WriteRegion3int16(self : Types.BufferComponentClass,region3int16 : Region3int16)
	assert(typeof(region3int16) == "Region3int16","region3int16 must be a Region3int16")
	local bytes = 12
	if(buffer.len(self.buffer) < bytes) then warn(`12 bytes is required to write a region3int16`) return end
	local max = region3int16.Max
	local min = region3int16.Min
	self:WriteVector3Int16(max)
	self:WriteVector3Int16(min)
end

-->-----------------------READER-----------------------------<--

--[[
	Read a SignedInteger8-bit from the buffer
]]
function BufferComponent.ReadI8(self : Types.BufferComponentClass,offset : number?)
	local offset = (type(offset) == "number" and offset <= self.offset) and offset or self.offset
	return buffer.readi8(self.buffer,offset)
end

--[[
	Read a SignedInteger16-bit from the buffer
]]
function BufferComponent.ReadI16(self : Types.BufferComponentClass,offset : number?)
	local offset = (type(offset) == "number" and offset <= self.offset) and offset or self.offset
	return buffer.readi16(self.buffer,offset)
end

--[[
	Read a SignedInteger24-bit from the buffer
]]
function BufferComponent.ReadI24(self : Types.BufferComponentClass,offset : number?)
	local offset = (type(offset) == "number" and offset <= self.offset) and offset or self.offset
	local b1 = buffer.readu8(self.buffer,offset)
	local b2 = buffer.readu8(self.buffer,offset + 1)
	local b3 = buffer.readu8(self.buffer,offset + 2)
	local value = bit32.bor(bit32.lshift(b1,16),bit32.lshift(b2,8),b3)
	if b1 >= 0x80 then -- 2^7
		value = value - 0x1000000 -- 2^24
	end
	return value
end

--[[
	Read a SignedInteger32-bit from the buffer
]]
function BufferComponent.ReadI32(self : Types.BufferComponentClass,offset : number?)
	local offset = (type(offset) == "number" and offset <= self.offset) and offset or self.offset
	return buffer.readi32(self.buffer,offset)
end

--[[
	Read a SignedInteger40-bit from the buffer
]]
function BufferComponent.ReadI40(self : Types.BufferComponentClass,offset : number?)
	local offset = (type(offset) == "number" and offset <= self.offset) and offset or self.offset
	local b1 = buffer.readu8(self.buffer,offset)
	local b2 = buffer.readu8(self.buffer,offset + 1)
	local b3 = buffer.readu8(self.buffer,offset + 2)
	local b4 = buffer.readu8(self.buffer,offset + 3)
	local b5 = buffer.readu8(self.buffer,offset + 4)
	--0x8000000000 is 2^40
	--0x100000000 is 2^32
	--0x1000000 is 2^24
	--0x10000 is 2^16
	--0x100 is 2^8
	local value = 
		b1 * 0x100000000 + -- 32 bits
		b2 * 0x1000000 + -- 24 bits
		b3 * 0x10000 + -- 16 bits
		b4 * 0x100 + -- 8 bits
		b5
	if(value >= 0x8000000000) then
		--[[
			0x10000000000 is the actual max of a unsigned int 40 (e.g 1099511627776)
			so this will convert the actual number into a negatif signed int 40 number
		]]
		value -= 0x10000000000
	end
	return value
end

--[[
	Read a SignedInteger48-bit from the buffer
]]
function BufferComponent.ReadI48(self : Types.BufferComponentClass,offset : number?)
	local offset = (type(offset) == "number" and offset <= self.offset) and offset or self.offset
	local b1 = buffer.readu8(self.buffer,offset)
	local b2 = buffer.readu8(self.buffer,offset + 1)
	local b3 = buffer.readu8(self.buffer,offset + 2)
	local b4 = buffer.readu8(self.buffer,offset + 3)
	local b5 = buffer.readu8(self.buffer,offset + 4)
	local b6 = buffer.readu8(self.buffer,offset + 5)
	--0x10000000000 is 2^40
	--0x100000000 is 2^32
	--0x1000000 is 2^24
	--0x10000 is 2^16
	--0x100 is 2^8
	local value = 
		b1 * 0x10000000000 + -- 40 bits
		b2 * 0x100000000 + -- 32 bits
		b3 * 0x1000000 + -- 24 bits
		b4 * 0x10000 + -- 16 bits
		b5 * 0x100 + -- 8 bits
		b6
	if(value > 0x800000000000) then --value >= 0x800000000000
		value -= 0x1000000000000
	end
	return value
end

--[[
	Read a SignedInteger54-bit from the buffer
]]
function BufferComponent.ReadI54(self : Types.BufferComponentClass,offset : number?)
	local offset = (type(offset) == "number" and offset <= self.offset) and offset or self.offset
	local byte7 = buffer.readu8(self.buffer, offset)
	local byte6 = buffer.readu8(self.buffer, offset + 1)
	local byte5 = buffer.readu8(self.buffer, offset + 2)
	local byte4 = buffer.readu8(self.buffer, offset + 3)
	local byte3 = buffer.readu8(self.buffer, offset + 4)
	local byte2 = buffer.readu8(self.buffer, offset + 5)
	local byte1 = buffer.readu8(self.buffer, offset + 6)
	--0x1000000000000 is 2^48
	--0x10000000000 is 2^40
	--0x100000000 is 2^32
	--0x1000000 is 2^24
	--0x10000 is 2^16
	--0x100 is 2^8
	local value = 
		byte7 * 0x1000000000000 +  -- 48 bits
		byte6 * 0x10000000000 +    -- 40 bits
		byte5 * 0x100000000 +      -- 32 bits
		byte4 * 0x1000000 +        -- 24 bits
		byte3 * 0x10000 +          -- 16 bits
		byte2 * 0x100 +            -- 8 bits
		byte1
	--0x20000000000000 is 2^53
	if value >= 0x20000000000000 then
		value -= 0x40000000000000 -- 2^54
	end
	return value
end

--[[
	Read a UnsignedInteger8-bit from the buffer
]]
function BufferComponent.ReadU8(self : Types.BufferComponentClass,offset : number?)
	local offset = (type(offset) == "number" and offset <= self.offset) and offset or self.offset
	return buffer.readu8(self.buffer,offset)
end

--[[
	Read a UnsignedInteger16-bit from the buffer
]]
function BufferComponent.ReadU16(self : Types.BufferComponentClass,offset : number?)
	local offset = (type(offset) == "number" and offset <= self.offset) and offset or self.offset
	return buffer.readu16(self.buffer,offset)
end

--[[
	Read a UnsignedInteger24-bit from the buffer
]]
function BufferComponent.ReadU24(self : Types.BufferComponentClass,offset : number?)
	local offset = (type(offset) == "number" and offset <= self.offset) and offset or self.offset
	local b1 = buffer.readu8(self.buffer,offset)
	local b2 = buffer.readu8(self.buffer,offset + 1)
	local b3 = buffer.readu8(self.buffer,offset + 2)
	local value = bit32.bor(bit32.lshift(b1,16),bit32.lshift(b2,8),b3)
	return value
end

--[[
	Read a UnsignedInteger32-bit from the buffer
]]
function BufferComponent.ReadU32(self : Types.BufferComponentClass,offset : number?)
	local offset = (type(offset) == "number" and offset <= self.offset) and offset or self.offset
	return buffer.readu32(self.buffer,offset)
end

--[[
	Read a UnsignedInteger40-bit from the buffer
]]
function BufferComponent.ReadU40(self : Types.BufferComponentClass,offset : number?)
	local offset = (type(offset) == "number" and offset <= self.offset) and offset or self.offset
	local b1 = buffer.readu8(self.buffer,offset)
	local b2 = buffer.readu8(self.buffer,offset + 1)
	local b3 = buffer.readu8(self.buffer,offset + 2)
	local b4 = buffer.readu8(self.buffer,offset + 3)
	local b5 = buffer.readu8(self.buffer,offset + 4)
	--0x100000000 is 2^32
	--0x1000000 is 2^24
	--0x10000 is 2^16
	--0x100 is 2^8
	local value =
		b1 * 0x100000000 + -- 32 bits
		b2 * 0x1000000 + -- 24 bits
		b3 * 0x10000 + -- 16 bits
		b4 * 0x100 + -- 8 bits
		b5
	return value
end

--[[
	Read a UnsignedInteger48-bit from the buffer
]]
function BufferComponent.ReadU48(self : Types.BufferComponentClass,offset : number?)
	local offset = (type(offset) == "number" and offset <= self.offset) and offset or self.offset
	local b1 = buffer.readu8(self.buffer,offset)
	local b2 = buffer.readu8(self.buffer,offset + 1)
	local b3 = buffer.readu8(self.buffer,offset + 2)
	local b4 = buffer.readu8(self.buffer,offset + 3)
	local b5 = buffer.readu8(self.buffer,offset + 4)
	local b6 = buffer.readu8(self.buffer,offset + 5)
	--0x10000000000 is 2^40
	--0x100000000 is 2^32
	--0x1000000 is 2^24
	--0x10000 is 2^16
	--0x100 is 2^8
	local value = 
		b1 * 0x10000000000 + -- 40 bits
		b2 * 0x100000000 +  -- 32 bits
		b3 * 0x1000000 +  -- 24 bits
		b4 * 0x10000 + -- 16 bits
		b5 * 0x100 +  -- 8 bits
		b6
	return value
end

--[[
	Read a UnsignedInteger54-bit from the buffer
]]
function BufferComponent.ReadU54(self : Types.BufferComponentClass,offset : number?)
	local offset = (type(offset) == "number" and offset <= self.offset) and offset or self.offset
	local byte7 = buffer.readu8(self.buffer, offset)
	local byte6 = buffer.readu8(self.buffer, offset + 1)
	local byte5 = buffer.readu8(self.buffer, offset + 2)
	local byte4 = buffer.readu8(self.buffer, offset + 3)
	local byte3 = buffer.readu8(self.buffer, offset + 4)
	local byte2 = buffer.readu8(self.buffer, offset + 5)
	local byte1 = buffer.readu8(self.buffer, offset + 6)
	--0x1000000000000 is 2^48
	--0x10000000000 is 2^40
	--0x100000000 is 2^32
	--0x1000000 is 2^24
	--0x10000 is 2^16
	--0x100 is 2^8
	local value = 
		byte7 * 0x1000000000000 +  -- 48 bits
		byte6 * 0x10000000000 +    -- 40 bits
		byte5 * 0x100000000 +      -- 32 bits
		byte4 * 0x1000000 +        -- 24 bits
		byte3 * 0x10000 +          -- 16 bits
		byte2 * 0x100 +            -- 8 bits
		byte1
	return value
end

--[[
	Read a String from the buffer
	the first argument is the len and the second one is the offset (both are optional but i recommend to use it)
	if the len is not the default value 1 please dont set the len upper than the string itself

	exemple
	local str = "123"
	local len = 4

	the len is upper then the str string and this will thrown a string overflow.
]]
function BufferComponent.ReadString(self : Types.BufferComponentClass,len : number?,offset : number?)
	local offset = (type(offset) == "number" and offset <= self.offset) and offset or self.offset
	local len = (type(len) == "number" and len <= self.offset) and len or Constants.MIN_STRING
	return buffer.readstring(self.buffer,offset,len)
end

--[[
	Read a boolean-1bit from the buffer 
	this return a boolean not a number.
]]
function BufferComponent.ReadBool1(self : Types.BufferComponentClass,offset : number?)
	local offset = (type(offset) == "number" and offset <= self.offset) and offset or self.offset
	local boolean_bits : boolean = (buffer.readbits(self.buffer,offset,1) == 1) and true or false
	return boolean_bits
end

--[[
	Read 8 boolean from the buffer
	this return a table with a FUNCTION

	.values = sorted list of all booleans.
	:majority() -> return true if the list contain more true otherwise it return false.
]]
function BufferComponent.ReadBool8(self : Types.BufferComponentClass,offset : number?)
	local offset = (type(offset) == "number" and offset <= self.offset) and offset or self.offset
	local booleans = {}
	for i = 0,7 do
		local boolean_bits : boolean = (buffer.readbits(self.buffer,offset + i,1) == 1) and true or false
		table.insert(booleans,boolean_bits)
	end
	return {
		value = booleans,
		majority = function() : boolean
			local teamTrue = 0
			local teamFalse = 0
			for i,bool in next,booleans do
				if(bool == true) then
					teamTrue += 1
				else
					teamFalse += 1
				end
			end
			return (teamTrue > teamFalse) and true or false
		end,
	}
end

--[[
	Read a Float16-bit from the buffer
]]
function BufferComponent.ReadF16(self : Types.BufferComponentClass,offset : number?)
	local offset = (type(offset) == "number" and offset <= self.offset) and offset or self.offset
	--read the current number
	local uint16 = buffer.readu16(self.buffer, offset)
	--get the sign, exponent and mantissa
	local sign = bit32.rshift(uint16, 15)
	local exponent = bit32.band(bit32.rshift(uint16, 10), 0x1F)
	local mantissa = bit32.band(uint16, 0x3FF)
	--special case
	if exponent == 0 then
		if mantissa == 0 then
			--return 0
			return sign == 0 and 0 or -0
		else
			--return a denormalize number
			local value = mantissa / 1024 * (2 ^ -14)
			return sign == 0 and value or -value
		end
	elseif exponent == 31 then
		if mantissa == 0 then
			--return inf
			return sign == 0 and math.huge or -math.huge
		else
			--return NaN
			return 0/0
		end
	end
	--return the normal number with precision lost.
	local value = (1 + mantissa / 1024) * (2 ^ (exponent - 15))
	return sign == 0 and value or -value
end

--[[
	Read a Float32-bit from the buffer
]]
function BufferComponent.ReadF32(self : Types.BufferComponentClass,offset : number?)
	local offset = (type(offset) == "number" and offset <= self.offset) and offset or self.offset
	return buffer.readf32(self.buffer,offset)
end

--[[
	Read a Float64-bit from the buffer
]]
function BufferComponent.ReadF64(self : Types.BufferComponentClass,offset : number?)
	local offset = (type(offset) == "number" and offset <= self.offset) and offset or self.offset
	return buffer.readf64(self.buffer,offset)
end

--[[
	Read a Instance from the instance_buffer
]]
function BufferComponent.ReadInstance(self : Types.BufferComponentClass,instance_offset : number?)
	local instance_offset = (type(instance_offset) == "number" and instance_offset <= self.instance_offset) and instance_offset or self.instance_offset
	return self.instance_buffer[instance_offset]
end

--[[
	Read a ReadVector2 from the buffer
]]
function BufferComponent.ReadVector2(self : Types.BufferComponentClass,offset : number?)
	local offset = (type(offset) == "number" and offset <= self.offset) and offset or self.offset
	return Vector2.new(buffer.readf64(self.buffer,offset),buffer.readf64(self.buffer,offset + 8))
end

--[[
	Read a ReadVector2int16 from the buffer
]]
function BufferComponent.ReadVector2int16(self : Types.BufferComponentClass,offset : number?)
	local offset = (type(offset) == "number" and offset <= self.offset) and offset or self.offset
	return Vector2int16.new(buffer.readi16(self.buffer,offset),buffer.readi16(self.buffer,offset + 2))
end

--[[
	Read a ReadVector3 from the buffer
]]
function BufferComponent.ReadVector3(self : Types.BufferComponentClass,offset : number?)
	local offset = (type(offset) == "number" and offset <= self.offset) and offset or self.offset
	return Vector3.new(buffer.readf64(self.buffer,offset),buffer.readf64(self.buffer,offset + 8),buffer.readf64(self.buffer,offset + 16))
end

--[[
	Read a ReadVector3int16 from the buffer
]]
function BufferComponent.ReadVector3int16(self : Types.BufferComponentClass,offset : number?)
	local offset = (type(offset) == "number" and offset <= self.offset) and offset or self.offset
	return Vector3int16.new(buffer.readi16(self.buffer,offset),buffer.readi16(self.buffer,offset + 2),buffer.readi16(self.buffer,offset + 4))
end

--[[
	Read a ReadCFrame from the buffer
]]
function BufferComponent.ReadCFrame(self : Types.BufferComponentClass,offset : number?)
	local offset = (type(offset) == "number" and offset <= self.offset) and offset or self.offset
	local components = {}
	for i = 0, 11 do
		components[i + 1] = buffer.readf64(self.buffer, offset + (i * 8))
	end
	return CFrame.new(table.unpack(components))
end

--[[
	Read a LossyCFrame from the buffer
]]
function BufferComponent.ReadLossyCFrame(self : Types.BufferComponentClass,offset : number?)
	local offset = (type(offset) == "number" and offset <= self.offset) and offset or self.offset
	local components = {}
	for i = 0, 11 do
		components[i + 1] = buffer.readf32(self.buffer, offset + (i * 4))
	end
	return CFrame.new(table.unpack(components))
end

--[[
	Read a Udim from the buffer
]]
function BufferComponent.ReadUdim(self : Types.BufferComponentClass,offset : number?)
	local offset = (type(offset) == "number" and offset <= self.offset) and offset or self.offset
	local scale = buffer.readf32(self.buffer,self.offset)
	local offset = buffer.readf32(self.buffer,self.offset+4)
	return UDim.new(scale,offset)
end

--[[
	Read a Udim2 from the buffer
]]
function BufferComponent.ReadUdim2(self : Types.BufferComponentClass,offset : number?)
	local offset = (type(offset) == "number" and offset <= self.offset) and offset or self.offset
	local scaleX,scaleY = buffer.readf32(self.buffer,offset),buffer.readf32(self.buffer,offset + 4)
	local offsetX,offsetY = buffer.readf32(self.buffer,offset + 8),buffer.readf32(self.buffer,offset + 12)
	return UDim2.new(scaleX,offsetX,scaleY,offsetY)
end

--[[
	Read a Color3 from the buffer
]]
function BufferComponent.ReadColor3(self : Types.BufferComponentClass,offset : number?)
	local offset = (type(offset) == "number" and offset <= self.offset) and offset or self.offset
	local r = buffer.readf32(self.buffer,offset)*255
	local g = buffer.readf32(self.buffer,offset+4)*255
	local b = buffer.readf32(self.buffer,offset+8)*255
	return Color3.fromRGB(r,g,b)
end

--[[
	Read a Rect from the buffer
]]
function BufferComponent.ReadRect(self : Types.BufferComponentClass,offset : number?)
	local offset = (type(offset) == "number" and offset <= self.offset) and offset or self.offset
	local max = self:ReadVector2(offset)
	local min = self:ReadVector2(offset + 16)
	return Rect.new(min,max)
end

--[[
	Read a Region3 from the buffer
]]
function BufferComponent.ReadRegion3(self : Types.BufferComponentClass,offset : number?)
	local offset = (type(offset) == "number" and offset <= self.offset) and offset or self.offset
	local cframe = self:ReadCFrame(offset)
	local size = self:ReadVector3(offset + 92)
	local halfSize = size * 0.5
	local min = cframe.Position - halfSize
	local max = cframe.Position + halfSize
	return Region3.new(min,max)
end

--[[
	Read a Region3int16 from the buffer
]]
function BufferComponent.ReadRegion3int16(self : Types.BufferComponentClass,offset : number?)
	local offset = (type(offset) == "number" and offset <= self.offset) and offset or self.offset
	local max = self:ReadVector3int16(offset)
	local min = self:ReadVector3int16(offset + 6)
	return Region3int16.new(min,max)
end

-->-----------------------Cursor/Buffer-----------------------------<--

--[[
	return the actual offset of the buffer
]]
function BufferComponent.GetOffset(self : Types.BufferComponentClass)
	return self.offset
end

--[[
	return the actual instance offset of the buffer
]]
function BufferComponent.GetInstanceOffset(self : Types.BufferComponentClass)
	return self.instance_offset
end

--[[
	return the current buffer
]]
function BufferComponent.GetBuffer(self : Types.BufferComponentClass)
	return self.buffer
end

--[[
	return the current instance buffer
]]
function BufferComponent.GetInstanceBuffer(self : Types.BufferComponentClass)
	return self.instance_buffer
end

--[[
	return the actual buffer size (not the written data size)
]]
function BufferComponent.GetBufferSize(self : Types.BufferComponentClass)
	return buffer.len(self.buffer)
end

--[[
	clear the buffer to a new one with the same size
	the offset is also set to 0.
]]
function BufferComponent.clear(self : Types.BufferComponentClass)
	local buffer_blank = buffer.create(buffer.len(self.buffer))
	self.buffer = buffer_blank
	self.offset = 0
end

--[[
	Destroy the actual BufferComponent.
	You can't use the BufferComponent after this.
]]
function BufferComponent.Destroy(self : Types.BufferComponentClass)
	self.buffer = nil :: any
	self.instance_buffer = nil :: any
	self.instance_offset = nil :: any
	self.offset = nil :: any
	table.clear(self)
	setmetatable(self,nil)
	self = nil :: any
end

return BufferConstructor
