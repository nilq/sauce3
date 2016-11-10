import java from sauce3

Gdx = java.require "com.badlogic.gdx.Gdx"
Peripheral = java.require "com.badlogic.gdx.Input$Peripheral"
Constants = require "sauce3.wrappers"

is_available = ->
  is_visible! or Gdx.input\isPeripheralAvailable Peripheral.HardwareKeyboard

is_down = (...) ->
  args = table.pack ...

  found = false

  for i = 1, args.n
    k = Constants.keys[args[i]]
    found = found or Gdx.input\isKeyPressed k
  found

is_visible = ->
  Gdx.input\isPeripheralAvailable Peripheral.OnscreenKeyboard

set_visible = (v) ->
  Gdx.input\setOnscreenKeyboardVisible v

{
  :is_down
  :is_visible
  :is_available
  :set_visible
}
