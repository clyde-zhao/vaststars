require "type.entity"
require "type.chest"
require "type.inserter"
require "type.assembling"
require "type.laboratory"
require "type.powergrid"
require "type.fluidbox"
require "type.pump"
require "type.mining"
require "type.pole"

local type = require "register.type"
type "item"
    .stack "number"

type "fluid"

type "recipe"
    .ingredients "items"
    .results "items"
    .time "time"

type "tech"
    .ingredients "items"
    .time "time"
    .count "number"

type "task"
    .ingredients "items"
    .task "task"
    .count "number"
