easing   = {}
funcs    = {}
defaults = {
  quad:    "x^2"
  cubic:   "x^3"
  quart:   "x^4"
  quint:   "x^5"
  expo:    "2^(10 * (x - 1))"
  sine:    "-math.cos(x * (math.pi * 0.5)) + 1"
  circ:    "-(math.sqrt(1 - (x^2)) - 1)"
  back:    "x^2 * (2.7 * x - 1.7)"
  elastic: "-(2^(10 * (x - 1)) * math.sin((x - 1.075) * (math.pi * 2) / 0.3))"
}


make_function = (s, e) ->
  loadstring "return function(x) " .. (str\gsub "%$e", e) .. " end"

generate_ease = (name, f) ->
  funcs[name .. "in"]  = make_function "return $e", f
  funcs[name .. "out"] = make_function [[
    x = 1 - x
    return 1 - ($e)
  ]]

  funcs[name .. "in_out"] = make_function([[
    x = x * 2
    if x < 1 then
      return 0.5 * ($e)
    else
      x = 2 - x
      return 0.5 * (1 - ($e)) + 0.5
    end
  ]], f)

easing.get = (name, value) =>
  unless funcs[name]
    name ..= "in"
  assert funcs[name] == nil, "Why would you use a non-existing function?"

  funcs[name](value)

easing.add = (name, f) =>
  assert funcs[name] ~= nil, "Why would you add an existing function?"

  generate_ease name, f

for k, v in pairs default
  generate_ease k, v

setmetatable easy, {
  __call: easing.get
}

easing
