--[[
	author : evxry_ll
	
	Task: A class for managing and cleaning up tasks and resources.
	
	This script implements a Task management system that provides a unified way to handle cleanup of various Roblox objects and connections.
	It's particularly useful for preventing memory leaks by ensuring all connections, instances,
	and other resources are properly cleaned up when no longer needed.
]]

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

-- List of common cleanup method names to look for in objects
-- These are standard methods used by various libraries for cleanup/destruction
local GENERIC_CLEANUP_FUNCTIONS = {"Destroy","Disconnect","DisconnectAll","DoCleaning","Clean"}

-- Import type definitions
local Types = require(script.Types)

--[[
	Checks if a table has a cleanup method from our generic list
	@param t - The table to check
	@return boolean - True if the table has at least one cleanup method
]]
local function checkClass(t : {}) : boolean
	-- Validate input exists
	if(not t) then return false end
	-- Ensure input is a table
	if(typeof(t) ~= "table") then return false end
	-- Search for any cleanup function in the table
	local generic_function = nil
	for _,g in next,GENERIC_CLEANUP_FUNCTIONS do
		if(typeof(t[g]) == "function") then
			generic_function = g
			break
		end
	end
	-- Return true if we found a cleanup function, false otherwise
	if(not generic_function) then 
		return false
	elseif(generic_function) then
		return true
	end
	return false
end

--[[
	Universal cleanup function that handles different types of objects
	Supports: RBXScriptConnection, Instance, tables with cleanup methods, functions, and threads
	@param _task - The object to clean up
]]
local function clean_connectionCach(_task : any)
	-- Exit early if nothing to clean
	if(not _task) then return end
	-- Handle RBXScriptConnection (event connections)
	if(typeof(_task) == "RBXScriptConnection") then
		_task:Disconnect()
		_task = nil
		-- Handle Roblox Instances
	elseif(typeof(_task) == "Instance" and _task.Destroy ~= nil) then
		_task:Destroy()
		_task = nil
		-- Handle tables with cleanup methods
	elseif(typeof(_task) == "table") then
		-- Find which cleanup method the table has
		local generic_function = nil
		for _,g in next,GENERIC_CLEANUP_FUNCTIONS do
			if(typeof(_task[g]) == "function") then
				generic_function = g
				break
			end
		end
		-- Call the cleanup method if found
		if(not generic_function) then 
			-- No cleanup method found, do nothing
		else
			_task[generic_function](_task)
		end
		-- Handle cleanup functions (just call them)
	elseif(typeof(_task) == "function") then 
		_task() 
		_task = nil
		-- Handle threads/coroutines
	elseif(typeof(_task) == "thread") then
		-- Try to cancel the task first (newer API)
		local succes = pcall(task.cancel,_task)
		-- If that fails, try to close the coroutine (older API)
		if(not succes) then succes = pcall(coroutine.close,_task) end
		_task = nil
	end
end

-- Main Task class definition
local _task_ = {}

-- Metamethod: Handle property access
-- Allows accessing both Task methods and connected task properties
_task_.__index = function(self,index)
	-- First check if it's a Task method
	if(_task_[index]) then
		return _task_[index]
	else
		-- Otherwise, return from connected tasks
		return self.__connected_task[index]
	end
end

-- Metamethod: Handle property assignment
-- Automatically cleans up old tasks when replacing them
_task_.__newindex = function(self,index,value)
	-- Prevent overwriting Task methods
	if(_task_[index]) then return end
	-- Get the task currently at this index
	local previousTask = self.__connected_task[index]
	-- Don't do anything if setting the same value
	if(previousTask == value) then
		return
	end
	-- Set the new value
	self.__connected_task[index] = value
	-- Clean up the previous task if it existed
	if(previousTask) then
		clean_connectionCach(previousTask)
	end	
end

--[[
	Validates if an object is a Task instance
	@param self - The object to check
	@return boolean - True if it's a valid Task
]]
_task_.IsTask = function(self)
	if(not self) then return false end
	if(not self.__ID) then return false end
	return true
end

--[[
	Constructor: Creates a new Task instance
	@return Task - A new Task object with unique ID and empty task list
]]
function _task_.new<T...>() : Types.Task<T...>
	local self = setmetatable({
		__ID = HttpService:GenerateGUID(false); -- Unique identifier
		__connected_task = {}; -- Array of managed tasks
	},_task_)
	return self
end

--[[
	Adds a Promise to the task list and automatically removes it when resolved
	@param self - The Task instance
	@param _promise - The Promise to add
]]
_task_.AddPromise = function(self,_promise)
	-- Validate Task instance
	if(not _task_.IsTask(self)) then return end
	-- Don't add already failed promises
	if(_promise:getStatus() == "Cancelled" or _promise:getStatus() == "Rejected") then return _promise end
	-- Create a new promise that resolves when the original does
	local _new_promise = _promise.resolved(_promise)
	local index = #self.__connected_task+1
	table.insert(self.__connected_task,_new_promise)
	-- Auto-remove the promise from our list when it completes
	_new_promise:finally(function()
		table.remove(self.__connected_task,index)
	end)
end

--[[
	Adds any supported task type to be managed
	@param self - The Task instance
	@param _task - The task to add (connection, instance, function, etc.)
]]
_task_.Add = function(self,_task)
	-- Validate Task instance
	if(not _task_.IsTask(self)) then return end
	-- Task cannot be nil or false
	assert(_task,"task can't be nil or false")
	-- Warn if adding a table without cleanup methods
	if(typeof(_task) == "table" and not checkClass(_task)) then
		warn(("_Task_ :: %s will be discarded cause not avaible cleaning function found."):format(type(_task)))
		return
	end
	-- Add to the task list
	table.insert(self.__connected_task,_task)
end

--[[
	Retrieves a task at a specific index (1-based, clamped to valid range)
	@param self - The Task instance
	@param index - The index to retrieve
	@return any - The task at the given index
]]
_task_.GetTaskAtIndex = function(self,index : number)
	-- Validate Task instance
	if(not _task_.IsTask(self)) then return end
	-- Validate index type
	assert(type(index) == "number","index must be a number")
	-- Clamp index to valid range
	local clamp_index = math.clamp(index,1,math.clamp(#self.__connected_task,1,#self.__connected_task+1))
	return self.__connected_task[clamp_index] :: Types.Task<{any}>
end

--[[
	Executes a function and returns its result
	Utility method for running code within the Task context
	@param self - The Task instance
	@param callback - The function to execute
	@return any - The function's return value
]]
_task_.Execute = function(self,callback : (...any) -> ...any) : ...any
	-- Validate Task instance
	if(not _task_.IsTask(self)) then return end
	-- Validate function type
	if(type(callback) ~= "function") then return end
	-- Execute and return result
	return callback()
end

--[[
	Main cleanup method - destroys all managed tasks and the Task instance itself
	@param self - The Task instance to destroy
]]
_task_.Destroy = function(self)
	-- Validate object exists
	if(not self) then return end
	if(not self.__ID) then return end
	-- Clean up all connected tasks
	for i,_task in next,self.__connected_task do
		clean_connectionCach(_task)
	end
	-- Clear the task list
	table.clear(self.__connected_task)
	-- Remove metatable to prevent further use
	setmetatable(self,nil)
end

-- Alias methods for flexibility and compatibility with different naming conventions
_task_.clean = _task_.Destroy
_task_.Clean = _task_.Destroy
_task_.Disconnect = _task_.Destroy
_task_.destroy = _task_.Destroy
_task_.execute = _task_.Execute
_task_.add = _task_.Add
_task_.addPromise = _task_.AddPromise
_task_.getTaskAtIndex =  _task_.GetTaskAtIndex
_task_.isTask = _task_.IsTask

return _task_
