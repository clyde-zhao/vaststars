local prototype = require "prototype"
local container = require "vaststars.container.core"
local component = require "register.component"
local type = require "register.type"

component "chest" {
    type = "word",
}

local c = type "chest"
    .slots "number"

function c:ctor(init, pt)
    local id = container.create(self.cworld, "chest", pt.slots)
    if init.items then
        for i, item in pairs(init.items) do
            local what = prototype.query("item", item[1])
            container.place(self.cworld, id, what.id, item[2])
        end
    end
    return {
        chest = id
    }
end
