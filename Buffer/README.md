# Buffer

## What next

## Logs

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
