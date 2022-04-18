local gameplay = import_package "vaststars.gameplay"
local general = require "gameplay.utility.general"
local unpackarea = general.unpackarea

local funcs = {}
funcs["fluidbox"] = function(typeobject)
    local w, h = unpackarea(typeobject.area)
    for _, conn in ipairs(typeobject.fluidbox.connections) do
        local position = conn.position
        if position[1] > w - 1 or position[2] > h - 1 then
            error(("invalid fluidbox %s (%s, %s) - (%s, %s)"):format(typeobject.name, w, h, position[1], position[2]))
        end
    end
end

local iotypes <const> = {"input", "output"}
funcs["fluidboxes"] = function(typeobject)
    local w, h = unpackarea(typeobject.area)
    for _, iotype in ipairs(iotypes) do
        for _, v in ipairs(typeobject.fluidboxes[iotype]) do
            for _, conn in ipairs(v.connections) do
                local position = conn.position
                if position[1] > w - 1 or position[2] > h - 1 then
                    error(("invalid fluidboxes %s (%s, %s) - (%s, %s)"):format(typeobject.name, w, h, position[1], position[2]))
                end
            end
        end
    end
end

local function check()
    for _, typeobject in pairs(gameplay.prototype_name) do
        for _, type in ipairs(typeobject.type) do
            local func = funcs[type]
            if func then
                func(typeobject)
            end
        end
    end
end
return check