with sauce3
  .draw = ->
    .graphics.print "This is #{.project.name}", 10, 10

  .key_pressed = (key) ->
    if key == "q" or key == "escape"
      .system.quit!
