import Source from sauce3

sources = {}
global_volume = 1

new_source = (path, a_type, f_type) ->
  source = Source path, a_type, f_type
  table.insert sources, source
  source

pause = (source) ->
  source\pause!

play = (source) ->
  source\play!

play_volume = (source) ->
  source\set_volume global_volume
  source\play!

resume = (source) ->
  source\resume!

set_volume = (v) ->
  global_volume = v

  for _, source in ipairs sources
    source\set_volume global_volume

stop = (source) ->
  source\stop!

stop_all = ->
  for _, source in ipairs sources
    source\stop!
    source\dispose!

{
  :new_source
  :pause
  :play
  :play_volume
  :resume
  :set_volume
  :stop
  :stop_all
}
