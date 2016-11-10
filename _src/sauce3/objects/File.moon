Gdx = sauce3.java.require "com.badlogic.gdx.Gdx"
Sauce3VM = sauce3.java.require "sauce3.Sauce3VM"

class
  new: (filename, filetype="internal") =>
    switch filetype
      when "internal"
        @file = Gdx.files\internal filename
      when "local"
        @file = Sauce3VM.util\localfile filename
      when "external"
        @file = Gdx.files\external
      when "classpath"
        @file = Gdx.files\classpath
      when "absolute"
        @file = Gdx.files\absolute

  append: (text) =>
    @file\writeString text, true

  copy: (to) =>
    @file\copyTo to

  createDirectory: =>
    @file\mkdirs!

  exists: =>
    @file\exists!

  get_directory_items: =>
    children = @file\list!
    paths = {}

    for i = 0, children.length
      paths[i + 1] = children[i]\path!

    paths

  get_last_modified: =>
    @file\lastModified!

  get_size: =>
    @file\length!

  is_directory: =>
    @file\isDirectory!

  is_file: =>
    not @is_directory!

  move: (to_file) =>
    @file\moveTo to_file

  read: =>
    @file\readString!

  remove: =>
    @file\deleteDirectory!

  write: (text) =>
    @file\writeString text
