#include <lua.hpp>
#include <assert.h>
#include <string.h>

#include "luaecs.h"
#include "core/world.h"
#include "core/entity.h"
extern "C" {
#include "util/prototype.h"
}

#define STATUS_IDLE 0
#define STATUS_DONE 1

static void
checkFinish(world& w, ecs::burner& b) {
	if (b.progress == STATUS_DONE) {
		prototype_context recipe = w.prototype(b.recipe);
		recipe_container& container = w.query_container<recipe_container>(b.container);
		recipe_items* r = (recipe_items*)pt_results(&recipe);
		if (container.recipe_place(w, r)) {
			b.progress = STATUS_IDLE;
		}
	}
}

static int
lupdate(lua_State *L) {
	world& w = *(world*)lua_touserdata(L, 1);
	for (auto& v: w.select<ecs::burner, ecs::entity, ecs::capacitance>()) {
		ecs::capacitance& c = v.get<ecs::capacitance>();
		if (c.shortage <= 0) {
			checkFinish(w, v.get<ecs::burner>());
			continue;
		}
		ecs::entity& e = v.get<ecs::entity>();
		prototype_context p = w.prototype(e.prototype);
		unsigned int power = pt_power(&p);
		if (c.shortage < power) {
			checkFinish(w, v.get<ecs::burner>());
			continue;
		}
		ecs::burner& b = v.get<ecs::burner>();
		if (b.progress == STATUS_DONE || b.progress == STATUS_IDLE) {
			prototype_context recipe = w.prototype(b.recipe);
			recipe_container& container = w.query_container<recipe_container>(b.container);
			if (b.progress == STATUS_DONE) {
				recipe_items* items = (recipe_items*)pt_results(&recipe);
				if (container.recipe_place(w, items)) {
					b.progress = STATUS_IDLE;
				}
			}
			if (b.progress == STATUS_IDLE) {
				recipe_items* items = (recipe_items*)pt_ingredients(&recipe);
				if (container.recipe_pickup(w, items)) {
					int time = pt_time(&recipe);
					b.progress = time + STATUS_DONE;
				}
			}
		}
		if (b.progress == STATUS_DONE || b.progress == STATUS_IDLE) {
			continue;
		}

		c.shortage -= power;
		b.progress--;
	}
	return 0;
}

extern "C" int
luaopen_vaststars_burner_system(lua_State *L) {
	luaL_checkversion(L);
	luaL_Reg l[] = {
		{ "update", lupdate },
		{ NULL, NULL },
	};
	luaL_newlib(L, l);
	return 1;
}
