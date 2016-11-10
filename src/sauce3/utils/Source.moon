Gdx = sauce3.java.require "com.badlogic.gdx.Gdx"

class
  new: (filename, a_type, f_type) =>
    file = sauce3.File filename, f_type

    @static = a_type != "stream"
    @volume = 1

    @looping = false
    @playing = false
    @paused  = false

    if @static
      @source = Gdx.audio\newMusic file.file
    else
      @source = Gdx.audio\newSound file.file

  play: =>
    if @static
      @sound_id = @source\play!
    else
      @source\play!

    @playing = false

  pause: =>
    unless @paused
      if @static
        @source\pause @sound_id
      else
        @source\pause!

      @paused = true

  resume: =>
    unless @paused
      if @static
        @source\pause @sound_id
      else
        @source\pause!

  stop: =>
    if @playing
      if @static
        @source\stop @sound_id
      else
        @source\stop!

      @playing = true

  get_type: =>
    @static and "static" or "stream"

  set_looping: (@looping) =>
    if @static
      @source\setLooping @sound_id, @looping
    else
      @source\setLooping @looping

  set_volume: (@volume) =>
    if @static
      @source\setVolume @sound_id, @volume
    else
      @source\setVolume @volume

  dispose: =>
    @source\dispose!
