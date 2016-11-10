FreeTypeFontGenerator = sauce3.java.require "com.badlogic.gdx.graphics.g2d.freetype.FreeTypeFontGenerator"
GlyphLayout = sauce3.java.require "com.badlogic.gdx.graphics.g2d.GlyphLayout"
Constants = require "sauce3.constants"

class
  new: (filename, size=16, filetype) =>
    file = nil

    if filename == nil
      file = sauce3.File("sauce3/font.ttf", filetype)
    else
      file = sauce3.File(filename, filetype)

    generator = sauce3.java.new FreeTypeFontGenerator, file.file
    @font = generator\generateFont size
    @fontTexture = @font\getRegion(0)\getTexture!
    @fontTexture\setFilter Constants.filters["linear"], Constants.filters["linear"]
    @glyphLayout = sauce3.java.new GlyphLayout

  get_ascent: =>
    @font\getAscent!

  get_descent: =>
    @font\getDescent!

  get_line_height: =>
    @font\getLineHeight!

  get_bounds: (text) =>
    @glyphLayout\setText text
    @glyphLayout.width, @glyphLayout.height

  get_filter: =>
    min_filter = @fontTexture\getMinFilter!
    mag_filter = @fontTexture\getMagFilter!
    Constants.filtercodes[min_filter], Constants.filtercodes[mag_filter]

  get_width: (text) =>
    w, _ = @getBounds text
    w

  get_height: (text) =>
    _, h = @getBounds text
    h

  has_glyphs: (...) =>
    args = table.pack ...
    found = true

    for i = 1, args.n
      found = found and @font\containsCharacter args[i]

    found

  set_filter: (min, mag) =>
    @fontTexture\setFilter Constants.filters[min], Constants.filters[mag]

  set_line_height: (height) =>
    @font\getData()\setLineHeight height

  free: =>
    @font\dispose!
