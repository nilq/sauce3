Gdx     = sauce3.java.require "com.badlogic.gdx.Gdx"
Sauce3VM = sauce3.java.require "sauce3.Sauce3VM"

class
  new: (f, t = "internal") =>
    switch t
      when "internal"
        @file = Gdx.files\internal f
      when "local"
        @file = Sauce3VM.util\localfile f
      when "external"
        @file = Gdx.files\external f
      when "classpath"
        @file = Gdx.files\classpath f
      when "absolute"
        @file = Gdx.files\absolute f

  append: (v) =>
    @file\writeString v, true

  copy: (f) =>
    @file\copyTo f

  dir_create: =>
    @file\mkdirs!

  exists: =>
    @file\exists!

  get_dir_list: =>
    children = @file\list!
    paths    = {}

    for i = 0, children.length
      paths[i + 1] = children[i]\path!

    paths

  get_last_modified: =>
    @file\lastModified!

  get_size: =>
    @file\length!

  is_dir: =>
    @file\isDirectory!

  is_file: =>
    not @is_dir

  move: (p) =>
    @file\moveTo p

  read: =>
    @file\readString!

  remove: =>
    @file\deleteDirectory!

  write: (v) =>
    @file\writeString v
