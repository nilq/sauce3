-------------------------------------------------------------------------------
-- Allows manipulation with files and directories.
-------------------------------------------------------------------------------
-- Sauce3 applications run on three different platforms
-- * desktop systems (Windows, Linux, Mac OS X)
-- * Android
-- * and iOS.
--
-- Each of these platforms handles file I/O a little differently.
--
-- Each Sauce3 file has a type which defines where the file is located.
-- The following table illustrates the availability and location of each file
-- type for each platform.
--
-- **Classpath**
-- Classpath files are directly stored in your source folders. These get
-- packaged with your jars and are always *read-only*. They have their purpose,
-- but should be avoided if possible.
--
-- **Internal**
-- Internal files are relative to the application’s *root* or *working*
-- directory on desktops and relative to the *assets* directory on Android.
-- These files are *read-only*. If a file can't be found on the internal storage,
-- the file module falls back to searching the file on the classpath. This file
-- type is default for Sauce3 files.
--
-- **Local**
-- Local files are stored relative to the application's *root* or *working*
-- directory on desktops and relative to the internal (private) storage of the
-- application on Android. Note that Local and internal are mostly the same on the
-- desktop.
--
-- **External**
-- External files paths are relative to the
-- [SD card root](http =//developer.android.com/reference/android/os/Environment.html#getExternalStorageDirectory\(\))
-- on Android and to the [home directory](http =//www.roseindia.net/java/beginners/UserHomeExample.shtml)
-- of the current user on desktop systems.
--
-- **Absolute**
-- Absolute files need to have their fully qualified paths specified. For the
-- sake of portability, this option must be used only when absolutely necessary.
--
-- @module sauce3.filesystem

import java, File from sauce3
Gdx = java.require "com.badlogic.gdx.Gdx"
Sauce3VM = java.require "sauce3.Sauce3VM"

---
-- Append data to an existing file.
-- @string filename The name (and path) of the file.
-- @string text The string data to append to the file.
-- @string[opt="internal"] filetype Type of the file
-- @usage
-- sauce3.filesystem.append filename, text, filetype
append = (filename, text, filetype) ->
  file = newFile filename, filetype
  file\append text

---
-- Copy file.
-- @string from_filename The name (and path) of the source file.
-- @string to_filename The name (and path) of the destination file.
-- @string[opt="internal"] from_filetype Type of the source file
-- @string[opt="internal"] to_filetype Type of the destination file
-- @usage
-- sauce3.filesystem.copy from_filename, to_filename, from_filetype, to_filetype
copy = (from_filename, to_filename, from_filetype, to_filetype) ->
  from_file = newFile from_filename, from_filetype
  to_file = newFile from_filename, from_filetype
  from_file\copy to_file

---
-- Creates a directory.
-- @string filename The name (and path) of the file.
-- @string[opt="internal"] filetype Type of the file
-- @usage
-- sauce3.filesystem.createDirectory filename, filetype
createDirectory = (filename, filetype) ->
  file = newFile filename, filetype
  file\create_directory!

---
-- Check whether a file or directory exists.
-- @string filename The name (and path) of the file.
-- @string[opt="internal"] filetype Type of the file
-- @treturn bool True if there is a file or directory with the specified name.
-- False otherwise.
-- @usage
-- exists = sauce3.filesystem.exists filename, filetype
exists = (filename, filetype) ->
  file = newFile filename, filetype
  file\exists!

---
-- Returns a table with the names of files and subdirectories in the specified
-- path. The table is not sorted in any way; the order is undefined.
-- @string filename The name (and path) of the file.
-- @string[opt="internal"] filetype Type of the file
-- @treturn table A sequence with the names of all files and subdirectories as
-- strings.
-- @usage
-- items = sauce3.filesystem.getDirectoryItems filename, filetype
getDirectoryItems = (filename, filetype) ->
  file = newFile filename, filetype
  file\list!

---
-- Get external storage path
-- @treturn string absolute path to external storage location
-- @usage
-- externalPath = sauce3.filesystem.getExternalPath!
getExternalPath = ->
  Gdx.files\getExternalStoragePath!

---
-- Get local storage path
-- @treturn string absolute path to local storage location
-- @usage
-- localPath = sauce3.filesystem.getLocalPath!
getLocalPath = ->
  Gdx.files\getLocalStoragePath!

---
-- Get path to current directory
-- @treturn string absolute path to current directory
-- @usage
-- workingPath = sauce3.filesystem.getWorkingPath!
getWorkingPath = ->
  file = newFile(".")\file!
  file\getAbsolutePath!

---
-- Gets the last modification time of a file.
-- @string filename The name (and path) of the file.
-- @string[opt="internal"] filetype Type of the file
-- @treturn number The last modification time in seconds since the unix epoch
-- or nil on failure.
-- @usage
-- lastModified = sauce3.filesystem.getLastModified filename, filetype
getLastModified = (filename, filetype) ->
  file = newFile filename, filetype
  file\last_modified!

---
-- Gets the size in bytes of a file.
-- @string filename The name (and path) of the file.
-- @string[opt="internal"] filetype Type of the file
-- @treturn number The size in bytes of the file, or nil on failure.
-- @usage
-- size = sauce3.filesystem.getSize filename, filetype
getSize = (filename, filetype) ->
  file = newFile filename, filetype
  file\size!

---
-- Check whether something is a directory.
-- @string filename The name (and path) of the file.
-- @string[opt="internal"] filetype Type of the file
-- @treturn bool True if there is a directory with the specified name. False
-- otherwise.
-- @usage
-- isDirectory = sauce3.filesystem.isDirectory filename, filetype
isDirectory = (filename, filetype) ->
  file = newFile filename, filetype
  file\is_directory!

---
-- Check whether something is a file.
-- @string filename The name (and path) of the file.
-- @string[opt="internal"] filetype Type of the file
-- @treturn bool True if there is a file with the specified name. False
-- otherwise.
-- @usage
-- isFile = sauce3.filesystem.isFile filename, filetype
isFile = (filename, filetype) ->
  file = newFile filename, filetype
  file\is_file!

---
-- Load a lua or moon file (but not run it)
-- @string filename The name (and path) of the file.
-- @string[opt="internal"] filetype Type of the file
-- @treturn function The loaded chunk
-- @usage
-- chunk = sauce3.filesystem.load filename, filetype
-- result = chunk!
load = (filename, filetype) ->
  file = newFile filename, filetype
  Sauce3VM.lua\load file\reader!, filename


---
-- Move file.
-- @string from_filename The name (and path) of the source file.
-- @string to_filename The name (and path) of the destination file.
-- @string[opt="internal"] from_filetype Type of the source file
-- @string[opt="internal"] to_filetype Type of the destination file
-- @usage
-- sauce3.filesystem.move from_filename, to_filename, from_filetype, to_filetype
move = (from_filename, to_filename, from_filetype, to_filetype) ->
  from_file = newFile from_filename, from_filetype
  to_file = newFile from_filename, from_filetype
  from_file\move to_file
  true

---
-- Creates a new File object.
-- @string filename The name (and path) of the file.
-- @string[opt="internal"] filetype Type of the file
-- @treturn File The new File object.
newFile = (filename, filetype) ->
  File filename, filetype

---
-- Read the contents of a file
-- @string filename The name (and path) of the file.
-- @string[opt="internal"] filetype Type of the file
-- @treturn string The file contents
-- @usage
-- contents = sauce3.filesystem.read filename, filetype
read = (filename, filetype) ->
  file = newFile filename, filetype
  file\read!

---
-- Removes a file or directory.
-- Write data to an existing file.
-- @string filename The name (and path) of the file.
-- @string[opt="internal"] filetype Type of the file
-- @usage
-- sauce3.filesystem.remove filename, filetype
remove = (filename, filetype) ->
  file = newFile filename, filetype
  file\remove!
  true

---
-- Write data to an existing file.
-- @string filename The name (and path) of the file.
-- @string text The string data to write to the file.
-- @string[opt="internal"] filetype Type of the file
-- @usage
-- sauce3.filesystem.write filename, text, filetype
write = (filename, text, filetype) ->
  file = newFile filename, filetype
  file\write text
  true

{
  :append
  :copy
  :createDirectory
  :exists
  :getDirectoryItems
  :getExternalPath
  :getLocalPath
  :getWorkingPath
  :getLastModified
  :getSize
  :newFile
  :isDirectory
  :isFile
  :load
  :move
  :read
  :remove
  :write
}
