-- Easy type checking for MoonScript classes
oldType = type
export type = (value) ->
  baseType = oldType value
  if base_type == "table"
    cls = value.__class
    return cls.__name if cls
  baseType

-- Initialize java and console module first
sauce3.console = require "sauce3.console"
sauce3.java = require "sauce3.java"

-- Initialize the objects
sauce3.File = require "sauce3.objects.File"
sauce3.Font = require "sauce3.objects.Font"
sauce3.Image = require "sauce3.objects.Image"
sauce3.Quad = require "sauce3.objects.Quad"
sauce3.Source = require "sauce3.objects.Source"

-- Initialize the modules
sauce3.accelerometer = require "sauce3.accelerometer"
sauce3.audio = require "sauce3.audio"
sauce3.compass = require "sauce3.compass"
sauce3.filesystem = require "sauce3.filesystem"
sauce3.graphics = require "sauce3.graphics"
sauce3.keyboard = require "sauce3.keyboard"
sauce3.mouse = require "sauce3.mouse"
sauce3.system = require "sauce3.system"
sauce3.timer = require "sauce3.timer"
sauce3.touch = require "sauce3.touch"
sauce3.window = require "sauce3.window"

-- Wrap the callbacks to be usefull for the engine
Constants = require "sauce3.constants"
import keycodes, buttoncodes from Constants

sauce3._keypressed = (keycode) ->
  sauce3.keypressed(keycodes[keycode]) if sauce3.keypressed

sauce3._keyreleased = (keycode) ->
  sauce3.keyreleased(keycodes[keycode]) if sauce3.keyreleased

sauce3._mousepressed = (x, y, buttoncode) ->
  sauce3.mousepressed(buttoncodes[buttoncode]) if sauce3.mousepressed

sauce3._mousereleased = (x, y, buttoncode) ->
  sauce3.mousereleased(buttoncodes[buttoncode]) if sauce3.mousereleased

sauce3._quit = ->
  if sauce3.quit then sauce3.quit!
  sauce3.audio.stopAll!

-- Main loop function
sauce3.run = ->
  dt = sauce3.timer.getDelta!
  sauce3.update(dt) if sauce3.update
  sauce3.graphics.clear!
  sauce3.graphics.origin!
  sauce3.draw! if sauce3.draw
  sauce3.graphics.present!

require "main"
