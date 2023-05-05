local help = {
	{
        name = "移动/删除",
		content = {
            "1. 长按建筑达{/g 3秒}激活建筑移动/删除",
            "2. 点击删除后建筑会立刻销毁",
            "3. 点击移动后滑动手指将建筑摆放到空置区域，点击“放置”后完成",
        },
        guide_progress = 5,
	},

	{
        name = "电网铺设",
		content = {
            "1. 每个导电建筑都一定的供电范围，点击导电建筑会显示浅蓝色的供电范围",
            "2. 如果连续的供电范围内至少含有一个发电建筑，则该范围组成电网",
            "3. 处于电网内的耗电建筑在供电充足时正常工作；在供电不足时低效工作；在无供电时停止工作",
        },
        guide_progress = 15,
	},
    
    {
        name = "生产配方",
		content = {
            "1. 组装机、化工厂等可生产物资的建筑点选“管理”可设置配方",
            "2. 配方设置界面左侧是配方类别，右侧是配方需要原料和产出明细",
            "3. 点击“取消生产”可以将已设生产配方取消",
            "4. 点击“开始生产”则替换为当前选中生产配方",
        },
        guide_progress = 20,
	},

}

return help