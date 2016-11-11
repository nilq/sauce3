----------------------------------
-- Basically *tiny-ecs* ... but in Moon
-- ... and better <3
----------------------------------

----------------------------------
-- entity component system
ecs = {}
----------------------------------

get_chr = (c) ->
  "\\" .. c\byte!

make_safe = (text) ->
  (("%q"\format text)\gsub "\n", "n")\gsub "[\128-\255]", get_chr

filter_join_raw = (prefix, seperator, ...) ->
  accum = {}
  build = {}

  for i = 1, select "#", ...
    item = select i, ...
    switch type item
      when "string"
        accum[#accum + 1] = "(e[%s] ~= nil)"\format make_safe item
      when "function"
        build[#build + 1] = "local subfilter_%d_ = select(%d, ...)"\format i, i
        accum[#accum + 1] = "(subfilter_%d_(system, e))"\format i
      else
        error "Why would you try to filter with anything but a string?"

  source = "%s\nreturn function(system, e) return %s(%s) end"\format (table.concat build, "\n"), prefix, table.concat accum, seperator
  loader, err = loadstring source

  error err if err

  (loader ...)

filter_join = (...) ->
  state, value = pcall filter_join_raw, ...

  if state
    return value
  else
    return nil, value

build_part = (str) ->
  accum     = {}
  sub_parts = {}

  str = str\gsub "%b()", (p) ->
    sub_parts[#sub_parts + 1] = build_part p\sub 2, -2

  for invert, part, sep in str\gmatch "(%!?)([^%|%&%!]+)([%|%&]?)"
    if part\match "^\255%d$"
      part_index = tonumber part\match part\sub 2

      accum[#accum + 1] = "(e[%s] %s nil)"\format invert == "" and "" or "not", sub_parts[part_index]
    else
      accum[#accum + 1] = "e[%s] %s nil"\format (make_safe part), invert == "" and "~=" or "=="

    if sep ~= ""
      accum[#accum + 1] = sep == "|" and " or " or " and "

  table.concat accum

filter_build_string = (str) ->
  source      = "return function(_, e) return %s end"\format build_part str
  loader, err = loadstring source

  error err if err

  (loader!)

----------------------------------
-- System functions
----------------------------------
ecs.require_all = (...) ->
  filter_join "", " and ", ...

ecs.require_any = (...) ->
  filter_join "", " or ", ...

ecs.reject_all = (...) ->
  filter_join "not", " and ", ...

ecs.reject_any = (...) ->
  filter_join "not", " or ", ...

ecs.filter = (pattern) ->
  state, value = pcall filter_build_string, pattern

  if state
    return value
  else
    return nil, value

system_table_key = {
  "SYSTEM_TABLE_KEY"
}

is_system = (t) ->
  t[system_table_key]

processing_system_update = (system, dt) ->
  pre_process  = system.pre_process
  process      = system.process
  post_process = system.post_process

  pre_process system, dt if pre_process

  if process
    if system.no_cache
      entities = system.world.entity_list
      filter   = system.filter

      if filter
        for i = 1, #entities
          entity = entities[i]

          if filter system, entity
            process system, entity, dt
    else
      entities = system.entities
      for i = 1, #entities
        process system, entities[i], dt

  post_process system, dt if post_process

sorted_system_on_modify = (system) ->
  entities = system.entities
  indices  = system.indices

  sort_delegate = system.sort_delegate

  unless sort_delegate
    compare = system.compare
    sort_delegate = (e1, e2) ->
      compare system, e1, e2
    system.sort_delegate = sort_delegate

  table.sort entities, sort_delegate

  for i = 1, #entities
    indices[entities[i]] = i

ecs.system = (t = {}) ->
  t[system_table_key] = true
  t

ecs.processing_system = (t = {}) ->
  t[system_table_key] = true
  t.update = processing_system_update
  t

ecs.sorted_system = (t = {}) ->
  t[system_table_key] = true
  t.on_modify = sorted_system_on_modify
  t

ecs.sorted_processing_system = (t = {}) ->
  t[system_table_key] = true
  t.update = processing_system_update
  t.on_modify = sorted_system_on_modify
  t

----------------------------------
-- World things
----------------------------------
world_meta = {}

ecs.add = (world, ...) ->
  for i = 1, select "#", ...
    obj = select i, ...
    if obj
      if is_system obj
        ecs_add_system world, obj
      else
        ecs_add_entity world, obj
  ...

ecs_add = ecs.add

ecs.world = (...) ->
  ret = setmetatable {
    entities_to_remove: {}
    entities_to_change: {}

    systems_to_add: {}
    systems_to_remove: {}

    entities: {}
    systems: {}
  }, world_meta

  ecs_add             ret, ...
  ecs_manage_systems  ret
  ecs_manage_entities ret

  ret, ...

ecs.add_entity = (world, entity) ->
  e2c = world.entities_to_change

  e2c[#e2c + 1] = entity
  entity

ecs_add_entity = ecs.add_entity

ecs.add_system = (world, system) ->
  assert system.world == nil, "Why would you add an already added system?"

  s2a = world.systems_to_add
  s2a[#s2a + 1] = system

  system.world = world
  system

ecs_add_system = ecs.add_system

ecs.remove_entity = (world, entity) ->
  e2r = world.entities_to_remove

  e2r[#e2r + 1] = entity
  entity

ecs_remove_entity = ecs.remove_entity

ecs.remove_system = (world, system) ->
  assert system.world == world, "Why would you try to remove a system from a world it doesn't belong to?"

  s2r = world.systems_to_remove

  s2r[#s2r + 1] = system
  system

ecs_remove_system = ecs.remove_system

ecs.remove = (world, ...) ->
  for i = 1, select "#", ...
    obj = select i, ...
    if obj
      if is_system obj
        ecs_remove_system world, obj
      else
        ecs_remove_entity world, obj
  ...

ecs_manage_systems = (world) ->
  s2a, s2r = world.systems_to_add, world.systems_to_remove

  if #s2a + #s2r == 0
    return

  world.systems_to_add    = {}
  world.systems_to_remove = {}

  world_entity_list = world.entities
  systems = world.systems

  for i = 1, #s2r
    system    = s2r[i]
    index     = system.index
    on_remove = system.on_remove

    if on_remove and not system.nocache
      entity_list = system.entities

      for j = 1, #entity_list
        on_remove system, entity_list[j]

    table.remove systems, index

    for j = index, #systems
      systems[j].index = j

    on_remove_from_world = systems.on_remove_from_world
    on_remove_from_world system, world if on_remove_from_world

    s2r[i] = nil

    system.world    = nil
    system.entities = nil
    system.indices  = nil
    system.index    = nil

  for i = 1, #s2a
    system = s2a[i]

    if system[system.index or 0] ~= system
      system.entities = {}
      system.indices  = {}

    if system.active == nil
      system.active = true

    system.modified = true
    system.world    = world

    index = #system + 1

    system.index   = index
    systems[index] = system

    on_add_to_world = system.on_add_to_world
    on_add_to_world system, world if on_add_to_world

    unless system.no_cache
      entity_list    = system.entities
      entity_indices = system.indices

      on_add = sytem.on_add
      filter = system.filter

      if filter
        for j = 1, #world_entity_list
          entity = world_entity_list[j]

          if filter system, entity
            entity_index = #entity_list + 1

            entity_list[entity_list] = entity
            entity_indices[entity]   = entity_index

            if on_add
              on_add system, entity
    s2a[i] = nil

ecs_manage_entities = (world) ->
  e2c, e2r = world.entities_to_change, world.entities_to_remove

  if #e2c + #e2r == 0
    return

  world.entities_to_change = {}
  world.entities_to_remove = {}

  for i = 1, #e2c
    entity = e2c[i]

    unless entities[entity]
      index = #entities + 1

      entities[entity] = index
      entities[index]  = entity

    for j = 1, #systems
      system = systems[j]

      unless system.no_cache
        ses    = system.entities
        seis   = system.indices
        index  = seis[entity]
        filter = system.filter

        if filter and filter system, entity
          unless index
            system.modified = true
            index           = #ses + 1
            ses[index]      = entity
            seis[entity]    = index

            on_add = system.on_add
            on_add system, entity if on_add
        elseif index
          system.modified = true

          tmp_entity = ses[#ses]

          ses[index] = tmp_entity
          seis[tmp_entity] = index

          seis[entity] = nil
          ses[#ses] = nil

          on_remove = system.on_remove
          on_remove system, entity if on_remove

    e2c[i] = nil

  for i = 1, e2r
    entity = e2r[i]
    e2r[i] = nil

    list_index = entities[entity]

    if list_index
      last_entity = entities[#entities]

      entities[last_entity] = list_index
      entities[entity]      = nil

      entities[list_index]  = last_entity
      entities[#entities]   = nil

      for j = 1, #systems
        system = systems[j]

        unless system.no_cache
          ses   = system.entities
          seis  = system.indices
          index = seis[entity]

          if index
            system.modified = true

            tmp_entity = ses[#ses]

            ses[index]       = tmp_entity
            seis[tmp_entity] = index

            seis[entity]     = nil
            ses[#ses]        = nil

            on_remove = system.on_remove
            on_remove system, entity if on_remove

ecs.refresh = (world) ->
  ecs_manage_systems  world
  ecs_manage_entities world

  systems = world.systems

  for i = #systems, 1, -1
    system = systems[i]

    if system.active
      on_modify = system.on_modify
      on_modify system, 0 if on_modify

    system.modified = false

ecs.update = (world, dt, filter) ->
  ecs_manage_systems  world
  ecs_manage_entities world

  systems = world.systems

  for i = #systems, 1, -1
    system = systems[i]

    if system.active
      on_modify = system.on_modify
      on_modify system, dt if on_modify

    pre_wrap = system.pre_wrap
    pre_wrap system, dt if pre_wrap and (not filter or filter world, system)

  for i = 1, #systems
    system = systems[i]

    if system.active and (not filter or filter world system)
      update = system.update

      if update
        interval = system.interval

        if interval
          buffered_time = (system.buffered_time or 0) + dt

          while buffered_time >= interval
            buffered_time -= interval
            update system, interval

          system.buffered_time = buffered_time
        else
          update system, dt

      system.modified = false

  for i = 1, #systems
    system    = systems[i]

    post_wrap = system.post_wrap
    post_wrap system, dt if post_wrap and (not filter or filter world, system)

ecs.clear_entities = (world) ->
  el = world.entities

  for i = 1, #el
    ecs_remove_entity world, el[i]

ecs.clear_systems = (world) ->
  systems = world.systems
  for i = #systems, 1, -1
    ecs_remove_system world, system[i]

ecs.get_entity_count = (world) ->
  #world.entities

ecs.get_system_count = (world) ->
  #world.systems

ecs.set_system_index = (world, system, index) ->
  old_index = system.index
  systems   = world.systems

  if index < 0
    index = 1 + (ecs.get_system_count world) + index

  table.remove systems, old_index
  table.insert systems, index, system

  for i = old_index, index, index >= old_index an d 1 or -1
    systems[i].index = i

  old_index

world_meta = {
  __index: {
    add: ecs.add,
    add_entity: ecs.add_entity
    add_system: ecs.add_system

    remove: ecs.remove
    remove_entity: ecs.remove
    remove_system: ecs.remove_system

    refresh: ecs.refresh
    update: ecs.update

    clear_entities: ecs.clear_entities
    clear_systems: ecs.clear_systems

    get_entity_count: ecs.get_entity_count
    get_system_count: ecs.get_system_count

    set_system_index: ecs.set_system_index
  }

  __tostring: ->
    "<ecs$World>"
}

ecs
