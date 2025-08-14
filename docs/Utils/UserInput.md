# UserInput

## Overview

The UserInput Component is a Roblox module that provides a unified interface for handling user input from both keyboard and gamepad devices. It abstracts the differences between input types and provides a consistent API with signal-based events.

## Features

- Dual Input Support: Seamlessly handle both Keyboard and Gamepad inputs
- Dynamic Switching: Change input types on the fly
- Key Registration: Filter which keys trigger events
- Signal-Based Events: Clean event system for key press/release
- Input Observation: Detect when users switch input methods
- Proper Cleanup: Built-in memory management

## Installation: [UserInput](https://github.com/evxryyy/OpenEvxEngine/releases/tag/script)

## API

### Constructor

#### ```new(config: UserInputConfiguration): UserInputComponent```

Creates a new UserInput component instance.

Parameters:

config: Configuration object with the following properties:

- Keys: {Enum.KeyCode} - Array of keys to register
- InputType: "Gamepad" | "Keyboard" - Initial input type
`
### Component

#### ```Pressed(self : UserInputComponent,callback : (key : Enum.KeyCode) -> ()) -> SignalConnectionStruct```

Public method to connect a callback to the key pressed event

- @param callback: Function that will be called when a registered key is pressed
- @return: SignalConnection that can be used to disconnect the callback

#### ```Released(self : UserInputComponent,callback : (key : Enum.KeyCode) -> ()) -> SignalConnectionStruct```

Public method to connect a callback to the key released event

- @param callback: Function that will be called when a registered key is released
- @return: SignalConnection that can be used to disconnect the callback

#### ```Observe(self : UserInputComponent,callback : (InputType : "Gamepad" | "MouseKeyboard" | "Touch") -> ()) : () -> ()```

 Observe changes in the user's preferred input method

- @param callback: Function called when input type changes (Gamepad, MouseKeyboard, or Touch)
- @return: Cleanup function to stop observing


#### ```ChangeInputType(self : UserInputComponent,InputType : "Gamepad" | "Keyboard")```

Dynamically change the input type between Gamepad and Keyboard
This will clear all registered keys and recreate the input handlers

- @param InputType: Either "Gamepad" or "Keyboard"

#### ```ChangeKey(self : UserInputComponent,Keys : {Enum.KeyCode})```

Replace all currently registered keys with a new set

- @param Keys: Array of KeyCodes to register

#### ```AddKey(self : UserInputComponent,Keys : {Enum.KeyCode})```

Add new keys to the existing registered set
Duplicate keys are automatically ignored

- @param Keys: Array of KeyCodes to add

#### ```RemoveKey(self : UserInputComponent,Keys : {Enum.KeyCode})```

Remove specific keys from the registered set

- @param Keys: Array of KeyCodes to remove

#### ```DisconnectPressed(self : UserInputComponent)```

Disconnect all callbacks connected to the KeyPressed signal
Useful for temporarily disabling key press detection

#### ```DisconnectReleased(self : UserInputComponent)```

Disconnect all callbacks connected to the KeyReleased signal
Useful for temporarily disabling key release detection

#### ```Destroy(self : UserInputComponent)```

Complete cleanup of the UserInput component
This should be called when the component is no longer needed
