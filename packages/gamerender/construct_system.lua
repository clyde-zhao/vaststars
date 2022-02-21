local ecs = ...
local world = ecs.world
local w = world.w

local fs = require "filesystem"
local serialize = import_package "ant.serialize"
local cr = import_package "ant.compile_resource"
local iinput = ecs.import.interface "vaststars.input|iinput"
local iom = ecs.import.interface "ant.objcontroller|iobj_motion"
local icamera = ecs.import.interface "ant.camera|icamera"
local imaterial = ecs.import.interface "ant.asset|imaterial"
local iui = ecs.import.interface "vaststars.ui|iui"
local iterrain = ecs.import.interface "vaststars.gamerender|iterrain"
local iroad = ecs.import.interface "vaststars.gamerender|iroad"
local ipipe = ecs.import.interface "vaststars.gamerender|ipipe"
local igame_object = ecs.import.interface "vaststars.gamerender|igame_object"
local iprefab_object = ecs.import.interface "vaststars.gamerender|iprefab_object"
local igameplay_adapter = ecs.import.interface "vaststars.gamerender|igameplay_adapter"
local icanvas = ecs.import.interface "vaststars.gamerender|icanvas"

local math3d = require "math3d"
local mathpkg = import_package "ant.math"
local mc = mathpkg.constant
local entities_cfg = import_package "vaststars.config".entity
local backers_cfg = import_package "vaststars.config".backers
local fluid_list_cfg = import_package "vaststars.config".fluid_list
local utility = import_package "vaststars.utility"
local dir_rotate = utility.dir.rotate
local dir_offset_of_entry = utility.dir.offset_of_entry

local CONSTRUCT_RED_BASIC_COLOR <const> = {50.0, 0.0, 0.0, 0.8}
local CONSTRUCT_GREEN_BASIC_COLOR <const> = {0.0, 50.0, 0.0, 0.8}

local ui_construct_building_mb = world:sub {"ui", "construct", "click_construct"}
local ui_construct_confirm_mb = world:sub {"ui", "construct", "click_construct_confirm"}
local ui_construct_cancel_mb = world:sub {"ui", "construct", "click_construct_cancel"}
local ui_construct_rotate_mb = world:sub {"ui", "construct", "click_construct_rotate"}
local ui_remove_message_mb = world:sub {"ui", "construct", "click_construct_remove"}
local ui_get_fluid_catagory = world:sub {"ui", "GET_DATA", "fluid_catagory"}

local pickup_show_remove_mb = world:sub {"pickup_mapping", "pickup_show_remove"}
local pickup_show_ui_mb = world:sub {"pickup_mapping", "pickup_show_ui"}
local drapdrop_entity_mb = world:sub {"drapdrop_entity"}
local construct_sys = ecs.system "construct_system"

local get_fluid_catagory; do
    local function is_type(prototype, t)
        for _, v in ipairs(prototype.type) do
            if v == t then
                return true
            end
        end
        return false
    end

    local t = {}
    for _, v in pairs(igameplay_adapter.prototype_name()) do
        if is_type(v, 'fluid') then
            for _, c in ipairs(v.catagory) do
                t[c] = t[c] or {}
                t[c][#t[c]+1] = {id = v.id, name = v.name, icon = v.icon}
            end
        end
    end

    local r = {}
    for catagory, v in pairs(t) do
        r[#r+1] = {catagory = catagory, icon = fluid_list_cfg[catagory].icon, pos = fluid_list_cfg[catagory].pos, fluid = v}
        table.sort(v, function(a, b) return a.id < b.id end)
    end
    table.sort(r, function(a, b) return a.pos < b.pos end)

    -- = {{catagory = xxx, icon = xxx, fluid = {{id = xxx, name = xxx, icon = xxx}, ...} }, ...}
    function get_fluid_catagory()
        return r
    end
end

local check_construct_detector; do
    local base_path = fs.path('/pkg/vaststars.gamerender/construct_detector/')
    local construct_detectors = {}
    for f in fs.pairs(base_path) do
        local detector = fs.relative(f, base_path):stem():string()
        construct_detectors[detector] = ecs.require(('construct_detector.%s'):format(detector))
    end

    function check_construct_detector(detectors, position, dir, area)
        local func
        for _, v in ipairs(detectors) do
            func = construct_detectors[v]
            if not func(position, dir, area) then
                return false
            end
        end
        return true
    end
end

local function replace_material(template)
    for _, v in ipairs(template) do
        for _, policy in ipairs(v.policy) do
            if policy == "ant.render|render" or policy == "ant.render|simplerender" then
                v.data.material = "/pkg/vaststars.resources/construct.material"
            end
        end
    end

    return template
end

local function __update_basecolor_by_pos(game_object)
    w:sync("construct_detector:in dir:in prototype:in", game_object)

    local basecolor_factor
    local prefab = igame_object.get_prefab(game_object)
    local position = math3d.tovalue(iom.get_position(prefab.root))

    if game_object.construct_detector then
        local entity = igameplay_adapter.query("entity", game_object.prototype)
        if not check_construct_detector(game_object.construct_detector, position, game_object.dir, entity.area) then
            basecolor_factor = CONSTRUCT_RED_BASIC_COLOR
        else
            basecolor_factor = CONSTRUCT_GREEN_BASIC_COLOR
        end
    else
        basecolor_factor = CONSTRUCT_GREEN_BASIC_COLOR
    end

    for _, e in ipairs(prefab.tag["*"]) do
        w:sync("material?in", e)
        if e.material then
            imaterial.set_property(e, "u_basecolor_factor", basecolor_factor)
        end
    end
end

local on_prefab_ready; do
    local canvas_itemids = {}
    function on_prefab_ready(game_object, prefab)
        icanvas.remove_item(table.unpack(canvas_itemids))

        local position = math3d.tovalue(iom.get_position(prefab.root))
        __update_basecolor_by_pos(game_object)
        local coord = iterrain.get_coord_by_position(position)
        local coord_offset = {
            {name = "confirm.png", coord = {-1, 1}},
            {name = "cancel.png",  coord = {1,  1}},
            {name = "rotate.png",  coord = {0,  -1}},
        }

        local items = {}
        for _, v in ipairs(coord_offset) do
            local item = {
                name = v.name,
                x = coord[1] + v.coord[1],
                y = coord[2] + v.coord[2],
            }

            items[#items+1] = item
        end
        canvas_itemids = icanvas.add_items(table.unpack(items))
    end
end

local on_prefab_message ; do
    local funcs = {}
    funcs["basecolor"] = function(game_object)
        __update_basecolor_by_pos(game_object)
    end

    funcs["confirm_construct"] = function(game_object, prefab)
        local position = math3d.tovalue(iom.get_position(prefab.root))
        local srt = prefab.root.scene.srt

        w:sync("construct_detector?in dir:in", game_object)
        if game_object.construct_detector then
            local entity = igameplay_adapter.query("entity", game_object.prototype)
            if not check_construct_detector(game_object.construct_detector, position, game_object.dir, entity.area) then
                print("can not construct") -- todo error tips
                return
            end
        end

        -- create entity
        local coord = iterrain.get_coord_by_position(position)
        w:sync("construct_road?in construct_pipe?in dir:in construct_prefab:in construct_entity:in", game_object)

        if game_object.construct_road then
            iroad.construct(nil, coord)
        elseif game_object.construct_pipe then
            ipipe.construct(nil, coord, game_object.dir)
        else
            local new_prefab = ecs.create_instance(("/pkg/vaststars.resources/%s"):format(game_object.construct_prefab))
            iom.set_srt(new_prefab.root, srt.s, srt.r, srt.t)
            local template = {
                policy = {},
                data = {
                    prototype = game_object.prototype,
                    pause_animation = true,
                    x = coord[1],
                    y = coord[2],
                    dir = game_object.dir,
                    area = igameplay_adapter.query("entity", game_object.prototype).area,
                }
            }

            for k, v in pairs(game_object.construct_entity) do
                template.data[k] = v
            end

            new_prefab.on_ready = function(game_object, prefab)
                w:sync("prototype:in x:in y:in dir:in", game_object)
                local entity = igameplay_adapter.query("entity", game_object.prototype)
                local area = {}
                area[1], area[2] = igameplay_adapter.unpack_coord(entity.area)

                local gameplay_entity = {
                    x = game_object.x,
                    y = game_object.y,
                    dir = game_object.dir,
                }

                w:sync("station?in", game_object)
                if game_object.station then
                    w:sync("scene:in", prefab.root)
                    gameplay_entity.station = {
                        id = prefab.root.scene.id,
                        coord = igameplay_adapter.pack_coord(coord[1], coord[2] + (-1 * (area[2] // 2)) - 1),
                    }
                end

                igameplay_adapter.create_entity(game_object.prototype, gameplay_entity)
            end
            iprefab_object.create(new_prefab, template)
        end

        -- remove construct entity
        world:pub {"ui_message", "construct_show_confirm", false}
        prefab:remove()
    end

    function on_prefab_message(game_object, prefab, cmd, ...)
        local func = funcs[cmd]
        if func then
            func(game_object, prefab, ...)
        end
    end
end

function construct_sys:entity_init()
    --
	for e in w:select "INIT x:in y:in area:in prototype:in" do
        iterrain.set_tile_building_type({e.x, e.y}, e.prototype, e.area)
    end

    --
    for e in w:select "INIT set_road_entry:in x:in y:in dir:in area:in" do
        local offset = dir_offset_of_entry(e.dir)
        local width, heigh = igameplay_adapter.unpack_coord(e.area)
        local coord = {
            e.x + offset[1] + (offset[1] * (width // 2)),
            e.y + offset[2] + (offset[2] * (heigh // 2)),
        }

        iroad.set_building_entry(coord, e.dir)
    end
    w:clear "set_road_entry"

    --
    for e in w:select "INIT random_name:in name:out" do
        e.name = backers_cfg[math.random(1, #backers_cfg)]
    end
end

function construct_sys:camera_usage()
    local position
    for _, game_object, mouse_x, mouse_y in drapdrop_entity_mb:unpack() do
        local prefab_object = igame_object.get_prefab_object(game_object)
        position = iinput.screen_to_world {mouse_x, mouse_y}
        position = iterrain.get_tile_centre_position(math3d.tovalue(position))
        iom.set_position(prefab_object.root, position)
        local coord1, coord2, coord3 = iterrain.get_confirm_ui_position(position)
        world:pub {"ui_message", "construct_show_confirm", true, math3d.tovalue(icamera.world_to_screen(coord1)), math3d.tovalue(icamera.world_to_screen(coord2)), math3d.tovalue(icamera.world_to_screen(coord3)) }
        prefab_object:send("basecolor")
    end
end

function construct_sys:data_changed()
    local cfg
    for _, _, _, prototype in ui_construct_building_mb:unpack() do
        cfg = entities_cfg[prototype]
        if cfg then
            for game_object in w:select "construct_entity:in" do
                igame_object.get_prefab_object(game_object):remove()
            end

            local f = ("/pkg/vaststars.resources/%s"):format(cfg.prefab)
            local template = replace_material(serialize.parse(f, cr.read_file(f)))
            local prefab = ecs.create_instance(template)
            iom.set_position(prefab.root, iterrain.get_tile_centre_position({0, 0, 0})) -- todo 可能需要根据屏幕中间位置来设置?

            local t = {
                policy = {},
                data = {
                    prototype = prototype,
                    drapdrop = false,
                    construct_entity = cfg.component,
                    pause_animation = true,
                    dir = 'N',
                    x = 0,
                    y = 0,
                    construct_prefab = cfg.prefab,
                },
            }

            for k, v in pairs(cfg.construct_component) do
                t.data[k] = v
            end

            prefab.on_message = on_prefab_message
            prefab.on_ready = on_prefab_ready
            iprefab_object.create(prefab, t)
        else
            print(("Can not found prototype `%s`"):format(prototype))
        end
    end

    local prefab_object
    for _, _, _ in ui_construct_confirm_mb:unpack() do
        for game_object in w:select "construct_entity:in" do
            prefab_object = igame_object.get_prefab_object(game_object)
            prefab_object:send("confirm_construct")
        end
    end

    for _, _, _ in ui_construct_cancel_mb:unpack() do
        for game_object in w:select "construct_entity:in" do
            prefab_object = igame_object.get_prefab_object(game_object)
            world:pub {"ui_message", "construct_show_confirm", false}
            prefab_object:remove()
        end
    end

    for _, _, _ in ui_construct_rotate_mb:unpack() do
        for game_object in w:select "construct_entity:in dir:in" do
            game_object.dir = dir_rotate(game_object.dir, -1)
            w:sync("dir:out", game_object)
            prefab_object = igame_object.get_prefab_object(game_object)
            local rotation = iom.get_rotation(prefab_object.root)
            local deg = math.deg(math3d.tovalue(math3d.quat2euler(rotation))[2])
            iom.set_rotation(prefab_object.root, math3d.quaternion{axis=mc.YAXIS, r=math.rad(deg - 90)})
            __update_basecolor_by_pos(game_object)
        end
    end

    for _ in ui_remove_message_mb:unpack() do
        for game_object in w:select("pickup_show_remove:in pickup_show_set_road_arrow?in pickup_show_set_pipe_arrow?in x:in y:in area:in") do
            if game_object and game_object.pickup_show_remove and not game_object.pickup_show_set_road_arrow and not game_object.pickup_show_set_pipe_arrow then
                igame_object.get_prefab_object(game_object):remove()
                iterrain.set_tile_building_type({game_object.x, game_object.y}, nil, game_object.area)
                igameplay_adapter.remove_entity(game_object.x, game_object.y)
                world:pub {"ui_message", "construct_show_remove", nil}
            end
        end
    end

    for _ in ui_get_fluid_catagory:unpack() do
        world:pub {"ui_message", "SET_DATA", {["fluid_catagory"] = get_fluid_catagory()}}
    end
end

function construct_sys:after_pickup_mapping()
    local url
    for _, _, entity in pickup_show_ui_mb:unpack() do
        w:sync("pickup_show_ui:in", entity)
        url = entity.pickup_show_ui.url
        iui.open(url)
    end

    -- local show_pickup_show_remove
    -- for _, _, game_object in pickup_show_remove_mb:unpack() do
    --     w:sync("x:in y:in pickup_show_remove:in ", game_object)
    --     local pos = iterrain.get_begin_position_by_coord(game_object.x, game_object.y)
    --     world:pub {"ui_message", "construct_show_remove", math3d.tovalue(icamera.world_to_screen(pos))}
    --     game_object.pickup_show_remove = true
    --     w:sync("pickup_show_remove:out", game_object)
    --     show_pickup_show_remove = true
    -- end

    -- for _ in pickup_mb:unpack() do
    --     if not show_pickup_show_remove then
    --         for e in w:select("pickup_show_remove:update") do
    --             e.pickup_show_remove = false
    --         end

    --         world:pub {"ui_message", "construct_show_remove", nil}
    --         break
    --     end
    -- end
end
