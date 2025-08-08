# Buffer

## What next

- add a way to write and read any enums type
- add a way to get the actual written data size and be able to shrink the buffer.
- add a way to write and read a Signed Interger 1 (1-bit) (values: -1,1)

## Logs

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
- added .fromString(), create a BufferComponent with the given string
- added .tostring(), convert the BufferComponent to a string .fromString (data are not lost) can be called to transform the string back to a BufferComponent

Version : 1.0
- Released the module
