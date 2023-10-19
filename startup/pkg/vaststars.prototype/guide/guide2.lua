local guide2 = {
	{
        name = "",
		narrative = {
            {"哔哩..欢迎进入{/g 电网教学}", "/pkg/vaststars.resources/ui/textures/guide/guide-6.texture"},
        },
        narrative_end = {
            pop_chapter = {"教学","电网搭建"},
            task = {
                "电网教学",
            },
            guide_progress = 1,
        },
        prerequisites = {},
	},

	{
        name = "",
		narrative = {
            {"哔哩..检查地面上的{/color:4bd0ff 废墟堆},拾取残余{/g 物资}..哔哩..(期待)", "/pkg/vaststars.resources/ui/textures/guide/guide-6.texture"},
        },
        narrative_end = {
            task = {
                "检查废墟",
            },
            guide_progress = 2,
        },
        prerequisites = {
            "电网教学",
        },
	},

	{
        name = "",
		narrative = {
            {"哔哩..放置{/color:4bd0ff 采矿机}准备开采矿物..哔哩..(期待)", "/pkg/vaststars.resources/ui/textures/guide/guide-6.texture"},
        },
        narrative_end = {
            task = {
                "矿区搭建",
            },
            guide_progress = 10,
        },
        prerequisites = {
            "检查废墟",
        },
	},

    {
        name = "",
		narrative = {
            {"哔哩..所有{/color:4bd0ff 采矿机}处于{/r 缺电状态},这不是我们希望的..哔哩..(担忧)", "/pkg/vaststars.resources/ui/textures/guide/guide-6.texture"},
            {"哔哩..请放置1台{/g 轻型风力发电机}给矿区{/color:4bd0ff 供电}..哔哩..(期待)", "/pkg/vaststars.resources/ui/textures/guide/guide-6.texture"},
        },
        narrative_end = {
            task = {
                "风力发电机放置",
            },
            guide_progress = 10,
        },
        prerequisites = {
            "矿区搭建",
        },
	},

    {
        name = "",
		narrative = {
            {"哔哩..{/color:4bd0ff 风力发电机}可给设备供电,所有的{/g 采矿机}都正常运转了..哔哩..(期待)", "/pkg/vaststars.resources/ui/textures/guide/guide-6.texture"},
            {"哔哩..现在设置{/color:4bd0ff 仓库}收货{/g 碎石}、{/g 铁矿石}、{/g 铝矿石}..哔哩..(期待)", "/pkg/vaststars.resources/ui/textures/guide/guide-6.texture"},
        },
        narrative_end = {
            task = {
                "收集矿石",
            },
            guide_progress = 10,
        },
        prerequisites = {
            "风力发电机放置",
        },
	},

    {
        name = "",
		narrative = {
            {"哔哩..铺设{/g 铁制电线杆}让右侧的所有{/color:4bd0ff 组装机}工作..哔哩..(期待)", "/pkg/vaststars.resources/ui/textures/guide/guide-6.texture"},
        },
        narrative_end = {
            task = {
                "电力铺设",
            },
            guide_progress = 10,
        },
        prerequisites = {
            "收集矿石",
        },
	},

    {
        name = "",
		narrative = {
            {"哔哩..{/color:4bd0ff 组装机}设置配方{/g 地质科技包1}进行生产..哔哩..(期待)", "/pkg/vaststars.resources/ui/textures/guide/guide-6.texture"},
        },
        narrative_end = {
            task = {
                "生产设置",
            },
            guide_progress = 10,
        },
        prerequisites = {
            "电力铺设",
        },
	},

    {
        name = "",
		narrative = {
            {"哔哩..设置{/color:4bd0ff 新仓库}收货{/g 碎石}、{/g 铁矿石}、{/g 铝矿石}、{/g 地质科技包}..哔哩..(期待)", "/pkg/vaststars.resources/ui/textures/guide/guide-6.texture"},
        },
        narrative_end = {
            task = {
                "新仓库设置",
            },
            guide_progress = 10,
        },
        prerequisites = {
            "生产设置",
        },
	},

    {
        name = "",
		narrative = {
            {"哔哩..往{/color:4bd0ff 新仓库}转放{/g 10个铝矿石}..哔哩..(期待)", "/pkg/vaststars.resources/ui/textures/guide/guide-6.texture"},
        },
        narrative_end = {
            task = {
                "仓库互转",
            },
            guide_progress = 10,
        },
        prerequisites = {
            "新仓库设置",
        },
	},

    {
        name = "",
		narrative = {
            {"哔哩..检查新{/color:4bd0ff 废墟}并拾取{/g 太阳能板}..哔哩..(期待)", "/pkg/vaststars.resources/ui/textures/guide/guide-6.texture"},
        },
        narrative_end = {
            task = {
                "太阳能板获取",
            },
            guide_progress = 10,
        },
        prerequisites = {
            "仓库互转",
        },
	},

    {
        name = "",
		narrative = {
            {"哔哩..放置{/g 4个轻型太阳能板}..哔哩..(期待)", "/pkg/vaststars.resources/ui/textures/guide/guide-6.texture"},
        },
        narrative_end = {
            task = {
                "太阳能发电",
            },
            guide_progress = 10,
        },
        prerequisites = {
            "太阳能板获取",
        },
	},

    {
        name = "",
		narrative = {
            {"哔哩..让我们开始研究制造{/color:4bd0ff 轻型太阳能板}的科技..哔哩..(期待)", "/pkg/vaststars.resources/ui/textures/guide/guide-6.texture"},
            {"哔哩..只要给{/color:4bd0ff 科研中心}提供{/g 地质科技包},科研就会开展..哔哩..(期待)", "/pkg/vaststars.resources/ui/textures/guide/guide-6.texture"},
        },
        narrative_end = {
            task = {
                "太阳能制造技术",
            },
            guide_progress = 10,
        },
        prerequisites = {
            "太阳能发电",
        },
	},
}

return guide2