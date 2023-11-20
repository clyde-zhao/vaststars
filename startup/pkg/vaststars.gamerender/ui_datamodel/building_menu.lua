local ecs, mailbox = ...
local world = ecs.world
local w = world.w

local CHEST_TYPE_CONVERT <const> = {
    [0] = "none",
    [1] = "supply",
    [2] = "demand",
    [3] = "transit",
}

local CONSTANT <const> = require "gameplay.interface.constant"
local CHANGED_FLAG_STATION <const> = CONSTANT.CHANGED_FLAG_STATION
local CHANGED_FLAG_DEPOT <const> = CONSTANT.CHANGED_FLAG_DEPOT

local gameplay_core = require "gameplay.core"
local objects = require "objects"
local iprototype = require "gameplay.interface.prototype"
local iui = ecs.require "engine.system.ui_system"
local itask = ecs.require "task"
local icamera_controller = ecs.require "engine.system.camera_controller"
local math3d = require "math3d"

local set_recipe_mb = mailbox:sub {"set_recipe"}
local set_item_mb = mailbox:sub {"set_item"}
local lorry_factory_inc_lorry_mb = mailbox:sub {"lorry_factory_inc_lorry"}
local ui_click_mb = mailbox:sub {"ui_click"}
local pickup_item_mb = mailbox:sub {"pickup_item"}
local place_item_mb = mailbox:sub {"place_item"}
local remove_lorry_mb = mailbox:sub {"remove_lorry"}
local inventory_mb = mailbox:sub {"inventory"}

local move_mb = mailbox:sub {"move"}
local copy_md = mailbox:sub {"copy"}
local ichest = require "gameplay.interface.chest"
local iinventory = require "gameplay.interface.inventory"
local interval_call = ecs.require "engine.interval_call"
local gameplay = import_package "vaststars.gameplay"
local iGameplayStation = gameplay.interface "station"
local itransfer = ecs.require "transfer"

local function hasSetItem(e, typeobject)
    return e.station or (e.chest and CHEST_TYPE_CONVERT[typeobject.chest_type] == "transit" or false)
end

local function hasPickupItem(e)
    return e.chest ~= nil
end

local function hasPlaceItem(e)
    return e.chest ~= nil
end

local updateItemCount = interval_call(300, function(datamodel, e)
    local info = itransfer.get_transfer_info(gameplay_core.get_world())
    local length = 0
    for _, _ in pairs(info) do
        length = length + 1
    end

    local count = 0
    if datamodel.place_item then
        if length > 1 then
            count = "+"
        elseif length == 1 then
            local _, amount = next(info)
            count = amount
        else
            count = 0
        end
    end
    datamodel.place_item_count = count
end)

---------------
local M = {}
function M.create(gameplay_eid)
    iui.register_leave("/pkg/vaststars.resources/ui/building_menu.rml")

    local e = assert(gameplay_core.get_entity(gameplay_eid))
    local typeobject
    if e.lorry then
        typeobject = iprototype.queryById(e.lorry.prototype)
    else
        typeobject = iprototype.queryById(e.building.prototype)
    end

    local set_item = hasSetItem(e, typeobject)
    local place_item = hasPlaceItem(e)
    local lorry_factory_inc_lorry = (e.factory == true)

    local datamodel = {
        prototype_name = typeobject.name,
        show_set_recipe = e.assembling and typeobject.allow_set_recipt or false,
        lorry_factory_inc_lorry = lorry_factory_inc_lorry,
        pickup_item = hasPickupItem(e),
        place_item = place_item,
        place_item_count = 0,
        set_item = set_item,
        remove_lorry = (e.lorry ~= nil),
        move = typeobject.move ~= false,
        copy = typeobject.copy ~= false,
        inventory = iprototype.has_type(typeobject.type, "base"),
    }

    return datamodel
end

local function station_set_item(gameplay_world, e, type, item)
    local items = {}
    local found = false

    for i = 1, ichest.get_max_slot(iprototype.queryById(e.building.prototype)) do
        local slot = ichest.get(gameplay_world, e.station, i)
        if not slot then
            break
        end

        local limit = slot.limit
        if slot.item == item then
            limit = limit + 1
            found = true
        end
        items[#items+1] = {slot.type, slot.item, limit}
    end

    if not found then
        local typeobject = iprototype.queryById(item)
        items[#items+1] = {type, item, typeobject.station_capacity or 1}
    end

    iGameplayStation.set_item(gameplay_world, e, items)
    gameplay_core.set_changed(CHANGED_FLAG_STATION)
end

local function station_remove_item(gameplay_world, e, slot_index, item)
    local items = {}

    for i = 1, ichest.get_max_slot(iprototype.queryById(e.building.prototype)) do
        local slot = ichest.get(gameplay_world, e.station, i)
        if not slot then
            break
        end

        if slot.item == item and slot.limit - 1 > 0 then
            items[#items+1] = {slot.type, slot.item, slot.limit - 1}
        elseif i ~= slot_index then
            items[#items+1] = {slot.type, slot.item, slot.limit}
        end
    end

    iGameplayStation.set_item(gameplay_world, e, items)
    gameplay_core.set_changed(CHANGED_FLAG_STATION)
end

local function chest_set_item(gameplay_world, e, type, item)
    local items = {}
    local typeobject = iprototype.queryById(e.building.prototype)
    for i = 1, ichest.get_max_slot(typeobject) do
        local slot = ichest.get(gameplay_world, e.chest, i)
        if not slot then
            break
        end
        items[#items+1] = {slot.type, slot.item}
    end

    items[#items+1] = {CHEST_TYPE_CONVERT[typeobject.chest_type], item}
    ichest.set(gameplay_world, e, items)
    gameplay_core.set_changed(CHANGED_FLAG_DEPOT)
end

local function chest_remove_item(gameplay_world, e, slot_index)
    local items = {}

    for i = 1, ichest.get_max_slot(iprototype.queryById(e.building.prototype)) do
        local slot = ichest.get(gameplay_world, e.chest, i)
        if not slot then
            break
        end

        if i ~= slot_index then
            items[#items+1] = {slot.type, slot.item}
        end
    end

    ichest.set(gameplay_world, e, items)
    gameplay_core.set_changed(CHANGED_FLAG_DEPOT)
end

function M.update(datamodel, gameplay_eid)
    local e = assert(gameplay_core.get_entity(gameplay_eid))
    local typeobject
    if e.lorry then
        typeobject = iprototype.queryById(e.lorry.prototype)
    else
        typeobject = iprototype.queryById(e.building.prototype)
    end
    updateItemCount(datamodel, e)

    for _ in move_mb:unpack() do
        iui.leave()
        local object = assert(objects:coord(e.building.x, e.building.y))
        iui.redirect("/pkg/vaststars.resources/ui/construct.rml", "move", object.id)
    end
    for _ in copy_md:unpack() do
        assert(e.building)
        local typeobject = iprototype.queryById(e.building.prototype)
        iui.redirect("/pkg/vaststars.resources/ui/construct.rml", "copy", typeobject.name)
    end

    for _ in set_recipe_mb:unpack() do
        iui.open({rml = "/pkg/vaststars.resources/ui/recipe_config.rml"}, gameplay_eid)
    end

    for _ in set_item_mb:unpack() do
        assert(hasSetItem(e, typeobject))
        local interface = {}
        if e.station then
            interface.set_item = station_set_item
            interface.remove_item = station_remove_item
            interface.supply_button = true
            interface.demand_button = true
            interface.show_add = false
        else
            interface.set_item = chest_set_item
            interface.remove_item = chest_remove_item
            interface.show_add = true
        end
        iui.open({rml = "/pkg/vaststars.resources/ui/item_config.rml"}, gameplay_eid, interface)
    end

    for _ in lorry_factory_inc_lorry_mb:unpack() do
        local component = "chest"
        local slot = ichest.get(gameplay_core.get_world(), e[component], 1)
        if not slot then
            print("item not set yet")
            goto continue
        end
        local c = ichest.get_amount(slot)
        if slot.limit <= c then
            print("item already full")
            goto continue
        end
        if not iinventory.pickup(gameplay_core.get_world(), slot.item, 1) then
            print("failed to place")
            goto continue
        end
        ichest.place_at(gameplay_core.get_world(), e, 1, 1)
        ::continue::
    end

    for _, _, _, message in ui_click_mb:unpack() do
        itask.update_progress("click_ui", message, typeobject.name)
    end

    for _ in pickup_item_mb:unpack() do
        itransfer.set_source_eid(e.eid)
    end

    for _ in place_item_mb:unpack() do
        local object = assert(objects:coord(e.building.x, e.building.y))
        local gameplay_world = gameplay_core.get_world()

        local msgs = {}
        itransfer.transfer(gameplay_world, function(item, n)
            if e.station then
                e.station_changed = true
            end

            local typeobject = iprototype.queryById(item)
            msgs[#msgs+1] = {icon = typeobject.item_icon, name = typeobject.name, count = n}

            itask.update_progress("place_item", object.prototype_name, typeobject.name, n)
        end)

        local sp_x, sp_y = math3d.index(icamera_controller.world_to_screen(object.srt.t), 1, 2)
        iui.send("/pkg/vaststars.resources/ui/message_pop.rml", "item", {action = "down", left = sp_x, top = sp_y, items = msgs})
    end

    for _ in remove_lorry_mb:unpack() do
        e.lorry_willremove = true
        iui.leave()
        iui.redirect("/pkg/vaststars.resources/ui/construct.rml", "unselected")
    end

    for _ in inventory_mb:unpack() do
        iui.open({rml = "/pkg/vaststars.resources/ui/inventory.rml"})
    end
end

return M