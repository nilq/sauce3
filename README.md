# Sauce3 - GDK

> Oh no, oh no; that's the beauty of Sauce3, it's so intense it skips over the other two!

Sauce3 is a game development kit for cooking 1- and 2-dimensional games in MoonScript/Lua through LibGDX.
Currently supporting **Linux**, **Windows**, **OS X**, **Android**, **iOS**, **Ouya** as well as everything else supporting Java/LibGDX.

### Example

**MoonScript**
```moon
with sauce3
  .draw = ->
    .graphics.print "This is #{.project.name}", 10, 10

  .key_pressed = (key) ->
    if key == "q" or key == "escape"
      .system.quit!
```

or ...

```moon
sauce3.draw = ->
  sauce3.graphics.print "This is #{sauce3.project.name}", 10, 10

sauce3.key_pressed = (key) ->
  if key == "q" or key == "escape"
    sauce3.system.quit!
```

**Lua**
```lua
function sauce3.draw()
  sauce3.graphics.print("This is " .. sauce3.project.name, 10, 10)
end

function sauce3.key_pressed(key)
  if key == "q" or key == "escape" then
    sauce3.system.quit()
  end
end
```

### Styling commandments

- It is in fact a sin to use anything but **snake_case** for Moon/Lua function- and variable names!
- It is in fact a sin to use anything but **CamelCase** for Moon/Lua class names!

### Installation

```bash
$ alias fucking="sudo"
$ fucking luarocks install --server=http://luarocks.org/dev sauce3
```

### Reporting Issues

Use the [issue tracker](https://github.com/nilq/sauce3/issues) here on GitHub to report issues.
