-------------------------------------------------------------------------------
-- Handles creating, playing and manipulating sound and music instances.
-------------------------------------------------------------------------------
-- Sound effects are small audio samples, usually no longer than a few seconds,
-- that are played back on specific game events such as a character jumping or
-- shooting a gun.
-- For any sound that's longer than a few seconds it is preferable to stream it
-- from disk instead of fully loading it into RAM. Sauce3 provides a "stream"
-- source that lets you do that.
--
-- Sauce3 supports MP3, OGG and WAV files.
-- ***note1:*** iOS currently does not support OGG files.
-- ***note2:*** On Android, a static source cannot be over 1 MB
--
-- @module sauce3.audio

import Source from sauce3

sources = {}
globalvolume = 1

---
-- Gets the current number of simultaneously playing sources.
-- @treturn number The current number of simultaneously playing sources.
-- @usage
-- numSources = sauce3.audio.getSourcesCount!
getSourceCount = ->
  #sources


---
-- Returns the master volume.
-- @treturn number The current master volume
-- @usage
-- volume = sauce3.audio.getVolume!
getVolume = ->
  globalvolume

---
-- Creates a new Source from a filepath.
-- @string filename The name (and path) of the file.
-- @string[opt="stream"] audiotype Type of the audio.
-- @string[opt="internal"] filetype Type of the file
-- @treturn Source A new Source that can play the specified audio.
-- @see sauce3.Source.new
-- @usage
-- source = sauce3.audio.newSource filename, audiotype, filetype
newSource = (filename, audiotype, filetype) ->
  source = Source(filename, audiotype, filetype)
  table.insert sources, source
  return source

---
-- Pause the specified Source.
-- @tparam Source source The Source on which to pause the playback
-- @usage
-- sauce3.audio.pause source
pause = (source) ->
  source\pause!

---
-- Plays the specified Source.
-- @tparam Source source The Source to play.
-- @usage
-- sauce3.audio.play source
play = (source) ->
  source\setVolume globalvolume
  source\play!

---
-- Resumes the specified paused Source.
-- @tparam Source source The Source to resume
-- @usage
-- sauce3.audio.resume source
resume = (source) ->
  source\resume!

---
-- Sets the master volume.
-- @tparam number volume 1.0 is max and 0.0 is off.
-- @usage
-- sauce3.audio.setVolume volume
setVolume = (volume) ->
  globalvolume = volume

  for i, source in ipairs sources
    source\setVolume globalvolume

---
-- This function will only stop the specified Source.
-- @tparam Source source The Source on which to stop the playback.
-- @usage
-- sauce3.audio.stop source
stop = (source) ->
  source\stop!

---
-- This function will stop all currently active sources.
-- @usage
-- sauce3.audio.stopAll!
stopAll = ->
  for i, source in ipairs sources
    source\stop!
    source\free!

{
  :getSourceCount
  :getVolume
  :newSource
  :pause
  :play
  :resume
  :setVolume
  :stop
  :stopAll
}
