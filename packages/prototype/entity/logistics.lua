local gameplay = import_package "vaststars.gameplay"
local prototype = gameplay.register.prototype

local function prototype_road(name)
    return function (object)
        assert(object.crossing)

        local connections = object.crossing.connections
        local len = (1 << #connections) - 1

        for i = 0, len do
            local o = {}
            for k, v in pairs(object) do
                if k ~= "crossing" then
                    o[k] = v
                end
            end
            o.crossing = { connections = {} }

            for j = 1, #connections do
                local roadside
                if i & (1 << (j - 1)) ~= 0 then
                   roadside = true
                end
                o.crossing.connections[j] = {
                    type = connections[j].type,
                    position = connections[j].position,
                    roadside = roadside
                }
            end

            prototype(name:format(i + 1))(o)
        end
    end
end

prototype "指挥中心" {
    model = "prefabs/headquater-1.prefab",
    icon = "textures/building_pic/small_pic_headquarter.texture",
    background = "textures/build_background/pic_headquater.texture",
    construct_detector = {"exclusive"},
    type ={"entity", "generator", "chest", "base"},
    area = "5x5",
    supply_area = "9x9",
    supply_distance = 9,
    power = "1MW",
    priority = "primary",
    group = {"物流"},
    slots = 70,
    headquater = true,
    teardown = false,
}

prototype "物流派送站" {
    model = "prefabs/goods-station-output-1.prefab",
    icon = "textures/building_pic/small_pic_goodsstation_output.texture",
    background = "textures/build_background/small_pic_goodsstation_output.texture",
    construct_detector = {"exclusive"},
    type = {"entity", "chest"},
    area = "1x1",
    slots = 10,
    group = {"物流"},
}

prototype "物流需求站" {
    model = "prefabs/goods-station-input-1.prefab",
    icon = "textures/building_pic/small_pic_goodsstation_input.texture",
    background = "textures/build_background/small_pic_goodsstation_input.texture",
    construct_detector = {"exclusive"},
    type = {"entity", "chest"},
    area = "1x1",
    slots = 10,
    group = {"物流"},
}

prototype "物流中心I" {
    model = "prefabs/logistics-center-1.prefab",
    icon = "textures/building_pic/small_pic_logistics_center2.texture",
    background = "textures/build_background/pic_logisticscenter.texture",
    construct_detector = {"exclusive"},
    type ={"entity", "consumer"},
    area = "3x3",
    power = "300kW",
    priority = "secondary",
    group = {"物流"},
}

prototype "运输车辆I" {
    model = "prefabs/mars-truck.prefab",
    icon = "textures/building_pic/small_pic_mars_truck.texture",
    background = "textures/build_background/pic_mars_truck.texture",
    construct_detector = {"exclusive"},
    type ={"entity", "consumer"},
    area = "1x1",
    power = "80kW",
    stop_energy = "500kJ",
    capacitance = "10MJ",
    priority = "secondary",
    group = {"物流"},
    velocity = 3,
    room = 1,
    acceleration = 1.5,
    brake = 7.5,
    charge_power = "500kW",
}

prototype "机器爪I" {
    model = "prefabs/inserter-1.prefab",
    icon = "textures/building_pic/small_pic_inserter.texture",
    construct_detector = {"exclusive"},
    type = {"entity", "inserter", "consumer"},
    area = "1x1",
    speed = "1s",
    power = "12kW",
    priority = "secondary",
    group = {"物流","默认"},
}

prototype "科研中心I" {
    type ={"entity", "consumer","laboratory"},
    model = "prefabs/lab-1.prefab",
    icon = "textures/building_pic/small_pic_lab.texture",
    background = "textures/build_background/pic_lab.texture",
    construct_detector = {"exclusive"},
    area = "3x3",
    power = "150kW",
    speed = "100%",
    priority = "secondary",
    inputs = {
        "地质科技包",
        "气候科技包",
        "机械科技包",
    },
    group = {"物流"},
}

prototype_road "砖石公路-I型-%02d" {
    model = "prefabs/road/road_I.prefab",
    show_prototype_name = "砖石公路-I型",
    icon = "textures/construct/road1.texture",
    construct_detector = {"exclusive"},
    flow_type = 11,
    teardown = 20,
    flow_direction = {"N", "E"},
    track = "I",
    tickcount = 20,
    show_build_function = false,
    type ={"entity", "road"},
    area = "1x1",
    crossing = {
        connections = {
            {type="input-output", position={0,0,"N"}},
            {type="input-output", position={0,0,"S"}},
        },
    }
}

prototype_road "砖石公路-L型-%02d" {
    model = "prefabs/road/road_L.prefab",
    show_prototype_name = "砖石公路-I型",
    icon = "textures/construct/road1.texture",
    construct_detector = {"exclusive"},
    flow_type = 11,
    teardown = 20,
    flow_direction = {"N", "E", "S", "W"},
    track = "L",
    tickcount = 20,
    show_build_function = false,
    type ={"entity", "road"},
    area = "1x1",
    crossing = {
        connections = {
            {type="input-output", position={0,0,"N"}},
            {type="input-output", position={0,0,"E"}},
        },
    }
}

prototype_road "砖石公路-T型-%02d" {
    model = "prefabs/road/road_T.prefab",
    show_prototype_name = "砖石公路-I型",
    icon = "textures/construct/road1.texture",
    construct_detector = {"exclusive"},
    flow_type = 11,
    teardown = 20,
    flow_direction = {"N", "E", "S", "W"},
    track = "T",
    tickcount = 20,
    show_build_function = false,
    type ={"entity", "road"},
    area = "1x1",
    crossing = {
        connections = {
            {type="input-output", position={0,0,"E"}},
            {type="input-output", position={0,0,"S"}},
            {type="input-output", position={0,0,"W"}},
        },
    }
}

prototype_road "砖石公路-X型-%02d" {
    show_prototype_name = "砖石公路-I型",
    model = "prefabs/road/road_X.prefab",
    icon = "textures/construct/road1.texture",
    construct_detector = {"exclusive"},
    flow_type = 11,
    teardown = 20,
    flow_direction = {"N"},
    track = "X",
    tickcount = 20,
    show_build_function = false,
    type ={"entity", "road"},
    area = "1x1",
    crossing = {
        connections = {
            {type="input-output", position={0,0,"N"}},
            {type="input-output", position={0,0,"E"}},
            {type="input-output", position={0,0,"S"}},
            {type="input-output", position={0,0,"W"}},
        },
    }
}

prototype "砖石公路-O型-01" {
    model = "prefabs/road/road_O.prefab",
    show_prototype_name = "砖石公路-I型",
    icon = "textures/construct/road1.texture",
    construct_detector = {"exclusive"},
    flow_type = 11,
    teardown = 20,
    flow_direction = {"N"},
    track = "O",
    tickcount = 0,
    show_build_function = false,
    type ={"entity", "road"},
    area = "1x1",
    group = {"物流","默认"},
    crossing = {
        connections = {
        }
    }
}

prototype_road "砖石公路-U型-%02d" {
    model = "prefabs/road/road_U.prefab",
    show_prototype_name = "砖石公路-I型",
    icon = "textures/construct/road1.texture",
    construct_detector = {"exclusive"},
    flow_type = 11,
    teardown = 20,
    flow_direction = {"N", "E", "S", "W"},
    track = "U",
    tickcount = 20,
    show_build_function = false,
    type ={"entity", "road"},
    area = "1x1",
    crossing = {
        connections = {
            {type="input-output", position={0,0,"N"}},
        },
    }
}

prototype "修路设备箱" {
    model = "prefabs/small-chest.prefab",
    icon = "textures/building_pic/small_pic_chest.texture",
    background = "textures/build_background/pic_chest.texture",
    construct_detector = {"exclusive"},
    type = {"entity"},
    area = "1x1",
    supply_area = "21x21",
}

prototype "管道设备箱" {
    model = "prefabs/small-chest.prefab",
    icon = "textures/building_pic/small_pic_chest.texture",
    background = "textures/build_background/pic_chest.texture",
    construct_detector = {"exclusive"},
    type = {"entity"},
    area = "1x1",
    supply_area = "21x21",
}

prototype "电网设备箱" {
    model = "prefabs/small-chest.prefab",
    icon = "textures/building_pic/small_pic_chest.texture",
    background = "textures/build_background/pic_chest.texture",
    construct_detector = {"exclusive"},
    type = {"entity"},
    area = "1x1",
    supply_area = "21x21",
}