local gameplay = import_package "vaststars.gameplay"
local prototype = gameplay.prototype

prototype "液罐1" {
    type ={"entity", "fluidbox"},
    area = "3x3",
    fluidbox = {
        capacity = 15000,
        height = 200,
        base_level = 0,
        connections = {
            {type="input-output", position={0,0,"N"}},
            {type="input-output", position={2,2,"E"}},
            {type="input-output", position={2,2,"S"}},
            {type="input-output", position={0,0,"W"}},
        }
    }
}

prototype "抽水泵" {
    type ={"entity", "consumer", "assembling", "fluidboxes"},
    area = "1x2",
    power = "6kW",
    priority = "secondary",
    recipe = "离岸抽水",
    fluidboxes = {
        input = {},
        output = {
            {
                capacity = 300,
                height = 100,
                base_level = 150,
                connections = {
                    {type="output", position={0,0,"S"}},
                }
            }
        }
    }
}

prototype "压力泵1" {
    type ={"entity", "consumer", "fluidbox", "pump"},
    area = "1x2",
    power = "10kW",
    drain = "300W",
    priority = "secondary",
    fluidbox = {
        capacity = 500,
        height = 300,
        base_level = 0,
        pumping_speed = 1200,
        connections = {
            {type="output", position={0,0,"N"}},
            {type="input", position={0,1,"S"}},
        }
    }
}

prototype "烟囱1" {
    type ={"entity", "fluidbox"},
    area = "2x2",
    fluidbox = {
        capacity = 1000,
        height = 100,
        base_level = 10,
        connections = {
            {type="input", position={0,0,"N"}},
        }
    }
}

prototype "排水口1" {
    type ={"entity", "fluidbox"},
    area = "3x3",
    fluidbox = {
        capacity = 1000,
        height = 100,
        base_level = 10,
        connections = {
            {type="input", position={1,0,"N"}},
        }
    }
}

prototype "空气过滤器1" {
    type ={"entity", "consumer","assembling","fluidboxes"},
    area = "3x3",
    power = "50kW",
    drain = "1.5kW",
    priority = "secondary",
    recipe = "空气过滤",
    fluidboxes = {
        input = {},
        output = {
            {
                capacity = 1000,
                height = 200,
                base_level = 150,
                connections = {
                    {type="output", position={1,2,"S"}},
                }
            }
        },
    }
}


prototype "管道1-I型" {
    type = {"entity","fluidbox"},
    area = "1x1",
    fluidbox = {
        capacity = 100,
        height = 100,
        base_level = 0,
        connections = {
            {type="input-output", position={0,0,"N"}},
            {type="input-output", position={0,0,"S"}},
        }
    }
}

prototype "管道1-L型" {
    type = {"entity","fluidbox"},
    area = "1x1",
    fluidbox = {
        capacity = 100,
        height = 100,
        base_level = 0,
        connections = {
            {type="input-output", position={0,0,"N"}},
            {type="input-output", position={0,0,"E"}},
        }
    }
}

prototype "管道1-T型" {
    type = {"entity","fluidbox"},
    area = "1x1",
    fluidbox = {
        capacity = 100,
        height = 100,
        base_level = 0,
        connections = {
            {type="input-output", position={0,0,"E"}},
            {type="input-output", position={0,0,"S"}},
            {type="input-output", position={0,0,"W"}},
        }
    }
}

prototype "管道1-X型" {
    type = {"entity","fluidbox"},
    area = "1x1",
    fluidbox = {
        capacity = 100,
        height = 100,
        base_level = 0,
        connections = {
            {type="input-output", position={0,0,"N"}},
            {type="input-output", position={0,0,"E"}},
            {type="input-output", position={0,0,"S"}},
            {type="input-output", position={0,0,"W"}},
        }
    }
}

prototype "地下管1" {
    type ={"entity","pipe-to-ground","fluidbox"},
    area = "1x1",
    max_distance = 10,
    fluidbox = {
        capacity = 100,
        height = 100,
        base_level = 0,
        connections = {
            {type="input-output", position={0,0,"N"}},
            {type="input-output", position={0,0,"S"}},
        }
    }
}