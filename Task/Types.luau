export type Task<T...> = {
	__ID : string,
	__connected_task : {},
	Add : (self : Task<T...>,T : __Executable) -> (),
	AddPromise : (self : Task<T...>,T : __Executable) -> (),
	Execute : (self : Task<T...>,callback : (...any) -> ...any) -> ...any,
	GetTaskAtIndex : (self : Task<T...>,T : number) -> __Executable,
	Destroy : (self : Task<T...>) -> (),
	clean : (self : Task<T...>) -> (),
	Clean : (self : Task<T...>) -> (),
	Disconnect : (self : Task<T...>) -> (),
	destroy : (self : Task<T...>) -> (),
	execute : (self : Task<T...>,callback : (...any) -> ...any) -> ...any,
	add : (self : Task<T...>,T : __Executable) -> (),
	addPromise : (self : Task<T...>,T : __Executable) -> (),
	getTaskAtIndex : (self : Task<T...>,T : number) -> __Executable,
}

export type __Executable = 
	RBXScriptConnection 
	| {any} 
	| () -> () 
	| Instance


return nil
