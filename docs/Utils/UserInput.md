## Getting Started

### Module : [UserInput](https://create.roblox.com/store/asset/112977411128058/UserInput)

On this page you will learn how to use <b>UserInput</b> module
Please read the documentation entirely if you want to really use it for your projects

??? Note

    This module only handle gamepad and keyboard maybe in future update i will include mouse controll and touch.

### Basic

=== "Initialize"

    ```lua linenums="1"
    local UserInput = require(somewhere.UserInput)

    local Init = UserInput.new({
        Keys = {Enum.KeyCode.E};
        InputType = "Keyboard"
    })
    ```

    This will basically create a new Input Object with custom methods to adding/changing/removings key or directly changing
    the input type itself.

    !!! note
    
        <b>The keys argument should always be a an array of Enum.KeyCode</b>


### Connecting Pressed and Released.

=== "Pressed "

    ```lua linenums="1"
    local UserInput = require(somewhere.UserInput)

    local Init = UserInput.new({
        Keys = {Enum.KeyCode.E};
        InputType = "Keyboard"
    })

    Init:Pressed(function(key : Enum.KeyCode)
        print(key) -- This will print the actual pressed key.
    end)
    ```

    !!! note
        For disconnecting the pressed event i recommend you to call :DisconnectPressed()

=== "Released"

    ```lua linenums="1"
    local UserInput = require(somewhere.UserInput)

    local Init = UserInput.new({
        Keys = {Enum.KeyCode.E};
        InputType = "Keyboard"
    })

    Init:Released(function(key : Enum.KeyCode)
        print(key) -- This will print the actual released key.
    end)
    ```

    !!! note
        For disconnecting the pressed event i recommend you to call :DisconnectReleased()


### Add/Change/Remove Keys

With the current initialized Input you can still change or adding new keys during run time or even removing them all functions concerning this should you always have a an array of Enum.KeyCode to work.

=== "Changing keys"

    ```lua
    local UserInput = require(somewhere.UserInput)

    local Init = UserInput.new({
        Keys = {Enum.KeyCode.E};
        InputType = "Keyboard"
    })

    Init:Pressed(function(key : Enum.KeyCode)
        print(key) -- This will print the actual pressed key.
    end)

    Input:ChangeKey({Enum.KeyCode.A}) 
    -- old keys will be removed and changed to new one (E is not longer detected) without disconnecting and reconnecting the .Pressed
    ```

=== "Adding Keys"

    ```lua
    local UserInput = require(somewhere.UserInput)

    local Init = UserInput.new({
        Keys = {Enum.KeyCode.E};
        InputType = "Keyboard"
    })

    Init:Pressed(function(key : Enum.KeyCode)
        print(key) -- This will print the actual pressed key.
    end)

    Input:AddKey({Enum.KeyCode.A}) 
    -- A will now being detected when pressed without disconnecting and reconnecting the .Pressed
    ```


=== "Removing Keys"

    ```lua
    local UserInput = require(somewhere.UserInput)

    local Init = UserInput.new({
        Keys = {Enum.KeyCode.E};
        InputType = "Keyboard"
    })

    Init:Pressed(function(key : Enum.KeyCode)
        print(key) -- This will print the actual pressed key.
    end)

    Input:RemoveKey({Enum.KeyCode.E}) 
    -- E will be removed and being no longer detected without disconnecting and reconnecting the .Pressed
    ```

### Changing InputType

In runtime you can also change which type of input you want to use for exemple if you wanna have custom pressed event for gamepad you should do

=== "Keyboard to Gamepad"

    ```lua
    local UserInput = require(somewhere.UserInput)

    local Init = UserInput.new({
        Keys = {Enum.KeyCode.E};
        InputType = "Keyboard"
    })

    Init:Pressed(function(key : Enum.KeyCode)
        print(key) -- This will print the actual pressed key.
    end)

    Init:ChangeInputType("Gamepad") -- Pressed no need to be reconnected.
    Init:ChangeKey({Enum.KeyCode.ButtonB}) -- Key must be changed after changing the InputType
    ```

=== "Gamepad to Keyboard"

    ```lua
    local UserInput = require(somewhere.UserInput)

    local Init = UserInput.new({
        Keys = {Enum.KeyCode.ButtonB};
        InputType = "Gamepad"
    })

    Init:Pressed(function(key : Enum.KeyCode)
        print(key) -- This will print the actual pressed key.
    end)

    Init:ChangeInputType("Keyboard") -- Pressed no need to be reconnected.
    Init:ChangeKey({Enum.KeyCode.A}) -- Key must be changed after changing the InputType
    ```


Pretty simple for changing InputType if needed.

### Disconnections

When creating a new Input Object when you want to disconnect pressed or released events please call one of them directly

		.DisconnectPressed() -> Disconnect the pressed signal
		.DisconnectReleased() -> Disconnect the released signal

### Destroy

You can also destroy the Input Object by calling directly:

		.Destroy() -> Destroy Signals and everything related to the Input

### Tips

I recommend you to also use PreferredInput from Sleitnick for detecting when a player is playing with a gamepad/keyboard/mobile

so you will be able to dynamicly change the InputType during runtime without having many connections for the actual input

### __PRIVATE__

        {
            .KeyPressed : Signal<key : KeyCode> -> the signal that fire each time a correct key is pressed (PLEASE USE :Pressed functions)
            .KeyReleased : Signal<key : KeyCode> -> the signal that fire each time a correct key is released (PLEASE USE :Released functions)
            .__setUpInputStructKeyPressed() -> automaticly called to init the input pressed capture (DO NOT CALL THIS FUNCTION)
            .__setUpInputStructKeyReleased() -> automaticly called to init the input released capture (DO NOT CALL THIS FUNCTION)
            .inputStruct :  GamepadStruct | KeyboardStruct -> determinate wich input is used (see Input Framework from sleitnick DO NOT MODIFY OR DESTROY THIS STRUCT).
        }
