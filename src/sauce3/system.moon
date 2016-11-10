-------------------------------------------------------------------------------
-- Provides many usefull methods for managing your current device.
-------------------------------------------------------------------------------
-- @module sauce3.system

import java from sauce3
Gdx = java.require "com.badlogic.gdx.Gdx"
Sauce3VM = java.require "sauce3.Sauce3VM"

---
-- Gets text from the clipboard.
-- @treturn string The text currently held in the system's clipboard.
-- @usage
-- text = sauce3.system.getClipboardText!
getClipboardText = ->
  clipboard = Gdx.app\getClipboard!
  clipboard\getContents!

---
-- Get current platform. Can return "desktop", "android", "ios" or "unknown"
-- @treturn string current platform
-- @usage
-- platform = sauce3.system.getOS!
getOS = ->
  Sauce3VM.util\getOS!

---
-- Get info about current memory usage
-- @treturn number memory heap
-- @usage
-- heap = sauce3.system.getMemoryInfo!
getMemoryInfo = ->
  Gdx.app\getJavaHeap!

---
-- Opens a URL with the user's web or file browser.
-- @tparam string url The URL to open. Must be formatted as a proper URL.
-- @treturn bool Whether the URL was opened successfully.
-- @usage
-- success = sauce3.system.openURL url
openURL = (url) ->
  Gdx.net\openURI url

---
-- Puts text in the clipboard.
-- @tparam string text The new text to hold in the system's clipboard.
-- @usage
-- sauce3.system.setClipboardText text
setClipboardText = (text) ->
  clipboard = Gdx.app\getClipboard!
  clipboard\setContents text

---
-- Vibrates for the given amount of time.
-- @tparam number seconds the number of seconds to vibrate
-- @usage
-- sauce3.system.vibrate seconds
vibrate = (seconds) ->
  Gdx.input\vibrate seconds * 1000

---
-- Terminate the application
-- @usage
-- sauce3.system.quit! if something
quit = ->
  Gdx.app\exit!

{
  :getClipboardText
  :getOS
  :getMemoryInfo
  :openURL
  :setClipboardText
  :vibrate
  :quit
}
