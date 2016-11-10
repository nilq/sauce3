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

sauce3.run = ->
  dt = sauce3.timer.get_delta!

  sauce3.update(dt) if sauce3.update

  sauce3.graphics.clear!
  sauce3.graphics.origin!

  sauce3.draw! if sauce3.draw

  sauce3.graphics.present!

require "main"
