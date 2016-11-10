-------------------------------------------------------------------------------
-- Handles input and output to console.
-------------------------------------------------------------------------------
-- @module sauce3.console

---
-- Write text to console
-- @param ... text to write
-- @usage
-- sauce3.console.write "Hello", "World"
write = write

---
-- Read text from console
-- @treturn string entered text
-- @usage
-- message = sauce3.console.read!
-- print message
read = read

{
  :read
  :write
}