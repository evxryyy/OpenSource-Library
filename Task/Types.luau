export type Task<T...> = {
	__ID : string,
	__connected_task : {},
	Add : (self : Task<T...>,T : __Executable) -> (),
	AddPromise : (self : Task<T...>,T : __Executable) -> (),
	Execute : (self : Task<T...>,T : () -> ()) -> ();
	GetTaskAtIndex : (self : Task<T...>,T : number) -> __Executable,
	Destroy : (self : Task<T...>) -> (),
	clean : (self : Task<T...>) -> (),
	Clean : (self : Task<T...>) -> (),
	Disconnect : (self : Task<T...>) -> (),
}

export type __Executable = 
	RBXScriptConnection 
	| {any} 
	| () -> () 
	| Instance


return nil
