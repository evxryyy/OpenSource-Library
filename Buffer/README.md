# Buffer

## What next

## Logs

Version : 1.3
- fixed a bug where ReadU1 was not available on the current version
- change type annotation to 
  ```lua
   export type BufferComponentClass = typeof(setmetatable({} :: {
  	offset : number,
  	instance_offset : number,
  	buffer : buffer,
  	instance_buffer : { Instance },
  	allocate : (self : BufferComponentClass,size : number) -> (),
   },BufferComponent))
  ```
- added alot of alias for the buffer component and the constructor
  ```lua
  --Constructor alias
  BufferConstructor.new = BufferConstructor.create
  BufferConstructor.New = BufferConstructor.create
  BufferConstructor.From = BufferConstructor.from
  BufferConstructor.FromString = BufferConstructor.fromString
  BufferConstructor.Tostring = BufferConstructor.tostring
  
  --Component alias
  BufferComponent.Allocate = BufferComponent.allocate
  
  --[Writer] signed interger alias
  BufferComponent.writeI8 = BufferComponent.WriteI8
  BufferComponent.writei8 = BufferComponent.WriteI8
  BufferComponent.writeI16 = BufferComponent.WriteI16
  BufferComponent.writei16 = BufferComponent.WriteI16
  BufferComponent.writeI24 = BufferComponent.WriteI24
  BufferComponent.writei24 = BufferComponent.WriteI24
  BufferComponent.writeI32 = BufferComponent.WriteI32
  BufferComponent.writei32 = BufferComponent.WriteI32
  BufferComponent.writeI40 = BufferComponent.WriteI40
  BufferComponent.writei40 = BufferComponent.WriteI40
  BufferComponent.writeI48 = BufferComponent.WriteI48
  BufferComponent.writei48 = BufferComponent.WriteI48
  BufferComponent.writeI54 = BufferComponent.WriteI54
  BufferComponent.writei54 = BufferComponent.WriteI54
  
  --[Writer] unsigned interger alias
  BufferComponent.writeU1 = BufferComponent.WriteU1
  BufferComponent.writeu1 = BufferComponent.WriteU1
  BufferComponent.writeU8 = BufferComponent.WriteU8
  BufferComponent.writeu8 = BufferComponent.WriteU8
  BufferComponent.writeU16 = BufferComponent.WriteU16
  BufferComponent.writeu16 = BufferComponent.WriteU16
  BufferComponent.writeU24 = BufferComponent.WriteU24
  BufferComponent.writeu24 = BufferComponent.WriteU24
  BufferComponent.writeU32 = BufferComponent.WriteU32
  BufferComponent.writeu32 = BufferComponent.WriteU32
  BufferComponent.writeU40 = BufferComponent.WriteU40
  BufferComponent.writeu40 = BufferComponent.WriteU40
  BufferComponent.writeU48 = BufferComponent.WriteU48
  BufferComponent.writeu48 = BufferComponent.WriteU48
  BufferComponent.writeU54 = BufferComponent.WriteU54
  BufferComponent.writeu54 = BufferComponent.WriteU54
  
  --[Writer] float interger alias
  BufferComponent.writeF16 = BufferComponent.WriteF16
  BufferComponent.writef16 = BufferComponent.WriteF16
  BufferComponent.writeF32 = BufferComponent.WriteF32
  BufferComponent.writef32 = BufferComponent.WriteF32
  BufferComponent.writeF64 = BufferComponent.WriteF64
  BufferComponent.writef64 = BufferComponent.WriteF64
  
  --[Writer] string alias
  BufferComponent.writeString8 = BufferComponent.WriteString8
  BufferComponent.writestring8 = BufferComponent.WriteString8
  BufferComponent.writeString16 = BufferComponent.WriteString16
  BufferComponent.writestring16 = BufferComponent.WriteString16
  BufferComponent.writeString32 = BufferComponent.WriteString32
  BufferComponent.writestring32 = BufferComponent.WriteString32
  BufferComponent.writeString64 = BufferComponent.WriteString64
  BufferComponent.writestring64 = BufferComponent.WriteString64
  BufferComponent.writeString = BufferComponent.WriteString
  BufferComponent.writestring = BufferComponent.WriteString
  
  --[Writer] instance alias
  BufferComponent.writeInstance = BufferComponent.WriteInstance
  BufferComponent.writeinstance = BufferComponent.WriteInstance
  
  --[Writer] roblox type alias
  BufferComponent.writeVector2 = BufferComponent.WriteVector2
  BufferComponent.writevector2 = BufferComponent.WriteVector2
  BufferComponent.writeVector2int16 = BufferComponent.WriteVector2Int16
  BufferComponent.writevector2int16 = BufferComponent.WriteVector2Int16
  BufferComponent.writeVector3 = BufferComponent.WriteVector3
  BufferComponent.writevector3 = BufferComponent.WriteVector3
  BufferComponent.writeVector3int16 = BufferComponent.WriteVector3Int16
  BufferComponent.writevector3int16 = BufferComponent.WriteVector3Int16
  BufferComponent.writeCFrame = BufferComponent.WriteCFrame
  BufferComponent.writecframe = BufferComponent.WriteCFrame
  BufferComponent.writeLossyCFrame = BufferComponent.WriteLossyCFrame
  BufferComponent.writelossyCFrame = BufferComponent.WriteLossyCFrame
  BufferComponent.writeUdim = BufferComponent.WriteUdim
  BufferComponent.writeudim = BufferComponent.WriteUdim
  BufferComponent.writeUdim2 = BufferComponent.WriteUdim2
  BufferComponent.writeudim2 = BufferComponent.WriteUdim2
  BufferComponent.writeColor3 = BufferComponent.WriteColor3
  BufferComponent.writecolor3 = BufferComponent.WriteColor3
  BufferComponent.writeRect = BufferComponent.WriteRect
  BufferComponent.writerect = BufferComponent.WriteRect
  BufferComponent.writeRegion3 = BufferComponent.WriteRegion3
  BufferComponent.writeregion3 = BufferComponent.WriteRegion3
  BufferComponent.writeRegion3int16 = BufferComponent.WriteRegion3int16
  BufferComponent.writeregion3int16 = BufferComponent.WriteRegion3int16
  
  --[Reader] signed interger alias
  BufferComponent.readI8 = BufferComponent.ReadI8
  BufferComponent.readi8 = BufferComponent.ReadI8
  BufferComponent.readI16 = BufferComponent.ReadI16
  BufferComponent.readi16 = BufferComponent.ReadI16
  BufferComponent.readI24 = BufferComponent.ReadI24
  BufferComponent.readi24 = BufferComponent.ReadI24
  BufferComponent.readI32 = BufferComponent.ReadI32
  BufferComponent.readi32 = BufferComponent.ReadI32
  BufferComponent.readI40 = BufferComponent.ReadI40
  BufferComponent.readi40 = BufferComponent.ReadI40
  BufferComponent.readI48 = BufferComponent.ReadI48
  BufferComponent.readi48 = BufferComponent.ReadI48
  BufferComponent.readI54 = BufferComponent.ReadI54
  BufferComponent.readi54 = BufferComponent.ReadI54
  
  --[Reader] unsigned interger alias
  BufferComponent.readU1 = BufferComponent.ReadU1
  BufferComponent.readu1 = BufferComponent.ReadU1
  BufferComponent.readU8 = BufferComponent.ReadU8
  BufferComponent.readu8 = BufferComponent.ReadU8
  BufferComponent.readU16 = BufferComponent.ReadU16
  BufferComponent.readu16 = BufferComponent.ReadU16
  BufferComponent.readU24 = BufferComponent.ReadU24
  BufferComponent.readu24 = BufferComponent.ReadU24
  BufferComponent.readU32 = BufferComponent.ReadU32
  BufferComponent.readu32 = BufferComponent.ReadU32
  BufferComponent.readU40 = BufferComponent.ReadU40
  BufferComponent.readu40 = BufferComponent.ReadU40
  BufferComponent.readU48 = BufferComponent.ReadU48
  BufferComponent.readu48 = BufferComponent.ReadU48
  BufferComponent.readU54 = BufferComponent.ReadU54
  BufferComponent.readu54 = BufferComponent.ReadU54
  
  --[Reader] float interger alias
  BufferComponent.readF16 = BufferComponent.ReadF16
  BufferComponent.readf16 = BufferComponent.ReadF16
  BufferComponent.readF32 = BufferComponent.ReadF32
  BufferComponent.readf32 = BufferComponent.ReadF32
  BufferComponent.readF64 = BufferComponent.ReadF64
  BufferComponent.readf64 = BufferComponent.ReadF64
  
  --[Reader] string alias
  BufferComponent.readString = BufferComponent.ReadString
  BufferComponent.readstring = BufferComponent.ReadString
  
  --[Reader] instance alias
  BufferComponent.readInstance = BufferComponent.ReadInstance
  BufferComponent.readinstance = BufferComponent.ReadInstance
  
  --[Reader] roblox type alias
  BufferComponent.readVector2 = BufferComponent.ReadVector2
  BufferComponent.readvector2 = BufferComponent.ReadVector2
  BufferComponent.readVector2int16 = BufferComponent.ReadVector2int16
  BufferComponent.readvector2int16 = BufferComponent.ReadVector2int16
  BufferComponent.readVector3 = BufferComponent.ReadVector3
  BufferComponent.readvector3 = BufferComponent.ReadVector3
  BufferComponent.readVector3int16 = BufferComponent.ReadVector3int16
  BufferComponent.readvector3int16 = BufferComponent.ReadVector3int16
  BufferComponent.readCFrame = BufferComponent.ReadCFrame
  BufferComponent.readcframe = BufferComponent.ReadCFrame
  BufferComponent.readLossyCFrame = BufferComponent.ReadLossyCFrame
  BufferComponent.readlossyCFrame = BufferComponent.ReadLossyCFrame
  BufferComponent.readUdim = BufferComponent.ReadUdim
  BufferComponent.readudim = BufferComponent.ReadUdim
  BufferComponent.readUdim2 = BufferComponent.ReadUdim2
  BufferComponent.readudim2 = BufferComponent.ReadUdim2
  BufferComponent.readColor3 = BufferComponent.ReadColor3
  BufferComponent.readcolor3 = BufferComponent.ReadColor3
  BufferComponent.readRect = BufferComponent.ReadRect
  BufferComponent.readrect = BufferComponent.ReadRect
  BufferComponent.readRegion3 = BufferComponent.ReadRegion3
  BufferComponent.readregion3 = BufferComponent.ReadRegion3
  BufferComponent.readRegion3int16 = BufferComponent.ReadRegion3int16
  BufferComponent.readregion3int16 = BufferComponent.ReadRegion3int16
  
  --[Cursor] alias
  BufferComponent.getOffset = BufferComponent.GetOffset
  BufferComponent.getoffset = BufferComponent.GetOffset
  BufferComponent.getInstanceOffset = BufferComponent.GetInstanceOffset
  BufferComponent.getinstanceoffset = BufferComponent.GetInstanceOffset
  
  --[Buffer] alias
  BufferComponent.getBuffer = BufferComponent.GetBuffer
  BufferComponent.getbuffer = BufferComponent.GetBuffer
  BufferComponent.getInstanceBuffer = BufferComponent.GetInstanceBuffer
  BufferComponent.getinstancebuffer = BufferComponent.GetInstanceBuffer
  BufferComponent.getBufferSize = BufferComponent.GetBufferSize
  BufferComponent.getbuffersize = BufferComponent.GetBufferSize
  
  --[Lifecycle] alias
  BufferComponent.Clear = BufferComponent.clear
  BufferComponent.Destroy = BufferComponent.Destroy
  ```

Version : 1.2.2
- updated comments.

Version : 1.2.1
- fixed Buffer.init.spec

Version : 1.2
- added GetOffset() : number, get the current offset of the buffer
- added GetInstanceOffset() : number,get the current instance offset of the instance buffer
- added GetBuffer() : buffer,get the actual buffer
- added GetInstanceBuffer() : { Instance }, get the actual instance buffer
- added GetBufferSize() : number,get the buffer size (not the written data size)
- added clear(), clear the current buffer and the offset too
- added Destroy(), destroy the current BufferComponent

Version : 1.1.1
- fixed Buffer.init.spec

Version : 1.1
- added .__tostring(), for BufferComponent when "print" is called
- added .fromString(), create a BufferComponent with the given string (data are not lost)
- added .tostring(), convert the BufferComponent to a string .fromString (data are not lost) can be called to transform the string back to a BufferComponent

Version : 1.0
- Released the module
