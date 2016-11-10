-------------------------------------------------------------------------------
-- User input from keyboard.
-------------------------------------------------------------------------------
-- Keyboards signal user input by generating events for pressing and releasing
-- a key. Each event carries with it a key-code that identifies the key that
-- was pressed/released. These key-codes differ from platform to platform.
-- Sauce3 tries to hide this fact by providing its own key-code table. You can
-- query which keys are currently being pressed via polling.
--
-- @module sauce3.keyboard

import java from sauce3
Gdx = java.require "com.badlogic.gdx.Gdx"
Peripheral = java.require "com.badlogic.gdx.Input$Peripheral"
Constants = require "sauce3.constants"

---
-- Checks if keyboard is available on current device
-- @treturn bool True if keyboard is available
-- @usage
-- available = sauce3.keyboard.isAvailable!
isAvailable = ->
  isVisible or Gdx.input\isPeripheralAvailable Peripheral.HardwareKeyboard

---
-- Check if one of specified keys is down
-- @tparam ... keys keys to check for
-- @treturn bool true one of keys is pressed
-- @usage
-- is_down = sauce3.keyboard.isDown "a", "b", "c"
-- @see keys.moon
isDown = (...) ->
  args = table.pack ...
  found = false

  for i = 1, args.n
    keycode = Constants.keys[args[i]]
    found = found or Gdx.input\isKeyPressed keycode

  found

---
-- Checks if on-screen keyboard is visible (mobile devices only)
-- @treturn bool true if keyboard is visible
-- @usage
-- visible = sauce3.keyboard.isVisible!
isVisible = ->
  Gdx.input\isPeripheralAvailable Peripheral.OnscreenKeyboard

---
-- Change on-screen keyboard visibility (mobile devices only)
-- @tparam bool visible set if keyboard will be visible or not
-- @usage
-- sauce3.keyboard.setVisible true
setVisible = (visible) ->
  Gdx.input\setOnscreenKeyboardVisible visible

{
  :isDown
  :isVisible
  :isAvailable
  :setVisible
}
