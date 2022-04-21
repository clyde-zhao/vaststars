local gameplay = import_package "vaststars.gameplay"
local prototype = gameplay.prototype

prototype "铁制电线杆" {
    model = "prefabs/electric-pole-1.prefab",
    icon = "construct/electric-pole1.png",
    construct_detector = {"exclusive"},
    type = {"entity", "pole"},
    area = "1x1",
    supply_area = "5x5"
}
