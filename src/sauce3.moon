-- type checking for classes
_type = type
export type = (v) ->
  base = _type v
  if base == "table"
    cls = v.__class
    return cls.__name if cls
  base

sauce3.console = require "sauce3/core/console"
sauce3.java    = require "sauce3/core/java"

sauce3.File    = require "sauce3/utils/File"
sauce3.Font    = require "sauce3/utils/Font"
sauce3.Image   = require "sauce3/utils/Image"
sauce3.Quad    = require "sauce3/utils/Quad"

sauce3.file_system = require "sauce3/core/file_system"
sauce3.timer       = require "sauce3/core/timer"
sauce3.graphics    = require "sauce3/core/graphics"
sauce3.console     = require "sauce3/core/console"
sauce3.system      = require "sauce3/core/system"
sauce3.timer       = require "sauce3/core/timer"
sauce3.audio       = require "sauce3/core/audio"

Constants = require "sauce3/wrappers"
import key_codes, button_codes from Constants

sauce3._keypressed = (key) ->
  (sauce3.key_pressed key_codes[key]) if sauce3.keypressed

sauce3._keyreleased = (key) ->
  (sauce3.key_released key_codes[key]) if sauce3.keyreleased

sauce3._mousepressed = (x, y, button) ->
  (sauce3.mouse_pressed button_codes[button]) if sauce3.mouse_pressed

sauce3._mousereleased = (x, y, button) ->
  (sauce3.mouse_released button_codes[button]) if sauce3.mouse_released

sauce3._quit = ->
  if sauce3.quit then sauce3.quit!
  sauce3.audio.stop_all!

sauce3.run = ->
  dt = sauce3.timer.get_delta!

  sauce3.update(dt) if sauce3.update

  sauce3.graphics.clear!
  sauce3.graphics.origin!

  sauce3.draw! if sauce3.draw

  sauce3.graphics.present!

require "main"
