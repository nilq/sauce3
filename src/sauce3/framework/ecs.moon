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
