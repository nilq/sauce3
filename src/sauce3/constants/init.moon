buttons = require "sauce3.constants.buttons"
keys = require "sauce3.constants.keys"
formats = require "sauce3.constants.formats"
wraps = require "sauce3.constants.wraps"
filters = require "sauce3.constants.filters"
blendmodes = require "sauce3.constants.blendmodes"
shapetypes = require "sauce3.constants.shapetypes"
aligns = require "sauce3.constants.aligns"

keycodes = {}
for k, v in pairs keys
  keycodes[v] = k

buttoncodes = {}
for k, v in pairs buttons
  buttoncodes[v] = k

formatcodes = {}
for k, v in pairs formats
  formatcodes[v] = k

wrapcodes = {}
for k, v in pairs wraps
  wrapcodes[v] = k

filtercodes = {}
for k, v in pairs filters
  filtercodes[v] = k

{
  :keys
  :keycodes
  :buttons
  :buttoncodes
  :formats
  :formatcodes
  :wraps
  :wrapcodes
  :filters
  :filtercodes
  :blendmodes
  :shapetypes
  :aligns
}
