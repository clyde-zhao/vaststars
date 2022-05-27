local ecs, mailbox = ...
local world = ecs.world
local w = world.w

local item_category = import_package "vaststars.prototype"("item_category")
local gameplay_core = require "gameplay.core"
local ichest = require "gameplay.interface.chest"
local iprototype = require "gameplay.interface.prototype"
local global = require "global"
local objects = global.objects
local cache_names = global.cache_names
local irecipe = require "gameplay.interface.recipe"
local click_item_mb = mailbox:sub {"click_item"}
local to_chest_mb = mailbox:sub {"to_chest"}
local to_headquater_mb = mailbox:sub {"to_headquater"}

local item_id_to_info = {}
local recipe_to_category = {}
local category_to_entity = {}
for _, typeobject in pairs(iprototype:all_prototype_name()) do
    if iprototype:has_type(typeobject.type, "recipe") then
        for _, element in ipairs(irecipe:get_elements(typeobject.results)) do
            local typeobject_element = assert(iprototype:query(element.id))
            if iprototype:has_type(typeobject_element.type, "item") then
                local id = typeobject_element.id
                item_id_to_info[id] = item_id_to_info[id] or {}
                item_id_to_info[id][#item_id_to_info[id]+1] = {icon = assert(typeobject.icon), element = irecipe:get_elements(typeobject.ingredients), recipe_id = typeobject.id}
            end
        end
        recipe_to_category[typeobject.id] = typeobject.category
    end

    if iprototype:has_type(typeobject.type, "assembling") then
        if typeobject.recipe then -- 固定配方的组装机
            local typeobject_recipe = assert(iprototype:queryByName("recipe", typeobject.recipe))
            category_to_entity[typeobject_recipe.category] = category_to_entity[typeobject_recipe.category] or {}
            table.insert(category_to_entity[typeobject_recipe.category], {id = typeobject.id, icon = typeobject.icon})
        else
            if not typeobject.craft_category then
                log.error(("%s dont have craft_category"):format(typeobject.name))
            end
            for _, craft_category in ipairs(typeobject.craft_category or {}) do
                category_to_entity[craft_category] = category_to_entity[craft_category] or {}
                table.insert(category_to_entity[craft_category], {id = typeobject.id, icon = typeobject.icon})
            end
        end
    end
end

for _, item_info in pairs(item_id_to_info) do
    for _, recipe_info in ipairs(item_info) do
        local recipe_id = recipe_info.recipe_id
        local category = recipe_to_category[recipe_id]
        if category then
            recipe_info.entities = category_to_entity[category] or {}
        end
        recipe_info.recipe_id = nil
    end
end

-- TODO
local function get_headquater_object()
    for _, object in objects:select("CONSTRUCTED", "headquater", true) do
        return object
    end
end

---------------
local M = {}

function M:create(object_id)
    local object = assert(objects:get(cache_names, object_id))
    local typeobject = iprototype:queryByName("entity", object.prototype_name)

    return {
        object_id = object_id,
        prototype_name = iprototype:show_prototype_name(typeobject),
        background = typeobject.background,
        item_category = item_category,
        inventory = {},
        is_chest = not typeobject.headquater,
        item_prototype_name = "",
        item_id_to_info = {},
    }
end

function M:stage_ui_update(datamodel, object_id)
    local object = assert(objects:get(cache_names, object_id))
    local e = gameplay_core.get_entity(assert(object.gameplay_eid))
    if e then
        -- 更新背包界面对应的道具
        local inventory = {}
        local item_counts = ichest:item_counts(gameplay_core.get_world(), e)
        for id, count in pairs(item_counts) do
            local typeobject_item = assert(iprototype:query(id))
            local stack = count

            while stack > 0 do
                local t = {}
                t.id = typeobject_item.id
                t.name = typeobject_item.name
                t.icon = typeobject_item.icon
                t.category = typeobject_item.group

                if stack >= typeobject_item.stack then
                    t.count = typeobject_item.stack
                else
                    t.count = stack
                end

                inventory[#inventory+1] = t
                stack = stack - typeobject_item.stack
            end
        end

        datamodel.inventory = inventory
    end

    for _, _, _, prototype in click_item_mb:unpack() do
        local typeobject = iprototype:query(prototype)
        datamodel.show_item_info = true
        datamodel.item_prototype_name = iprototype:show_prototype_name(typeobject)
        datamodel.item_info = item_id_to_info[tonumber(prototype)] or {}
        self:flush()
    end

    for _, _, _, chest_object_id, prototype in to_chest_mb:unpack() do
        local headquater_object = get_headquater_object()
        if not headquater_object then
            log.error("can not found headquater")
            goto continue
        end

        local headquater_e = gameplay_core.get_entity(assert(headquater_object.gameplay_eid))
        if not headquater_e then
            log.error("can not found headquater")
            goto continue
        end

        local headquater_item_counts = ichest:item_counts(gameplay_core.get_world(), headquater_e)
        if not headquater_item_counts[prototype] then
            log.info(("can not found item `%s`"):format(prototype))
            goto continue
        end

        local chest_object = objects:get(cache_names, chest_object_id)
        if not chest_object then
            log.error(("can not found chest `%s`"):format(chest_object_id))
            goto continue
        end

        local chest_e = gameplay_core.get_entity(chest_object.gameplay_eid)
        if not chest_e then
            log.error(("can not found chest `%s`"):format(chest_object_id))
            goto continue
        end

        local chest_item_counts = ichest:item_counts(gameplay_core.get_world(), chest_e)
        if not chest_item_counts[prototype] then
            log.info(("can not found item `%s`"):format(prototype))
            goto continue
        end

        --
        local typeobject_item = iprototype:query(prototype)
        if chest_item_counts[prototype] >= typeobject_item.stack then
            log.info(("stack `%s`"):format(typeobject_item.stack))
            goto continue
        end

        local pickup_count = math.min(typeobject_item.stack - chest_item_counts[prototype], headquater_item_counts[prototype])
        ichest:pickup_place(gameplay_core.get_world(), headquater_e, chest_e, prototype, pickup_count)
        self:tick(datamodel, object_id)
        self:flush()
        ::continue::
    end

    for _, _, _, chest_object_id, prototype in to_headquater_mb:unpack() do
        local headquater_object = get_headquater_object()
        if not headquater_object then
            log.error("can not found headquater")
            goto continue
        end

        local headquater_e = gameplay_core.get_entity(assert(headquater_object.gameplay_eid))
        if not headquater_e then
            log.error("can not found headquater")
            goto continue
        end

        local chest_object = objects:get(cache_names, chest_object_id)
        if not chest_object then
            log.error(("can not found chest `%s`"):format(chest_object_id))
            goto continue
        end

        local chest_e = gameplay_core.get_entity(chest_object.gameplay_eid)
        if not chest_e then
            log.error(("can not found chest `%s`"):format(chest_object_id))
            goto continue
        end

        local chest_item_counts = ichest:item_counts(gameplay_core.get_world(), chest_e)
        if not chest_item_counts[prototype] then
            log.info(("can not found item `%s`"):format(prototype))
            goto continue
        end

        ichest:pickup_place(gameplay_core.get_world(), chest_e, headquater_e, prototype, chest_item_counts[prototype])
        self:tick(datamodel, object_id)
        self:flush()
        ::continue::
    end
end

function M:update(datamodel)
    self:tick(datamodel, datamodel.object_id)
    self:flush()
end

return M