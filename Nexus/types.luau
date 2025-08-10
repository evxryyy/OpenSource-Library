--Type annotations for the Nexus library

export type RemoteConfiguration = {
	Name : string,
	RemoteType : "RemoteEvent" | "RemoteFunction" | "UnreliableRemoteEvent",
	Validator : (Player : Player,...any) -> boolean??,
}

export type ServerComponent = {
	remote : RemoteEvent | RemoteFunction | UnreliableRemoteEvent,
	config : RemoteConfiguration,
	server_event : RBXScriptConnection?,
	FireClient : (self : ServerComponent,Player : Player,...any) -> (),
	InvokeClient : (self : ServerComponent,Player : Player,...any) -> ...any,
	OnServerEvent : (self : ServerComponent,callback : (Player : Player,...any) -> ()) -> RBXScriptConnection,
	Handle : (self : ServerComponent,callback : (Player : Player,...any) -> ()) -> (),
	Disconnect : (self : ServerComponent) -> (),
	Destroy : (self : ServerComponent) -> (),
}

export type ClientComponent = {
	remote : RemoteEvent? | RemoteFunction? | UnreliableRemoteEvent?,
	config : RemoteConfiguration,
	server_event : RBXScriptConnection?,
	FireServer : (self : ServerComponent,...any) -> (),
	InvokeServer : (self : ServerComponent,...any) -> ...any,
	OnClientEvent : (self : ClientComponent,callback : (...any) -> ()) -> RBXScriptConnection,
	Handle : (self : ClientComponent,callback : (...any) -> ()) -> (),
	Disconnect : (self : ClientComponent) -> (),
	Destroy : (self : ClientComponent) -> (),
}

return nil
