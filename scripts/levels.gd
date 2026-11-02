extends RefCounted
## 全部关卡配置。广州 / 深圳交替，难度递增；通关前一关才解锁下一关。
##
## 可用字段（缺省值见 game.gd）：
##   style        qilou 骑楼 / modern 玻璃幕墙 / village 城中村握手楼
##   play_l       人行道左边界，越大人行道越窄（默认 250，右边界固定 1000）
##   weather      clear / rain（地面湿滑、骑手穿雨披）
##   night        夜间：画面压暗，只有车灯、路灯、招牌发光
##   crossings    路口出现的时间点（秒）；red_time 红灯时长范围
##   difficulty   电鸡速度与密度倍率
##   mix          电鸡类型权重：overtake 后方超车 / weave 蛇形 / cross 店门口横冲 / brake 急刹概率 / convoy 成排概率
##   obs          障碍权重：metro 地铁口 / shared 共享单车 / parked 停放电鸡 / bollard 石墩 / stall 摊位
##   obstacle_rate 障碍密度倍率

const GZ_METRO := "#c8102e"
const SZ_METRO := "#009a44"
const GZ_BLOCKS := ["#b8a58c", "#9fa8a3", "#c7b299", "#a39589", "#b3b8a0"]
const GZ_SIGNS := ["#c0392b", "#27ae60", "#2c3e50", "#d35400", "#8e44ad", "#16a085"]
const SZ_BLOCKS := ["#7f9bb3", "#8fa3b0", "#6d8299", "#9aa9b8", "#7d8fa1"]
const SZ_SIGNS := ["#ff2d95", "#00b8d4", "#7a5cff", "#ff6d00", "#00c853", "#ff1744"]
const VILLAGE_BLOCKS := ["#a49a8a", "#9a8f80", "#b0a593", "#8f8778", "#a69c8c"]
const VILLAGE_SIGNS := ["#d32f2f", "#f9a825", "#1565c0", "#2e7d32", "#c62828"]

## 开车模式：每关对应一条真实路段。车道数等来自公开资料（维基百科 / 交警通告 / 新闻），
## 查不到确切数据的按街景常见断面估计，在注释里标“估”。
##   lanes_own / lanes_opp 本向 / 对向车道数（对向 0 = 单行道）
##   median    yellow 双黄线 / barrier 中央护栏 / green 绿化带 / viaduct 高架桥墩 / none
##   side      none / aux2 两车道辅道（绿化带隔开）/ bike_lane 护栏隔开的非机动车道
##   bus_lanes 最右侧几条是公交专用道；limit 限速 km/h；target_m 目的地距离（米）
##   crossings 路口位置（米）；light [绿灯秒, 红灯秒]；traffic 车流密度
##   bikes     电鸡行为权重：same 占道慢行 / wrong 逆行 / split 钻缝 / dart 路边横穿 / stop 急刹 / redrun 横街闯红灯
##   obs       路障权重：parked 违停 / cones 施工围挡
const DRIVE := {
	"gz_tiyuxi": {
		# 体育西路：南北走向，宽 44 米，双向 6 车道，车流量极大（维基百科）
		"road": "体育西路", "desc": "双向6车道、车流极大，天河城门口出租车上下客，外卖电鸡贴边逆行。",
		"lanes_own": 3, "lanes_opp": 3, "median": "barrier", "side": "none", "bus_lanes": 0,
		"limit": 50, "target_m": 380, "crossings": [150, 330], "cross_names": ["天河南一路", "天河路"],
		"light": [8.0, 6.0], "traffic": 1.0, "bike_rate": 1.0,
		"bikes": {"same": 0.3, "wrong": 0.25, "split": 0.15, "dart": 0.15, "stop": 0.1, "redrun": 0.05},
		"obs": {"parked": 0.6, "cones": 0.4}, "obs_rate": 0.8,
	},
	"sz_huaqiang": {
		# 华强北路红荔路—深南段 2017 年起为步行街，机动车不能进入；
		# 振华路由西向东单向通行，2021 年试点机非共板，右侧护栏隔出电动车道（深圳交警通告 / 南方+）
		"road": "振华路（单行）", "desc": "华强北路是步行街开不进去，走振华路：由西向东单行，右边有电动车道，可电鸡偏要跑进机动车道。",
		"lanes_own": 3, "lanes_opp": 0, "median": "none", "side": "bike_lane", "bus_lanes": 0,
		"limit": 40, "target_m": 320, "crossings": [120, 260], "cross_names": ["燕南路", "华发北路"],
		"light": [7.0, 5.0], "traffic": 0.9, "bike_rate": 1.3,
		"bikes": {"same": 0.25, "wrong": 0.3, "split": 0.15, "dart": 0.2, "stop": 0.1},
		"obs": {"parked": 0.7, "cones": 0.3}, "obs_rate": 0.9,
	},
	"gz_beijinglu": {
		# 北京路中段是步行街，开车只能走与之相交的中山路（维基百科）；中山五路北京路口—解放路，
		# 公交线路三十多条，高峰时段公交专用道（广州本地宝）；车道数估：双向 4 车道
		"road": "中山五路", "desc": "北京路步行街开不进去，走中山五路：双向4车道（估），晚高峰最右是公交专用道，公交车一辆接一辆进站。",
		"lanes_own": 2, "lanes_opp": 2, "median": "yellow", "side": "none", "bus_lanes": 1,
		"limit": 40, "target_m": 240, "crossings": [110, 240], "cross_names": ["北京路口", "吉祥路口"],
		"light": [7.0, 6.0], "traffic": 1.1, "bike_rate": 1.0, "bus_share": 0.5,
		"bikes": {"same": 0.3, "wrong": 0.2, "split": 0.1, "dart": 0.25, "stop": 0.1, "redrun": 0.05},
		"obs": {"parked": 0.5, "cones": 0.5}, "obs_rate": 0.9,
	},
	"sz_kejiyuan": {
		# 科苑路早晚高峰极度拥堵，南行由 3 车道扩为 4 车道（深圳交警 / 知乎）；北行 3 车道（估）
		# 深圳交警通过 AI 优化信号配时、打造绿波路段（深圳交警），这里三个路口按绿波协调
		"road": "科苑路", "desc": "午高峰科苑路排长龙，外卖电鸡在车缝里钻；路口做了绿波，保持约40km/h能一路绿灯。",
		"lanes_own": 4, "lanes_opp": 3, "median": "green", "side": "none", "bus_lanes": 0,
		"limit": 50, "target_m": 400, "crossings": [100, 220, 330], "cross_names": ["高新中一道", "高新南一道", "高新南四道"],
		"green_wave": true, "light": [10.0, 5.0], "traffic": 1.7, "bike_rate": 1.3,
		"bikes": {"same": 0.15, "wrong": 0.1, "split": 0.4, "dart": 0.1, "stop": 0.2, "redrun": 0.05},
		"obs": {"parked": 0.5, "cones": 0.5}, "obs_rate": 0.7,
	},
	"gz_kecun": {
		# 新港路：海珠区主干道，双向 2—6 车道，限速 60；新港中路设公交专用道（维基百科 / 新浪）
		"road": "新港中路", "desc": "海珠主干道限速60，最右是公交专用道，客村一带公交车密集进站。",
		"lanes_own": 3, "lanes_opp": 3, "median": "green", "side": "none", "bus_lanes": 1,
		"limit": 60, "target_m": 450, "crossings": [170, 380], "cross_names": ["新市头路", "艺苑路"],
		"light": [9.0, 6.0], "traffic": 1.1, "bike_rate": 1.1, "bus_share": 0.5,
		"bikes": {"same": 0.3, "wrong": 0.2, "split": 0.15, "dart": 0.2, "stop": 0.1, "redrun": 0.05},
		"obs": {"parked": 0.6, "cones": 0.4}, "obs_rate": 0.9,
	},
	"sz_dongmen": {
		# 东门中路：原双向 7 车道，南北双向靠右侧各 2 条为公交专用道，社会车辆按单双号进入（深圳本地宝 / 维基百科）
		"road": "东门中路", "desc": "双向7车道，可两边各2条是公交专用道，社会车只能挤在中间；商铺门口电鸡说冲就冲。",
		"lanes_own": 4, "lanes_opp": 3, "median": "yellow", "side": "none", "bus_lanes": 2,
		"limit": 40, "target_m": 300, "crossings": [110, 240], "cross_names": ["解放路", "晒布路"],
		"light": [7.0, 6.0], "traffic": 1.1, "bike_rate": 1.3, "bus_share": 0.6,
		"bikes": {"same": 0.2, "wrong": 0.15, "split": 0.15, "dart": 0.35, "stop": 0.1, "redrun": 0.05},
		"obs": {"parked": 0.4, "cones": 0.6}, "obs_rate": 0.9,
	},
	"gz_huacheng": {
		# 花城大道：宽 71 米，双向 10 车道，花城广场段有 CBD 隧道（维基百科）
		"road": "花城大道", "desc": "双向10车道又宽又快，暴雨天视线差、路面滑，刹车距离明显变长。",
		"lanes_own": 5, "lanes_opp": 5, "median": "green", "side": "none", "bus_lanes": 0,
		"limit": 60, "target_m": 520, "crossings": [190, 400], "cross_names": ["冼村路", "猎德大道"],
		"light": [10.0, 6.0], "traffic": 1.0, "bike_rate": 1.1,
		"bikes": {"same": 0.3, "wrong": 0.15, "split": 0.25, "dart": 0.15, "stop": 0.1, "redrun": 0.05},
		"obs": {"parked": 0.4, "cones": 0.6}, "obs_rate": 0.7,
	},
	"sz_chegongmiao": {
		# 深南大道：主路双向 6—8 车道，辅道双向 4 车道，限速 60（深圳交通维基）
		"road": "深南大道", "desc": "深南大道主路双向8车道、两边辅道，深夜车速快，电鸡从辅道横穿绿化带开口冲进主路。",
		"lanes_own": 4, "lanes_opp": 4, "median": "green", "side": "aux2", "bus_lanes": 0,
		"limit": 60, "target_m": 480, "crossings": [190, 400], "cross_names": ["泰然九路", "香梅路"],
		"green_wave": true, "light": [10.0, 6.0], "traffic": 0.9, "bike_rate": 1.1,
		"bikes": {"same": 0.25, "wrong": 0.15, "split": 0.15, "dart": 0.35, "stop": 0.05, "redrun": 0.05},
		"obs": {"parked": 0.3, "cones": 0.7}, "obs_rate": 0.6,
	},
	"gz_shipai": {
		# 石牌东路：由北往南单行恢复为双向通行；石牌村内近 300 条村路（新浪 / 新华网）；车道数估：双向 4 车道
		"road": "石牌东路", "desc": "贴着石牌村，村巷口随时冲出电鸡，路边违停一辆接一辆。",
		"lanes_own": 2, "lanes_opp": 2, "median": "yellow", "side": "none", "bus_lanes": 0,
		"limit": 40, "target_m": 230, "crossings": [130, 240], "cross_names": ["新陶北街", "新陶南街"],
		"light": [6.0, 6.0], "traffic": 0.9, "bike_rate": 1.5,
		"bikes": {"same": 0.2, "wrong": 0.25, "split": 0.05, "dart": 0.4, "stop": 0.1},
		"obs": {"parked": 0.8, "cones": 0.2}, "obs_rate": 1.3,
	},
	"sz_baishizhou": {
		# 深南大道白石洲段：主路两侧设辅路，沙河街口附近辅路上有多个公交站台（维基百科）
		"road": "深南大道辅道", "desc": "深南辅道白石洲段，左边绿化带外是主路；公交站一个接一个，城中村电鸡从沙河街口一窝蜂冲出。",
		"lanes_own": 2, "lanes_opp": 0, "median": "main_road", "side": "none", "bus_lanes": 1,
		"limit": 40, "target_m": 250, "crossings": [120, 230], "cross_names": ["沙河街", "石洲中路"],
		"light": [8.0, 6.0], "traffic": 0.9, "bike_rate": 1.5, "bus_share": 0.6,
		"bikes": {"same": 0.2, "wrong": 0.2, "split": 0.05, "dart": 0.4, "stop": 0.1, "redrun": 0.05},
		"obs": {"parked": 0.6, "cones": 0.4}, "obs_rate": 1.0,
	},
	"gz_xinshixu": {
		# 新市墟站周边为机场路及机场高速高架桥（维基百科）；地面道路车道数估：双向 6 车道
		"road": "机场路", "desc": "头顶是机场高速高架，桥墩挡住视线，暴雨夜路面反光，看不清贴边逆行的电鸡。",
		"lanes_own": 3, "lanes_opp": 3, "median": "viaduct", "side": "none", "bus_lanes": 0,
		"limit": 50, "target_m": 360, "crossings": [140, 300], "cross_names": ["齐富路", "汇侨南路"],
		"light": [8.0, 6.0], "traffic": 1.0, "bike_rate": 1.2,
		"bikes": {"same": 0.3, "wrong": 0.3, "split": 0.1, "dart": 0.15, "stop": 0.1, "redrun": 0.05},
		"obs": {"parked": 0.5, "cones": 0.5}, "obs_rate": 0.8,
	},
	"sz_minzhi": {
		# 民治大道：龙华区城市主干路，宽 24 米，限速 40，双向 6 车道（维基百科）
		"road": "民治大道", "desc": "双向6车道挤在24米宽的路上，限速40，晚高峰三个红灯，急刹、拉货、钻缝电鸡全都来了。",
		"lanes_own": 3, "lanes_opp": 3, "median": "barrier", "side": "none", "bus_lanes": 0,
		"limit": 40, "target_m": 270, "crossings": [80, 170, 250], "cross_names": ["人民路", "梅龙路", "工业路"],
		"light": [7.0, 6.0], "traffic": 1.4, "bike_rate": 1.6,
		"bikes": {"same": 0.2, "wrong": 0.2, "split": 0.25, "dart": 0.15, "stop": 0.15, "redrun": 0.05},
		"obs": {"parked": 0.5, "cones": 0.5}, "obs_rate": 1.0,
	},
}

const LIST := [
	{
		"id": "gz_tiyuxi", "city": "广州", "name": "天河·体育西路", "en": "Guangzhou · Tiyu West Road",
		"desc": "新手关：体育西路地铁站外，迎面逆行的电鸡最多。",
		"style": "qilou", "sidewalk": "#cdb9a0", "block_colors": GZ_BLOCKS, "sign_colors": GZ_SIGNS,
		"shops": ["肠粉", "云吞面", "凉茶铺", "糖水", "烧腊饭", "早茶", "猪脚饭", "士多"],
		"metro_color": GZ_METRO, "metro_name": "体育西路站",
		"cross_names": ["天河南一路", "天河路"], "crossings": [15.0, 38.0], "red_time": [4.0, 7.0],
		"difficulty": 1.0, "box_chance": 0.45, "cargo_chance": 0.05, "obstacle_rate": 1.0,
	},
	{
		"id": "sz_huaqiang", "city": "深圳", "name": "福田·华强北", "en": "Shenzhen · Huaqiang North",
		"desc": "电子市场门口，拉货的电鸡纸箱堆得比人还高。",
		"style": "modern", "sidewalk": "#b9b4ad", "block_colors": SZ_BLOCKS, "sign_colors": SZ_SIGNS,
		"shops": ["手机配件", "电子市场", "数码维修", "充电宝", "奶茶", "潮汕牛肉", "便利店", "无人机"],
		"metro_color": SZ_METRO, "metro_name": "华强北站",
		"cross_names": ["振华路", "红荔路"], "crossings": [13.0, 35.0], "red_time": [5.0, 8.0],
		"difficulty": 1.1, "box_chance": 0.55, "cargo_chance": 0.3, "obstacle_rate": 1.2,
	},
	{
		"id": "gz_beijinglu", "city": "广州", "name": "越秀·北京路", "en": "Guangzhou · Beijing Road",
		"desc": "骑楼老街人行道窄，糖水档、石墩挡路，要在缝里穿。",
		"style": "qilou", "play_l": 330.0, "sidewalk": "#d2bfa3", "block_colors": GZ_BLOCKS, "sign_colors": GZ_SIGNS,
		"shops": ["双皮奶", "牛杂", "姜撞奶", "老字号", "凉茶", "鸡仔饼", "云吞面", "手信"],
		"stall_names": ["糖水", "牛杂", "鸡蛋仔", "烤肠"],
		"metro_color": GZ_METRO, "metro_name": "公园前站",
		"cross_names": ["文明路", "中山五路"], "crossings": [20.0, 42.0], "red_time": [4.0, 6.0],
		"difficulty": 1.1, "box_chance": 0.4, "cargo_chance": 0.05, "obstacle_rate": 1.2,
		"obs": {"stall": 0.3, "bollard": 0.35, "shared": 0.15, "parked": 0.15, "metro": 0.05},
	},
	{
		"id": "sz_kejiyuan", "city": "深圳", "name": "南山·科技园", "en": "Shenzhen · Science Park",
		"desc": "午饭外卖高峰！身后嘀嘀声不断，红灯时电鸡全挤在你身边。",
		"style": "modern", "sidewalk": "#c4c0b8", "block_colors": SZ_BLOCKS, "sign_colors": SZ_SIGNS,
		"shops": ["咖啡", "轻食沙拉", "麻辣烫", "快餐", "便利店", "奶茶", "煲仔饭", "黄焖鸡"],
		"metro_color": SZ_METRO, "metro_name": "高新园站",
		"cross_names": ["科苑路", "高新南一道", "高新南四道"], "crossings": [12.0, 28.0, 45.0], "red_time": [5.0, 7.0],
		"difficulty": 1.2, "box_chance": 0.9, "cargo_chance": 0.03, "obstacle_rate": 1.0,
		"mix": {"overtake": 0.38, "weave": 0.1, "cross": 0.08, "brake": 0.2},
	},
	{
		"id": "gz_kecun", "city": "广州", "name": "海珠·客村", "en": "Guangzhou · Kecun",
		"desc": "换乘站口一个接一个，门口的共享单车堆成山。",
		"style": "qilou", "play_l": 280.0, "sidewalk": "#c9b79e", "block_colors": GZ_BLOCKS, "sign_colors": GZ_SIGNS,
		"shops": ["猪脚饭", "肠粉", "奶茶", "沙县小吃", "水果店", "药房", "粉面", "快递点"],
		"metro_color": GZ_METRO, "metro_name": "客村站", "metro_gap": 800.0,
		"cross_names": ["新港中路", "艺苑路"], "crossings": [16.0, 40.0], "red_time": [4.0, 7.0],
		"difficulty": 1.2, "box_chance": 0.5, "cargo_chance": 0.08, "obstacle_rate": 1.35,
		"obs": {"metro": 0.35, "shared": 0.45, "parked": 0.15, "bollard": 0.05},
	},
	{
		"id": "sz_dongmen", "city": "深圳", "name": "罗湖·东门", "en": "Shenzhen · Dongmen",
		"desc": "老商圈店铺密，电鸡随时从店门口冲出来。",
		"style": "modern", "play_l": 300.0, "sidewalk": "#bdb5a8", "block_colors": SZ_BLOCKS, "sign_colors": SZ_SIGNS,
		"shops": ["服装城", "鞋城", "凉茶", "牛杂", "烧鹅", "茶餐厅", "眼镜", "金铺"],
		"stall_names": ["炸串", "牛杂", "糖葫芦", "炒冰"],
		"metro_color": SZ_METRO, "metro_name": "老街站",
		"cross_names": ["解放路", "新园路"], "crossings": [18.0, 40.0], "red_time": [4.0, 7.0],
		"difficulty": 1.25, "box_chance": 0.45, "cargo_chance": 0.15, "obstacle_rate": 1.1,
		"mix": {"overtake": 0.2, "weave": 0.15, "cross": 0.25, "cross_after": 6.0, "brake": 0.15},
		"obs": {"stall": 0.25, "shared": 0.25, "parked": 0.3, "bollard": 0.15, "metro": 0.05},
	},
	{
		"id": "gz_huacheng", "city": "广州", "name": "珠江新城·花城大道", "en": "Guangzhou · Huacheng Avenue",
		"desc": "暴雨天！地面湿滑刹不住脚，穿雨披的电鸡看不清路。",
		"style": "modern", "weather": "rain", "sidewalk": "#9e9a94",
		"block_colors": ["#6f8596", "#7c8c99", "#5f7384", "#8a99a6"], "sign_colors": GZ_SIGNS,
		"shops": ["写字楼", "咖啡", "银行", "便利店", "轻食", "书店", "花店", "西饼"],
		"metro_color": GZ_METRO, "metro_name": "珠江新城站",
		"cross_names": ["冼村路", "猎德大道"], "crossings": [15.0, 38.0], "red_time": [4.0, 7.0],
		"difficulty": 1.25, "box_chance": 0.6, "cargo_chance": 0.05, "obstacle_rate": 1.0,
		"mix": {"overtake": 0.22, "weave": 0.2, "cross": 0.1, "brake": 0.2},
	},
	{
		"id": "sz_chegongmiao", "city": "深圳", "name": "福田·车公庙", "en": "Shenzhen · Chegongmiao",
		"desc": "深夜加班回家，路灯昏暗，只能靠车灯判断电鸡在哪。",
		"style": "modern", "night": true, "sidewalk": "#b3aea6", "block_colors": SZ_BLOCKS, "sign_colors": SZ_SIGNS,
		"shops": ["24h便利店", "烧烤", "螺蛳粉", "网吧", "牛肉火锅", "奶茶", "肠粉", "夜宵"],
		"metro_color": SZ_METRO, "metro_name": "车公庙站",
		"cross_names": ["泰然九路", "天安路"], "crossings": [20.0, 42.0], "red_time": [5.0, 7.0],
		"difficulty": 1.3, "box_chance": 0.7, "cargo_chance": 0.1, "obstacle_rate": 1.1,
	},
	{
		"id": "gz_shipai", "city": "广州", "name": "天河·石牌村", "en": "Guangzhou · Shipai Village",
		"desc": "城中村握手楼，巷子窄、停满电鸡，蛇形走位的特别多。",
		"style": "village", "play_l": 420.0, "sidewalk": "#a89f94",
		"block_colors": VILLAGE_BLOCKS, "sign_colors": VILLAGE_SIGNS,
		"shops": ["快递驿站", "沙县小吃", "猪脚饭", "理发", "手机维修", "粉面", "士多", "炒粉"],
		"stall_names": ["炒粉", "烤串", "水果", "肠粉"],
		"cross_names": ["石牌东路"], "crossings": [30.0], "red_time": [4.0, 6.0],
		"difficulty": 1.3, "box_chance": 0.5, "cargo_chance": 0.15, "obstacle_rate": 1.3,
		"mix": {"overtake": 0.2, "weave": 0.3, "weave_after": 4.0, "cross": 0.15, "cross_after": 10.0, "brake": 0.15},
		"obs": {"parked": 0.45, "stall": 0.2, "shared": 0.2, "bollard": 0.15},
	},
	{
		"id": "sz_baishizhou", "city": "深圳", "name": "南山·白石洲", "en": "Shenzhen · Baishizhou",
		"desc": "城中村夜市开档，摊位占道，电鸡在灯影里乱窜。",
		"style": "village", "night": true, "play_l": 400.0, "sidewalk": "#a39a8e",
		"block_colors": VILLAGE_BLOCKS, "sign_colors": VILLAGE_SIGNS,
		"shops": ["砂锅粥", "烧烤", "糖水", "湘菜馆", "便利店", "炒粉", "麻辣烫", "水果"],
		"stall_names": ["烤生蚝", "炒粉", "臭豆腐", "烧烤"],
		"cross_names": ["沙河街"], "crossings": [28.0], "red_time": [4.0, 6.0],
		"difficulty": 1.35, "box_chance": 0.5, "cargo_chance": 0.1, "obstacle_rate": 1.3,
		"mix": {"overtake": 0.22, "weave": 0.22, "cross": 0.2, "cross_after": 8.0, "brake": 0.2},
		"obs": {"stall": 0.45, "parked": 0.3, "shared": 0.15, "bollard": 0.1},
	},
	{
		"id": "gz_xinshixu", "city": "广州", "name": "白云·新市墟", "en": "Guangzhou · Xinshixu",
		"desc": "暴雨夜，又滑又黑，地铁口外排满了共享单车。",
		"style": "qilou", "weather": "rain", "night": true, "sidewalk": "#a0968a",
		"block_colors": GZ_BLOCKS, "sign_colors": GZ_SIGNS,
		"shops": ["烧腊", "粥粉面", "五金", "药店", "鞋店", "肠粉", "士多", "牛杂"],
		"metro_color": GZ_METRO, "metro_name": "新市墟站",
		"cross_names": ["机场路", "新市西街"], "crossings": [16.0, 40.0], "red_time": [4.0, 7.0],
		"difficulty": 1.4, "box_chance": 0.6, "cargo_chance": 0.1, "obstacle_rate": 1.2,
		"obs": {"metro": 0.25, "shared": 0.35, "parked": 0.25, "bollard": 0.15},
	},
	{
		"id": "sz_minzhi", "city": "深圳", "name": "龙华·民治", "en": "Shenzhen · Minzhi",
		"desc": "终极晚高峰：三个红灯，急刹、拉货、外卖、成排电鸡全都来了。",
		"style": "modern", "sidewalk": "#b6b0a6", "block_colors": SZ_BLOCKS, "sign_colors": SZ_SIGNS,
		"shops": ["手机店", "奶茶", "快递驿站", "烧腊", "沙县小吃", "超市", "饺子馆", "烤鱼"],
		"stall_names": ["炸串", "烤肠", "水果", "煎饼"],
		"metro_color": SZ_METRO, "metro_name": "民治站",
		"cross_names": ["民治大道", "人民路", "梅龙大道"], "crossings": [12.0, 30.0, 46.0], "red_time": [5.0, 8.0],
		"difficulty": 1.5, "box_chance": 0.7, "cargo_chance": 0.25, "obstacle_rate": 1.4,
		"mix": {"overtake": 0.3, "weave": 0.18, "cross": 0.15, "brake": 0.3, "convoy": 0.45, "convoy_after": 20.0},
		"obs": {"metro": 0.15, "shared": 0.25, "parked": 0.3, "bollard": 0.15, "stall": 0.15},
	},
]
