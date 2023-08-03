#include <lua.hpp>

#include "luaecs.h"
#include "core/world.h"
#include "core/capacitance.h"

#define STATUS_IDLE 0
#define STATUS_DONE 1
#define STATUS_WORKING 2

static void
sync_input_fluidbox(world& w, ecs::assembling& assembling, ecs::chest& c2, ecs::fluidboxes& fb) {
    if (assembling.fluidbox_in == 0) {
        return;
    }
    for (size_t i = 0; i < 4; ++i) {
        uint16_t fluid = fb.in[i].fluid;
        if (fluid != 0) {
            uint8_t index = ((assembling.fluidbox_in >> (i*4)) & 0xF) - 1;
            uint16_t value = chest::get_fluid(w, container::index::from(c2.chest), index);
            w.fluidflows[fluid].set(fb.in[i].id, value);
        }
    }
}

static void
sync_output_fluidbox(world& w, ecs::assembling& assembling, ecs::chest& c2, ecs::fluidboxes& fb) {
    if (assembling.fluidbox_out == 0) {
        return;
    }
    for (size_t i = 0; i < 3; ++i) {
        uint16_t fluid = fb.out[i].fluid;
        if (fluid != 0) {
            uint8_t index = ((assembling.fluidbox_out >> (i*4)) & 0xF) - 1;
            uint16_t value = chest::get_fluid(w, container::index::from(c2.chest), index);
            w.fluidflows[fluid].set(fb.out[i].id, value);
        }
    }
}

static bool assembling_update(world& w, ecs::assembling& assembling, ecs::chest& chest, ecs::fluidboxes* fb) {
    while (assembling.progress <= 0) {
        if (assembling.status == STATUS_DONE) {
            if (!chest::place(w, container::index::from(chest.chest), assembling.recipe)) {
                return false;
            }
            w.stat.finish_recipe(w, assembling.recipe);
            assembling.status = STATUS_IDLE;
            if (fb) {
                sync_output_fluidbox(w, assembling, chest, *fb);
            }
        }
        if (assembling.status == STATUS_IDLE) {
            if (!chest::pickup(w, container::index::from(chest.chest), assembling.recipe)) {
                return false;
            }
            auto time = prototype::get<"time">(w, assembling.recipe);
            assembling.progress += time * 100;
            assembling.status = STATUS_DONE;
            if (fb) {
                sync_input_fluidbox(w, assembling, chest, *fb);
            }
        }
    }
    return true;
}

static int
lupdate(lua_State *L) {
    auto& w = getworld(L);
    for (auto& v : ecs_api::select<ecs::assembling, ecs::chest, ecs::building>(w.ecs)) {
        bool is_consumer = v.component<ecs::consumer>();
        bool is_generator = v.component<ecs::generator>();
        ecs::assembling& assembling = v.get<ecs::assembling>();
        if (is_consumer && is_generator) {
            continue;
        }
        else if (is_consumer) {
            auto capacitance = v.component<ecs::capacitance>();
            if (!capacitance) {
                continue;
            }
            auto consumer = get_consumer(w, v, *capacitance);
            if (!consumer.cost_drain()) {
                continue;
            }
            if (assembling.recipe == 0) {
                continue;
            }
            ecs::chest& chest = v.get<ecs::chest>();
            ecs::fluidboxes* fb = v.component<ecs::fluidboxes>();
            if (consumer.cost_power()) {
                if (assembling_update(w, assembling, chest, fb)) {
                    assembling.progress -= assembling.speed;
                    assembling_update(w, assembling, chest, fb);
                }
            }
            else {
                assembling_update(w, assembling, chest, fb);
            }
        }
        else if (is_generator) {
            auto capacitance = v.component<ecs::capacitance>();
            if (!capacitance) {
                continue;
            }
            if (assembling.recipe == 0) {
                continue;
            }
            ecs::chest& chest = v.get<ecs::chest>();
            ecs::fluidboxes* fb = v.component<ecs::fluidboxes>();
            auto generator = get_generator(w, v, *capacitance);
            if (generator.produce()) {
                if (assembling_update(w, assembling, chest, fb)) {
                    assembling.progress -= assembling.speed;
                    assembling_update(w, assembling, chest, fb);
                }
            }
            else {
                assembling_update(w, assembling, chest, fb);
            }
        }
        else {
            if (assembling.recipe == 0) {
                continue;
            }
            ecs::chest& chest = v.get<ecs::chest>();
            ecs::fluidboxes* fb = v.component<ecs::fluidboxes>();
            if (assembling_update(w, assembling, chest, fb)) {
                assembling.progress -= assembling.speed;
                assembling_update(w, assembling, chest, fb);
            }
        }
    }
    return 0;
}

extern "C" int
luaopen_vaststars_assembling_system(lua_State *L) {
    luaL_checkversion(L);
    luaL_Reg l[] = {
        { "update", lupdate },
        { NULL, NULL },
    };
    luaL_newlib(L, l);
    return 1;
}
