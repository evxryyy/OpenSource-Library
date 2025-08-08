export type BufferComponentClass = {
	offset : number,
	instance_offset : number,
	buffer : buffer,
	instance_buffer : { Instance },
	allocate : (self : BufferComponentClass,size : number) -> (),
	--------------------------Writers--------------------------
	--Signed Interger.
	WriteI8 : (self : BufferComponentClass,value : number) -> (),
	WriteI16 : (self : BufferComponentClass,value : number) -> (),
	WriteI24 : (self : BufferComponentClass,value : number) -> (),
	WriteI32 : (self : BufferComponentClass,value : number) -> (),
	WriteI40 : (self : BufferComponentClass,value : number) -> (),
	WriteI48 : (self : BufferComponentClass,value : number) -> (),
	WriteI54 : (self : BufferComponentClass,value : number) -> (),
	--Unsigned Interger.
	WriteU1 : (self : BufferComponentClass,value : number) -> (),
	WriteU8 : (self : BufferComponentClass,value : number) -> (),
	WriteU16 : (self : BufferComponentClass,value : number) -> (),
	WriteU24 : (self : BufferComponentClass,value : number) -> (),
	WriteU32 : (self : BufferComponentClass,value : number) -> (),
	WriteU40 : (self : BufferComponentClass,value : number) -> (),
	WriteU48 : (self : BufferComponentClass,value : number) -> (),
	WriteU54 : (self : BufferComponentClass,value : number) -> (),
	--String.
	WriteString8 : (self : BufferComponentClass,value : string,len : number) -> (),
	WriteString16 : (self : BufferComponentClass,value : string,len : number) -> (),
	WriteString32 : (self : BufferComponentClass,value : string,len : number) -> (),
	WriteString : (self : BufferComponentClass,value : string) -> (),
	--Booleans.
	WriteBool1 : (self : BufferComponentClass,value : any) -> (),
	WriteBool8 : (self : BufferComponentClass,value : {any}) -> (),
	--Floats.
	WriteF16 : (self : BufferComponentClass,number : number) -> (),
	WriteF32 : (self : BufferComponentClass,number : number) -> (),
	WriteF64 : (self : BufferComponentClass,number : number) -> (),
	--Instances.
	WriteInstance : (self : BufferComponentClass,Instance : Instance) -> (),
	--Vectors.
	WriteVector2 : (self : BufferComponentClass,vector2 : Vector2) -> (),
	WriteVector2Int16 : (self : BufferComponentClass,vector2int16 : Vector2int16) -> (),
	WriteVector3 : (self : BufferComponentClass,vector3 : Vector3) -> (),
	WriteVector3Int16 : (self : BufferComponentClass,vector3int16 : Vector3int16) -> (),
	--CFrames.
	WriteCFrame : (self : BufferComponentClass,CF : CFrame) -> (),
	WriteLossyCFrame : (self : BufferComponentClass,CF : CFrame) -> (),
	--Udims.
	WriteUdim : (self : BufferComponentClass,udim : UDim) -> (),
	WriteUdim2 : (self : BufferComponentClass,udim2 : UDim2) -> (),
	--Colors.
	WriteColor3 : (self : BufferComponentClass,color : Color3) -> (),
	--Rects.
	WriteRect : (self : BufferComponentClass,rect : Rect) -> (),
	--Regions3
	WriteRegion3 : (self : BufferComponentClass,region3 : Region3) -> (),
	WriteRegion3int16 : (self : BufferComponentClass,region3int16 : Region3int16) -> (),
	--------------------------Readers--------------------------
	--Signed Interger.
	ReadI8 : (self : BufferComponentClass,offset : number?) -> number,
	ReadI16 : (self : BufferComponentClass,offset : number?) -> number,
	ReadI24 : (self : BufferComponentClass,offset : number?) -> number,
	ReadI32 : (self : BufferComponentClass,offset : number?) -> number,
	ReadI40 : (self : BufferComponentClass,offset : number?) -> number,
	ReadI48 : (self : BufferComponentClass,offset : number?) -> number,
	ReadI54 : (self : BufferComponentClass,offset : number?) -> number,
	--Unsigned Interger.
	ReadU1 : (self : BufferComponentClass,offset : number?) -> number,
	ReadU8 : (self : BufferComponentClass,offset : number?) -> number,
	ReadU16 : (self : BufferComponentClass,offset : number?) -> number,
	ReadU24 : (self : BufferComponentClass,offset : number?) -> number,
	ReadU32 : (self : BufferComponentClass,offset : number?) -> number,
	ReadU40 : (self : BufferComponentClass,offset : number?) -> number,
	ReadU48 : (self : BufferComponentClass,offset : number?) -> number,
	ReadU54 : (self : BufferComponentClass,offset : number?) -> number,
	--String.
	ReadString : (self : BufferComponentClass,len : number?,offset : number?) -> string,
	--Booleans.
	ReadBool1 : (self : BufferComponentClass,offset : number?) -> boolean,
	ReadBool8 : (self : BufferComponentClass,offset : number?) -> {
		values : {boolean},
		majority : () -> boolean,
	},
	--Floats.
	ReadF16 : (self : BufferComponentClass,offset : number?) -> number,
	ReadF32 : (self : BufferComponentClass,offset : number?) -> number,
	ReadF64 : (self : BufferComponentClass,offset : number?) -> number,
	--Instances.
	ReadInstance : (self : BufferComponentClass,offset : number?) -> Instance,
	--Vectors.
	ReadVector2 : (self : BufferComponentClass,offset : number?) -> Vector2,
	ReadVector2int16 : (self : BufferComponentClass,offset : number?) -> Vector2int16,
	ReadVector3 : (self : BufferComponentClass,offset : number?) -> Vector3,
	ReadVector3int16 : (self : BufferComponentClass,offset : number?) -> Vector3int16,
	--CFrames.
	ReadCFrame : (self : BufferComponentClass,offset : number?) -> CFrame,
	ReadLossyCFrame : (self : BufferComponentClass,offset : number?) -> CFrame,
	--Udims.
	ReadUdim : (self : BufferComponentClass,offset : number?) -> UDim,
	ReadUdim2 : (self : BufferComponentClass,offset : number?) -> UDim2,
	--Colors.
	ReadColor3 : (self : BufferComponentClass,offset : number?) -> Color3,
	--Rects.
	ReadRect : (self : BufferComponentClass,offset : number?) -> Rect,
	--Regions3
	ReadRegion3 : (self : BufferComponentClass,offset : number?) -> Region3,
	ReadRegion3int16 : (self : BufferComponentClass,offset : number?) -> Region3int16,
}

return nil
