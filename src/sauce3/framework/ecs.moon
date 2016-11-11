tiny = require "sauce3/framework/tiny"

require_all = (...) ->
  tiny.requireAll ...

require_any = (...) ->
  tiny.requireAny ...

reject_all = (...) ->
  tiny.rejectAll ...

reject_any = (...) ->
  tiny.rejectAny ...

filter = (pattern) ->
  tiny.filter pattern

system = (t) ->
  tiny.system t

processing_system = (t) ->
  tiny.processingSystem t

sorted_system = (t) ->
  tiny.sortedSystem t

sorted_processing_system = (t) ->
  tiny.sortedProcessingSystem t

world = (...) ->
  tiny.world ...

add_entity = (world, entity) ->
  tiny.addEntity world, entity

add_system = (world, system) ->
  tiny.addSystem world, system

add = (world, ...) ->
  tiny.add world, ...

remove_entity = (world, entity) ->
  tiny.removeEntity world, entity

remove_system = (world, system) ->
  tiny.removeSystem world, system

remove = (world, ...) ->
  tiny.remove world, ...

refresh = (world) ->
  tiny.refresh world

update = (world, dt, filter) ->
  tiny.update world, dt, filter

clear_entities = (world) ->
  tiny.clearEntities world

clear_systems = (world) ->
  tiny.clearSystems world

get_entity_count = (world) ->
  tiny.getEntityCount world

get_system_count = (world) ->
  tiny.getSystemCount world

set_system_index = (world, system, index) ->
  tiny.set_system_index world, system, index

{
  :require_all
  :require_any

  :reject_all
  :reject_any

  :filter

  :system
  :sorted_system
  :processing_system
  :sorted_processing_system

  :world

  :add_entity
  :add_system
  :add

  :remove_entity
  :remove_system
  :remove

  :refresh
  :update

  :clear_entities
  :clear_systems

  :get_entity_count
  :get_system_count

  :set_system_index
}
