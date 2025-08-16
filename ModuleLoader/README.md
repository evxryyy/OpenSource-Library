# ModuleLoader

## What Next

## Logs

Version : 1.2
- fixed a bug where calling the :Start and putting the settings SHOW_DEBUG_PRINT on false was not initializing and starting any module
- fixed a bug where calling the :Clean method will still display print even if the SHOW_DEBUG_PRINT was set on false
- added alias
  ```lua
  ModuleLoader.load = ModuleLoader.Load
  ModuleLoader.start = ModuleLoader.Start
  ModuleLoader.setSettings = ModuleLoader.SetSettings
  ModuleLoader.each = ModuleLoader.Each
  ModuleLoader.clear = ModuleLoader.Clear
  ModuleLoader.find = ModuleLoader.Find
  ModuleLoader.waitUntilStarted = ModuleLoader.WaitUntilStarted
  ModuleLoader.isStarted = ModuleLoader.IsStarted
  ModuleLoader.stop = ModuleLoader.Stop
  ```

Version : 1.1
- Changed the loaded methods, now all loaded module can be find by any script that require the ModuleLoader please see the API.
- Added WaitUntilStarted(), wait until the module loader start and it will return a elapsed time
- Added IsStarted(), return true if the module loader is started.

Version : 1.0
- Released the module
