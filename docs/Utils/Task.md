# Task

Get Task : [Task](https://github.com/evxryyy/OpenEvxEngine/releases/tag/task)

This module handle Instance/Metatable/Connection with clean up function ex 

```lua
    {"Destroy","Disconnect","DisconnectAll","DoCleaning","Clean"}
```

More clean up function can be set directly from the module itself

## Get Started


=== "Connection"
    ```lua
        local ReplicatedStorage = game:GetService("ReplicatedStorage")

        local Task = require(ReplicatedStorage.Task)
        --[[
            Task.new() return a new TaskClass
        ]]
        local TaskHandler = Task.new()
        TaskHandler:Add(workspace.Baseplate:GetPropertyChangedSignal("Position"):Connect(function(...: any) 
            -- do stuff here
        end)) -- Connect the function to the handler
        TaskHandler:Destroy() -- Connection(s) will be disconnected
    ```

=== "Instance"
    ```lua
        local ReplicatedStorage = game:GetService("ReplicatedStorage")

        local Task = require(ReplicatedStorage.Task)
        --[[
            Task.new() return a new TaskClass
        ]]
        local TaskHandler = Task.new()
        TaskHandler:Add(workspace.Baseplate) -- Attach the Baseplate to the task handler
        TaskHandler:Destroy() -- Baseplate will be destroyed
    ```

=== "Class"
    ```lua
        local ReplicatedStorage = game:GetService("ReplicatedStorage")

        local Task = require(ReplicatedStorage.Task)

        --Create a random strict class
        local class = {
            Destroy = function()
                print("Cleaning...")
            end,
        }
        setmetatable(class,{
            __index = function(t,k)
                warn(`Can't get Class::{type(k)}`)
            end,
            __newindex = function(t,k,v)
                warn(`Can't set Class:{type(k)} (not a valid member)`)
            end,
            
        })
        --[[
            Task.new() return a new TaskClass
        ]]
        local TaskHandler = Task.new()
        TaskHandler:Add(class) -- Added "Class" to the task handler
        TaskHandler:Destroy() -- Will print "Cleaning..."
    ```
    !!! info "Class without clean up function"
        If you try to pass a class without a single clean up function the class will be discarded and not added to the task handler.

## Using Signal

Exemples:

The used signal is the from sleitnick

link: [Signal Module](https://github.com/Sleitnick/RbxUtil/blob/main/modules/signal/init.luau)

=== "Code"
    ```lua
        local ReplicatedStorage = game:GetService("ReplicatedStorage")

        local Task = require(ReplicatedStorage.Task)
        local Signal = require(ReplicatedStorage.Signal)

        local TaskHandler = Task.new()
        local signal = Signal.new()

        TaskHandler:Add(signal:Connect(function(...)
            print(...) -- Will print hello signal
        end))

        signal:Fire("Hello Signal")

        TaskHandler:Clean()

        signal:Fire("Goodbye Signal") -- This will never show
    ```

## Using Promise

For promise you should prefer to use :AddPromise instead of Add

=== "Code"
    ```lua
        local ReplicatedStorage = game:GetService("ReplicatedStorage")

        local Task = require(ReplicatedStorage.Task)
        local Promise = require(ReplicatedStorage.Promise)

        local TaskHandler = Task.new()
        TaskHandler:AddPromise(Promise.new(function(resolve,reject,onCancel) 
            -- Promise stuff here
        end))
        TaskHandler:Clean()
    ```

## Executing function

The :Execute function allow you to directly call a function (only) instead of calling this function the clean up state

=== "Code"
```lua
    local ReplicatedStorage = game:GetService("ReplicatedStorage")

    local Task = require(ReplicatedStorage.Task)
    local Promise = require(ReplicatedStorage.Promise)

    local TaskHandler = Task.new()

    TaskHandler:Add(function()
        print("hi but on the clean up state") -- print after :Clean()
    end)

    TaskHandler:Execute(function()
        print("hi") -- print instantly
    end)

    task.wait(1)

    TaskHandler:Clean()
```

## GetTaskAtIndex(index : number)

You can get the added connection/class/instance/function from the target index

=== "Code"
    ```lua
    local ReplicatedStorage = game:GetService("ReplicatedStorage")

    local Task = require(ReplicatedStorage.Task)
    local Promise = require(ReplicatedStorage.Promise)

    local TaskHandler = Task.new()

    TaskHandler:Add(function()
        print("hi but on the clean up state") -- print after :Clean()
    end)

    TaskHandler:GetTaskAtIndex(1)() -- print "hi but on the clean up state"

    task.wait(1)

    TaskHandler:Clean()
    ```

    !!! info "Calling function with GetTaskAtIndex"
        if you call a returned function from GetTaskAtIndex at the CleanUp state of Task the same function will be called

##  IsTask()

Check if the current passed table is a task Class

=== "Code"
    ```lua
    local ReplicatedStorage = game:GetService("ReplicatedStorage")

    local Task = require(ReplicatedStorage.Task)
    local Promise = require(ReplicatedStorage.Promise)

    local TaskHandler = Task.new()

    print(Task.IsTask(TaskHandler)) -- true
    print(Task.IsTask({})) -- false
    ```

## Info

This module is still not finished but this is the first version of it

## Version


VERSION : 1.0
