local component = require "register.component"

component "entity" {
    "x:byte",
    "y:byte",
    "prototype:word",
    "direction:byte",	-- 0:North 1:East 2:South 3:West
}

component "chest" {
    "container:word",
}

component "assembling" {
    "fluidbox_in:word",
    "fluidbox_out:word",
    "recipe:word",
    "container:word",
    "process:int",
    "low_power:byte",
    "status:byte",
    "speed:word"
}

component "inserter" {
    "input_container:word",
    "output_container:word",
    "hold_item:word",
    "hold_amount:word",
    "process:word",
    "low_power:byte",
    "status:byte",
}

component "capacitance" {
	"shortage:dword"
}

component "burner" {
	"recipe:word",
	"container:word",
	"process:word",
}

component "consumer" {
}

component "generator" {
}

component "accumulator" {
}

component "pole" {
}

component "power" {
}

component "fluidbox" {
    "fluid:word",
    "id:word",
}

component "fluidboxes" {
    "in:fluidbox[4]",
    "out:fluidbox[3]",
}

component "pump" {
}

component "mining" {
}

component "road" {
    "road_type:word",
    "coord:word",
}

component "station" {
	"id:word",
	"coord:word",
}