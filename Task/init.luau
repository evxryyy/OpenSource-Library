local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local GENERIC_CLEANUP_FUNCTIONS = {"Destroy","Disconnect","DisconnectAll","DoCleaning","Clean"}

local Types = require(script.Types)

local function checkClass(t : {}) : boolean
	if(not t) then return false end
	if(typeof(t) ~= "table") then return false end
	local generic_function = nil
	for _,g in next,GENERIC_CLEANUP_FUNCTIONS do
		if(typeof(t[g]) == "function") then
			generic_function = g
			break
		end
	end
	if(not generic_function) then 
		return false
	elseif(generic_function) then
		return true
	end
	return false
end

local function clean_connectionCach(_task : any)
	if(not _task) then return end
	if(typeof(_task) == "RBXScriptConnection") then
		_task:Disconnect()
		_task = nil
	elseif(typeof(_task) == "Instance" and _task.Destroy ~= nil) then
		_task:Destroy()
		_task = nil
	elseif(typeof(_task) == "table") then
		local generic_function = nil
		for _,g in next,GENERIC_CLEANUP_FUNCTIONS do
			if(typeof(_task[g]) == "function") then
				generic_function = g
				break
			end
		end
		if(not generic_function) then 
		else
			_task[generic_function](_task)
		end
	elseif(typeof(_task) == "function") then _task() _task = nil
	elseif(typeof(_task) == "thread") then
		local succes = pcall(task.cancel,_task)
		if(not succes) then succes = pcall(coroutine.close,_task) end
		_task = nil
	end
end

local _task_ = {}

_task_.__index = function(self,index)
	if(_task_[index]) then
		return _task_[index]
	else
		return self.__connected_task[index]
	end
end

_task_.__newindex = function(self,index,value)
	if(_task_[index]) then return end
	local previousTask = self.__connected_task[index]
	if(previousTask == value) then
		return
	end
	self.__connected_task[index] = value
	if(previousTask) then
		clean_connectionCach(previousTask)
	end	
end

_task_.IsTask = function(self)
	if(not self) then return false end
	if(not self.__ID) then return false end
	return true
end

function _task_.new<T...>() : Types.Task<T...>
	local self = setmetatable({
		__ID = HttpService:GenerateGUID(false);
		__connected_task = {};
	},_task_)
	return self
end

_task_.AddPromise = function(self,_promise)
	if(not _task_.IsTask(self)) then return end
	if(_promise:getStatus() == "Cancelled" or _promise:getStatus() == "Rejected") then return _promise end
	local _new_promise = _promise.resolved(_promise)
	local index = #self.__connected_task+1
	table.insert(self.__connected_task,_new_promise)
	_new_promise:finally(function()
		table.remove(self.__connected_task,index)
	end)
end

_task_.Add = function(self,_task)
	if(not _task_.IsTask(self)) then return end
	assert(_task,"task can't be nil or false")
	if(typeof(_task) == "table" and not checkClass(_task)) then
		warn(("_Task_ :: %s will be discarded cause not avaible cleaning function found."):format(type(_task)))
		return
	end
	table.insert(self.__connected_task,_task)
end

_task_.GetTaskAtIndex = function(self,index : number)
	if(not _task_.IsTask(self)) then return end
	assert(type(index) == "number","index must be a number")
	local clamp_index = math.clamp(index,1,math.clamp(#self.__connected_task,1,#self.__connected_task+1))
	return self.__connected_task[clamp_index] :: Types.Task<{any}>
end

_task_.Execute = function(self,fn : (any) -> any) : any
	if(not _task_.IsTask(self)) then return end
	if(type(fn) ~= "function") then return end
	return fn()
end

_task_.Destroy = function(self)
	if(not self) then return end
	if(not self.__ID) then return end
	for i,_task in next,self.__connected_task do
		clean_connectionCach(_task)
	end
	table.clear(self.__connected_task)
	setmetatable(self,nil)
end

_task_.clean = _task_.Destroy
_task_.Clean = _task_.Destroy
_task_.Disconnect = _task_.Destroy

return _task_
