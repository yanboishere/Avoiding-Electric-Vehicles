extends "res://scripts/game.gd"
## 开车模式：在机动车道上开车，60 秒内开到目的地，躲开占道、逆行、钻缝、横穿的电鸡。
## 道路按每关的真实路段配置（levels.gd 的 DRIVE）：车道数、中央隔离、辅道 / 非机动车道、公交专用道、限速、路口。
##
## 坐标约定同 game.gd：屏幕 y = 世界 y + scroll，scroll 每帧增加的量 = 玩家本帧行驶的距离。
## 所有交通参与者都是轴对齐矩形，统一放在 ents 里：
##   竖直行驶 dir = -1（同向，往上）/ +1（对向，往下）；横向行驶 hx = ±1；静止 dir = hx = 0。
## 防重叠规则：每个参与者只沿自己的方向前进，前进量不超过与前方障碍的间距（迎面相向各让一半）；
## 横向行驶者检查竖直方向带 8px 余量，变道前检查目标位置是否空出。

const DRIVE: Dictionary = preload("res://scripts/levels.gd").DRIVE
const PX_PER_M := 20.0
const LANE_W := 100.0
const PLAYER_Y := 560.0
const DRIVE_TIME := 60.0
const PLAY_Y_SAFE := 440.0
const SIDEWALK_W := 160.0
const CAR_HW := 23.0
const CAR_HH := 44.0
const BUS_HW := 26.0
const BUS_HH := 66.0
const BK_HW := 13.0
const BK_HH := 34.0
const X_MARGIN := 8.0
const BAND_LANES := [70.0, 170.0]
const STATIC_TYPES := ["parked", "cones", "fallen", "fallen_ped"]
const PED_V := [24.0, 32.0]   # 行人 1.2–1.6 米/秒
const PED_CROSS_V := [40.0, 52.0]  # 过马路走得快一些
const CRASH_LINES := ["撞到电鸡了！", "电鸡倒地了…", "全责警告！", "下车看看人没事吧"]
const CAR_HIT_LINES := ["追尾了！", "刮到车了！", "保险要涨了…"]
const WRONG_LINES := ["逆行！", "让一让！", "嘀嘀！"]
const PLAYER_COLOR := Color("#ff7a00")

var cfg: Dictionary = {}
var ents: Array = []
var me: Dictionary = {}
var ixs: Array = []
var dwarn: Array = []  # 横穿预警
var limit_px := 0.0
var target_px := 0.0
var lanes_own := 3
var lanes_opp := 3
var bus_lanes := 0
var curb_x := 0.0     # 本向最右车道右缘
var median_r := 0.0   # 本向最左车道左缘
var median_l := 0.0   # 对向最左车道（靠中线一侧）右缘
var road_l := 0.0     # 道路最左缘
var side_r := 0.0     # 道路最右缘（含辅道 / 非机动车道），右边是人行道
var npc_timer := 0.0
var bike_timer := 1.2
var obs_next := -500.0
var bus_pen_t := 0.0
var bus_pen := 0
var lat_v := 0.0
var late := false
var autopilot := false
var stuck_removed := 0  # 体检用：因堵死被移走的电鸡 / 行人
var stuck_why := {}
var jam_why := {}
var jam_t := 0.0        # 体检用：前方没有红灯却停着的时间
var jay_timer := 6.0
var sw_r := Vector2.ZERO  # 右侧人行道 x 范围
var sw_l := Vector2.ZERO  # 左侧人行道 x 范围
var ap_tx := -1.0


func setup(p_level: Dictionary, p_mode: String, p_demo: bool, p_sfx: Callable) -> void:
	super.setup(p_level, "walk", p_demo, p_sfx)
	mode = "drive"
	cfg = DRIVE.get(level.id, {})
	lanes_own = cfg.get("lanes_own", 3)
	lanes_opp = cfg.get("lanes_opp", 3)
	bus_lanes = cfg.get("bus_lanes", 0)
	limit_px = float(cfg.get("limit", 50)) / 3.6 * PX_PER_M
	target_px = float(cfg.get("target_m", 400)) * PX_PER_M
	var side_w := 0.0
	match cfg.get("side", "none"):
		"aux2":
			side_w = 40.0 + 2.0 * LANE_W
		"bike_lane":
			side_w = 70.0
	var mw: float = {"yellow": 14.0, "barrier": 16.0, "green": 40.0, "viaduct": 56.0, "main_road": 40.0}.get(cfg.get("median", "none"), 0.0)
	var total: float = lanes_opp * LANE_W + mw + lanes_own * LANE_W + side_w
	var extra := 3.0 * LANE_W if cfg.get("median", "") == "main_road" and lanes_opp == 0 else 0.0  # 白石洲：左边是主路
	# 道路在画面里居中，两侧留人行道和店铺；右侧至少留 110px 人行道
	road_l = (W - total - extra) / 2.0 + extra
	road_l = minf(road_l, W - 110.0 - total)
	side_r = road_l + total
	curb_x = side_r - side_w
	median_r = curb_x - lanes_own * LANE_W
	median_l = median_r - mw
	var left_road := road_l - extra
	sw_r = Vector2(side_r + 10.0, minf(W, side_r + 110.0) - 10.0)
	sw_l = Vector2(maxf(0.0, left_road - 110.0) + 10.0, left_road - 10.0)
	var start_lane := maxi(0, (lanes_own - bus_lanes - 1) / 2)
	me = {"type": "player", "pos": Vector2(_lane_x(start_lane), PLAYER_Y), "hw": CAR_HW, "hh": CAR_HH,
		"dir": -1, "hx": 0, "v": 0.0}
	var lt: Array = cfg.get("light", [7.0, 6.0])
	var names: Array = cfg.get("cross_names", ["路口"])
	var cs: Array = cfg.get("crossings", [])
	var g: float = lt[0]
	var rd: float = lt[1]
	var cyc := g + 2.0 + rd
	var wave_v: float = float(cfg.get("limit", 50)) / 3.6 * 0.75
	for i in cs.size():
		var pos0 := randf() * cyc
		if cfg.get("green_wave", false):
			var t_arr := 3.0 + 2.5 + float(cs[i]) / wave_v  # 倒计时 + 起步 + 行驶
			pos0 = fposmod(g * 0.4 - t_arr, cyc)
		var st := "green"
		var t := g - pos0
		if pos0 >= g + 2.0:
			st = "red"
			t = cyc - pos0
		elif pos0 >= g:
			st = "yellow"
			t = g + 2.0 - pos0
		ixs.append({"wy": PLAYER_Y - CAR_HH - float(cs[i]) * PX_PER_M, "name": names[posmod(i, names.size())],
			"state": st, "t": t, "ran_red": false, "xt": 0.0, "clear_t": 0.0})


func _ready() -> void:
	font = ThemeDB.fallback_font
	for i in 7:
		_spawn_npc(randf_range(-150.0, H + 100.0))


func _lane_x(i: int) -> float:
	return median_r + LANE_W * (i + 0.5)


func _rect(e: Dictionary) -> Rect2:
	return Rect2(e.pos.x - e.hw, e.pos.y - e.hh, e.hw * 2.0, e.hh * 2.0)


func _remove_ent(o: Dictionary) -> void:
	for i in ents.size():
		if is_same(ents[i], o):
			ents.remove_at(i)
			return


func _is_bike(e: Dictionary) -> bool:
	return e.type == "bike"


func _is_vehicle(e: Dictionary) -> bool:
	return e.type in ["car", "taxi", "bus"]


# ------------------------------------------------------------------ 主循环

func _process(delta: float) -> void:
	if paused:
		queue_redraw()
		return
	shake = maxf(0.0, shake - delta * 3.0)
	flash = maxf(0.0, flash - delta * 2.0)
	go_timer = maxf(0.0, go_timer - delta)
	scroll_rate = 0.0
	match state:
		"countdown":
			var before := ceili(countdown)
			countdown -= delta
			if ceili(countdown) != before and countdown > 0.0:
				_sfx("tick")
			if countdown <= 0.0:
				state = "play"
				go_timer = 0.8
				_sfx("go")
			_update_world(delta)
		"play":
			elapsed += delta
			invuln = maxf(0.0, invuln - delta)
			_update_player(delta)
			_update_world(delta)
			if scroll >= target_px:
				_end(true)
			elif elapsed >= DRIVE_TIME:
				late = true
				_end(false)
		"over":
			me.v = 0.0
			_update_world(delta)
			end_timer -= delta
			if end_timer <= 0.0:
				state = "done"
				finished.emit(_result())
	_update_popups(delta)
	_update_flyers(delta)
	queue_redraw()


func _update_player(delta: float) -> void:
	var acc := 0.0
	var st := 0.0
	if autopilot:
		var a := _autopilot()
		acc = a[0]
		st = a[1]
	else:
		acc = Input.get_axis("move_down", "move_up")
		st = Input.get_axis("move_left", "move_right")
	var brake := 560.0 * (0.55 if rain else 1.0)  # 雨天刹车距离明显变长
	if acc > 0.1:
		me.v = minf(limit_px, me.v + 170.0 * acc * delta)
	elif acc < -0.1:
		me.v = maxf(0.0, me.v - brake * -acc * delta)
	else:
		me.v = maxf(0.0, me.v - 30.0 * delta)

	# 横向：变道
	var grip := 3.0 if rain else 7.0
	lat_v = lerpf(lat_v, st * 250.0 * clampf(0.4 + me.v / limit_px, 0.4, 1.0), clampf(delta * grip, 0.0, 1.0))
	var nx := clampf(me.pos.x + lat_v * delta, median_r + CAR_HW + 3.0, curb_x - CAR_HW - 3.0)
	if absf(nx - me.pos.x) > 0.001:
		var nr := _rect(me)
		nr.position.x += nx - me.pos.x
		var hit := _first_overlap(nr, me)
		if not hit.is_empty():
			_player_contact(hit)
			hit = _first_overlap(nr, me)
		if hit.is_empty():
			me.pos.x = nx
		else:
			lat_v = 0.0

	# 纵向：前进
	var move: float = me.v * delta
	var gi := _gap_ahead(me, 0.0)
	var gap: float = gi[0]
	if move > gap - 1.0:
		var who: Dictionary = gi[1]
		_player_contact(who)
		gi = _gap_ahead(me, 0.0)
		gap = gi[0]
		if move > gap - 1.0:
			move = maxf(0.0, gap - 1.0)
			me.v = minf(me.v, maxf(0.0, _along(gi[1], me)))
	scroll_rate = move / delta
	scroll += move
	score += move / PX_PER_M

	# 闯红灯：车头越过停止线时还是红灯
	var front := PLAYER_Y - CAR_HH
	for ix in ixs:
		var bottom: float = ix.wy + scroll
		if bottom - move < front - 0.01 and bottom >= front - 0.01 and ix.state in ["red", "clear"] and not ix.ran_red:
			_run_red(ix)
		if me.v < 5.0 and ix.state != "green" and bottom < front and bottom > front - 260.0:
			wait_total += delta
	var red_ahead := false
	for ix in ixs:
		var b: float = ix.wy + scroll
		if ix.state != "green" and b < front + 2.0 and b > front - 700.0:
			red_ahead = true
	if me.v < 5.0 and not red_ahead and state == "play":
		jam_t += delta
		var w: Dictionary = _gap_ahead(me, 0.0)[1]
		var key := "%s(%s%s)" % [w.get("type", "none"), w.get("kind", ""), " stop" if w.get("stop_t", 0.0) > 0.0 else ""]
		jam_why[key] = jam_why.get(key, 0.0) + delta

	# 占用公交专用道
	if bus_lanes > 0 and me.pos.x > curb_x - bus_lanes * LANE_W and me.v > 10.0:
		bus_pen_t += delta
		if bus_pen_t >= 1.0:
			bus_pen_t -= 1.0
			if _bypass_needed():
				_popup(me.pos + Vector2(0, -60), "借道绕行，不扣分", Color("#7CFC00"), 20)
			elif not invincible:
				score -= 15.0
				bus_pen += 15
				_popup(me.pos + Vector2(0, -60), "占用公交专用道 -15", Color("#ffd23f"), 22)
	else:
		bus_pen_t = 0.0


## 社会车道前方有施工 / 违停 / 倒地的车，必须借公交道绕行
func _bypass_needed() -> bool:
	var gen_r := curb_x - bus_lanes * LANE_W
	for e in ents:
		if e.type in STATIC_TYPES and e.pos.x < gen_r and e.pos.y > PLAYER_Y - 450.0 and e.pos.y < PLAYER_Y + 160.0:
			return true
	return false


func _run_red(ix: Dictionary) -> void:
	ix.ran_red = true
	jaywalks += 1
	_sfx("whistle")
	if invincible:
		_popup(me.pos + Vector2(0, -70), "无敌！红灯算什么", Color("#ffd23f"), 28)
		return
	var loss := int(score * 0.25)
	score -= loss
	_popup(me.pos + Vector2(0, -70), tr("闯红灯！-%d 分") % loss, Color("#ff5252"), 30)
	_popup(Vector2(W / 2.0, 170), "被横街的车撞到直接 GAME OVER！", Color("#ff9800"), 28)


## 玩家碰到了 o：电鸡 → 撞倒 / 创飞；车辆、路障 → 扣命
func _player_contact(o: Dictionary) -> void:
	if o.is_empty() or state != "play":
		return
	if _is_bike(o):
		if invincible:
			_remove_ent(o)
			_launch_flyer(o, o.pos, (o.pos - me.pos).normalized())
			return
		if invuln > 0.0:
			return
		_player_hit(o.pos, CRASH_LINES.pick_random())
		me.v *= 0.3
		_knock_down(o)
		return
	if o.type == "ped":
		if invincible or invuln > 0.0:
			return  # 无敌模式只创飞电鸡，行人是实心的，会把你挡住
		_player_hit(o.pos, "撞到行人了！全责！")
		me.v *= 0.1
		_knock_down(o)
		return
	if o.type == "xcar" and ixs[o.ix].ran_red and not invincible and not god:
		run_over = true
		hits += 1
		lives = 0
		shake = 1.5
		flash = 1.0
		_popup(me.pos + Vector2(0, -60), "闯红灯被车撞了！", Color("#ff5252"), 36)
		_sfx("hit")
		_end(false)
		return
	if invincible or invuln > 0.0 or o.type == "fallen":
		return
	_player_hit(o.pos, CAR_HIT_LINES.pick_random())
	me.v *= 0.2


## 被撞的电鸡倒在路边，变成路障
func _knock_down(o: Dictionary) -> void:
	var ped: bool = o.type == "ped"
	o.type = "fallen_ped" if ped else "fallen"
	o.fallen_t = 3.0 if ped else 4.0
	o.dir = 0
	o.hx = 0
	o.v = 0.0
	o.hw = 11.0 if ped else BK_HH
	o.hh = 7.0 if ped else BK_HW
	o.rot = PI / 2.0
	var side := 1.0 if o.pos.x >= me.pos.x else -1.0
	var cands := [
		Vector2(me.pos.x + side * (CAR_HW + o.hw + 3.0), clampf(o.pos.y, me.pos.y - CAR_HH + o.hh, me.pos.y + CAR_HH - o.hh)),
		Vector2(me.pos.x - side * (CAR_HW + o.hw + 3.0), me.pos.y),
		Vector2(me.pos.x, me.pos.y + CAR_HH + o.hh + 3.0),
		Vector2(me.pos.x, me.pos.y - CAR_HH - o.hh - 3.0),
	]
	for c in cands:
		var r := Rect2(c.x - o.hw, c.y - o.hh, o.hw * 2.0, o.hh * 2.0)
		if _free(r.grow(1.0), o):
			o.pos = c
			return
	# 旁边都没空位：骑手扶起车走了
	_remove_ent(o)
	_popup(me.pos + Vector2(0, -90), "电鸡扶起车溜了", Color.WHITE, 20)


# ------------------------------------------------------------------ 交通参与者

## 前方最近的障碍：返回 [间距, 障碍]。竖直行驶者 x 方向严格判定；横向行驶者 y 方向带余量
func _gap_ahead(e: Dictionary, margin: float) -> Array:
	var r := _rect(e)
	var best := INF
	var who: Dictionary = {}
	var vertical: bool = e.hx == 0
	var ignore_me: bool = e.get("ignore_player", false) and (invuln <= 0.0 or invincible)
	if invincible:
		ignore_me = e.get("ignore_player", false)
	for k in ents.size() + 1:
		var o: Dictionary = me if k == ents.size() else ents[k]
		if is_same(o, e) or (is_same(o, me) and ignore_me):
			continue
		var orr := _rect(o)
		var g: float
		if vertical:
			if orr.position.x >= r.end.x - 0.5 or orr.end.x <= r.position.x + 0.5:
				continue
			if e.dir < 0:
				if orr.end.y > r.position.y + 0.5:
					continue
				g = r.position.y - orr.end.y
			else:
				if orr.position.y < r.end.y - 0.5:
					continue
				g = orr.position.y - r.end.y
		else:
			if orr.position.y >= r.end.y + margin or orr.end.y <= r.position.y - margin:
				continue
			if e.hx > 0:
				if orr.position.x < r.end.x - 0.5:
					continue
				g = orr.position.x - r.end.x
			else:
				if orr.end.x > r.position.x + 0.5:
					continue
				g = r.position.x - orr.end.x
		if g < best:
			best = g
			who = o
	return [best, who]


## o 沿 e 行驶方向的速度（同向为正，迎面为负）
func _along(o: Dictionary, e: Dictionary) -> float:
	if o.is_empty():
		return 0.0
	if e.hx == 0:
		if o.hx != 0 or o.dir == 0:
			return 0.0
		return o.v if o.dir == e.dir else -o.v
	if o.hx == 0:
		return 0.0
	return o.v if o.hx == e.hx else -o.v


## 逆行 / 横穿 / 闯红灯的电鸡平时不让玩家（会撞上来），玩家受击无敌时才避开
func _ignores_me(e: Dictionary) -> bool:
	return e.get("ignore_player", false) and invuln <= 0.0 and not invincible


func _first_overlap(r: Rect2, e: Dictionary) -> Dictionary:
	for o in ents:
		if not is_same(o, e) and _rect(o).intersects(r):
			return o
	return {}


func _free(r: Rect2, e: Dictionary, include_me := true) -> bool:
	if not _first_overlap(r, e).is_empty():
		return false
	if include_me and not is_same(e, me) and _rect(me).intersects(r):
		return false
	return true


func _update_world(delta: float) -> void:
	# 1. 画面滚动：所有参与者一起平移
	for e in ents:
		e.pos.y += scroll_rate * delta
	for w in dwarn:
		w.y += scroll_rate * delta
	# 2. 信号灯与生成
	_update_lights(delta)
	if state != "over":
		_spawn_tick(delta)
	_gen_obstacles()
	# 3. 每个参与者沿自己的方向前进
	for i in range(ents.size() - 1, -1, -1):
		if i >= ents.size():
			continue
		var e: Dictionary = ents[i]
		if e.type not in STATIC_TYPES:
			_ai(e, delta)
		elif e.type in ["fallen", "fallen_ped"]:
			e.fallen_t -= delta
			if e.fallen_t <= 0.0:
				_remove_ent(e)
				continue
		var r := _rect(e)
		if r.position.y > H + 320.0 or r.end.y < -360.0 or r.end.x < -160.0 or r.position.x > W + 160.0:
			_remove_ent(e)
	if state == "play":
		_near_miss()


func _ai(e: Dictionary, dt: float) -> void:
	if e.get("kind", "") == "refuge":
		return
	if e.type == "xcar":
		e.ignore_player = ixs[e.ix].ran_red and not invincible
	var gi := _gap_ahead(e, X_MARGIN)
	var gap: float = gi[0]
	var who: Dictionary = gi[1]
	var bv := 0.0
	var headon := false
	if not who.is_empty():
		var a := _along(who, e)
		bv = maxf(a, 0.0)
		headon = a < 0.0
	var lg := _line_gap(e)
	if lg < gap:
		gap = lg
		bv = 0.0
		headon = false
		who = {}

	# 公交进站 / 出租车上下客 / 电鸡急刹
	var want: float = e.vmax
	if e.get("stop_at", -9999.0) > -9999.0 and e.pos.y < e.stop_at and not e.get("stopped_once", false):
		if e.type != "bus" or e.get("lane", -1) == lanes_own - 1:
			e.stopped_once = true
			e.stop_t = 3.5 if e.type == "bus" else (2.5 if e.type == "taxi" else 3.0)
			e.said = {"bus": "进站", "taxi": "上下客"}.get(e.type, "急刹！送外卖")
			e.said_t = 1.6
			if e.type == "bike":
				_sfx("brake")
		else:
			e.stopped_once = true
	if e.type == "ped" and e.get("kind", "") == "walk" and _in_red_band(e):
		want = e.vmax * 2.5  # 灯要变了，小跑过去
	if e.get("stop_t", 0.0) > 0.0:
		want = 0.0
		if e.v < 1.0:
			e.stop_t -= dt
	var safe: float = 24.0 + e.v * 0.5
	if gap < safe + 60.0:
		want = minf(want, bv + maxf(0.0, gap - 16.0) * 1.6)
	if want < e.v:
		e.v = maxf(want, e.v - e.dec * dt)
	else:
		e.v = minf(want, e.v + e.acc * dt)
	var mv: float = e.v * dt
	var lim := maxf(0.0, gap - 4.0)
	if headon:
		lim *= 0.5
	if mv > lim:
		mv = lim
	if e.hx == 0:
		e.pos.y += e.dir * mv
	else:
		e.pos.x += e.hx * mv
	e.said_t = maxf(0.0, e.get("said_t", 0.0) - dt)
	e.rot = 0.0 if e.dir < 0 else (PI if e.dir > 0 else (PI / 2.0 if e.hx > 0 else -PI / 2.0))

	_lateral(e, dt, gap, who)
	if _is_bike(e) or e.type == "ped":
		_unjam(e, dt, gap, who)
		var blocked: bool = e.v < 2.0 and not who.is_empty() and e.get("stop_t", 0.0) <= 0.0 \
			and (who.type in STATIC_TYPES or _along(who, e) < 0.0 or (who.v < 2.0 and who.get("hx", 0) != e.hx) \
				or (e.hx == 0 and who.get("hx", 0) == 0 and who.get("dir", 0) == -e.dir))
		e.stuck_t = e.get("stuck_t", 0.0) + dt if blocked else 0.0
		if e.stuck_t > 5.0:  # 堵死了：推车 / 走上人行道离开
			stuck_removed += 1
			var key := "%s(%s)←%s(%s)" % [e.type, e.get("kind", ""), who.type, who.get("kind", "")]
			stuck_why[key] = stuck_why.get(key, 0) + 1
			_remove_ent(e)
			return
	if e.type == "ped":
		e.phase += dt * e.v / 4.0
		if e.has("refuge_x") and e.hx != 0 and (e.pos.x - e.refuge_x) * e.hx >= 0.0:
			e.kind = "refuge"  # 站在安全岛上等
			e.hx = 0
			e.dir = 0
			e.v = 0.0
			e.vmax = 0.0
			e.rot = PI if e.pos.y > 0 else 0.0
		elif e.hx != 0 and ((e.hx < 0 and e.pos.x < sw_l.y) or (e.hx > 0 and e.pos.x > sw_r.x)):
			_ped_arrive(e)

	# 横穿的电鸡到了最左车道，或被路障 / 车流挡住超过半秒：转弯顺着车流往前骑
	if e.get("kind", "") == "dart":
		e.dart_stuck = e.get("dart_stuck", 0.0) + dt if e.v < 2.0 else 0.0
		if e.pos.x - e.hw <= median_r + 2.0:
			_dart_turn(e, median_r + 14.0)
		elif e.dart_stuck > 0.5:
			_dart_turn(e, clampf(e.pos.x, median_r + BK_HW + 2.0, curb_x - BK_HW - 1.0))

	# 无视玩家的电鸡（逆行 / 横穿 / 闯红灯）撞上了玩家
	if state == "play" and _is_bike(e) and e.get("ignore_player", false) and _rect(e).intersects(_rect(me)):
		_player_contact(e)
	elif e.type == "xcar" and e.ignore_player and state == "play" and _rect(e).intersects(_rect(me)):
		_player_contact(e)


## 车辆遇到停着 / 很慢的障碍就变道；电鸡贴边绕开障碍
func _lateral(e: Dictionary, dt: float, gap: float, who: Dictionary) -> void:
	if e.hx != 0:
		return
	if _is_vehicle(e) and e.get("lane", -1) >= 0:
		e.lc_cool = e.get("lc_cool", 0.0) - dt
		var blocked: bool = not who.is_empty() and gap < 160.0 and (who.type in STATIC_TYPES or _along(who, e) < e.vmax * 0.45 or who.get("stop_t", 0.0) > 0.0)
		if absf(e.pos.x - e.tx) < 0.5 and e.lc_cool <= 0.0 and blocked and e.get("stop_t", 0.0) <= 0.0:
			var cands := [e.lane - 1, e.lane + 1]
			cands.shuffle()
			var stuck: bool = who.type in STATIC_TYPES
			for c in cands:
				if c >= 0 and c < lanes_own and (_lane_allowed(e, c) or stuck) and _lane_free(e, c):
					e.lane = c
					e.tx = _lane_x(c)
					e.lc_cool = 2.5
					break
	elif _is_bike(e) and e.get("kind", "") in ["same", "stop", "wrong", "split"]:
		var blocked: bool = not who.is_empty() and gap < 80.0 and (who.type in STATIC_TYPES or absf(_along(who, e)) < 30.0)
		if blocked:
			var wr := _rect(who)
			var lo := median_r + BK_HW + 2.0
			var hi := curb_x - BK_HW - 1.0
			var left_x := wr.position.x - BK_HW - 6.0
			var right_x := wr.end.x + BK_HW + 6.0
			e.tx = left_x if left_x >= lo else right_x
			if right_x <= hi and absf(right_x - e.pos.x) < absf(left_x - e.pos.x):
				e.tx = right_x
			e.tx = clampf(e.tx, lo, hi)
		elif gap > 240.0:
			e.tx = e.home_x
	if e.has("tx") and absf(e.pos.x - e.tx) > 0.5:
		var spd := 110.0 if _is_vehicle(e) else 90.0
		var step: float = signf(e.tx - e.pos.x) * minf(absf(e.tx - e.pos.x), spd * dt)
		var nr := _rect(e)
		nr.position.x += step
		if _free(nr.grow_individual(3.0, 12.0, 3.0, 12.0), e, not _ignores_me(e)):
			e.pos.x += step


func _dart_turn(e: Dictionary, x: float) -> void:
	var r := Rect2(x - BK_HW, e.pos.y - BK_HH, BK_HW * 2.0, BK_HH * 2.0)
	if not _free(r.grow(2.0), e):
		return
	e.kind = "same"
	e.hx = 0
	e.dir = -1
	e.hw = BK_HW
	e.hh = BK_HH
	e.pos = Vector2(x, e.pos.y)
	e.vmax = 140.0
	e.v = minf(e.v, 140.0)
	e.home_x = x
	e.tx = x
	e.ignore_player = false


## 电鸡被迎面堵住（双方都走不了）超过 0.8 秒：往旁边让开
func _unjam(e: Dictionary, dt: float, gap: float, who: Dictionary) -> void:
	var jammed: bool = e.v < 2.0 and gap < 10.0 and not who.is_empty() and _along(who, e) <= 0.0 and who.type not in STATIC_TYPES and e.get("stop_t", 0.0) <= 0.0
	e.jam_t = e.get("jam_t", 0.0) + dt if jammed else 0.0
	if e.jam_t < 0.8:
		return
	var step: float = e.hw * 2.0 + 6.0 if e.hx == 0 else e.hh * 2.0 + 6.0
	var ks := [1.0, -1.0, 2.0, -2.0]
	if e.type == "ped" and e.hx == 0 and e.dir > 0:
		ks = [-1.0, 1.0, -2.0, 2.0]  # 往下走的人，右手边是 -x
	for k in ks:
		var np: Vector2 = e.pos + (Vector2(k * step, 0) if e.hx == 0 else Vector2(0, k * step))
		if e.hx == 0 and e.type == "ped" and (np.x < e.get("xmin", -INF) or np.x > e.get("xmax", INF)):
			continue
		if e.hx == 0 and e.type != "ped" and (np.x < median_r + BK_HW + 2.0 or np.x > curb_x - BK_HW - 1.0):
			continue
		var r := Rect2(np.x - e.hw, np.y - e.hh, e.hw * 2.0, e.hh * 2.0)
		if _free(r.grow(2.0), e, not _ignores_me(e)):
			e.pos = np
			e.tx = np.x
			e.jam_t = 0.0
			return


func _lane_allowed(e: Dictionary, lane: int) -> bool:
	if e.type == "bus":
		return true
	return lane < lanes_own - bus_lanes or bus_lanes >= lanes_own


func _lane_free(e: Dictionary, lane: int) -> bool:
	var r := Rect2(_lane_x(lane) - e.hw - 4.0, e.pos.y - e.hh - 150.0, e.hw * 2.0 + 8.0, e.hh * 2.0 + 260.0)
	return _free(r, e)


## 停止线：机动车遇红灯 / 来得及停的黄灯停在线前；横街车在路口外等
func _line_gap(e: Dictionary) -> float:
	if e.type == "xcar":
		var ix: Dictionary = ixs[e.ix]
		if ix.state == "red" and ix.t > 1.5 and not _band_busy(ix):
			return INF
		var r := _rect(e)
		var el := minf(road_l, sw_l.x - 10.0) - 4.0  # 停在人行道外侧，不挡过横街的行人
		var er := maxf(side_r, sw_r.y + 10.0) + 4.0
		if e.hx > 0 and r.end.x <= el + 0.5:
			return el - r.end.x
		if e.hx < 0 and r.position.x >= er - 0.5:
			return r.position.x - er
		return INF
	if e.type == "ped" and e.get("kind", "") == "walk":
		return _ped_line_gap(e)
	if not _is_vehicle(e):
		return INF  # 电鸡从来不看红绿灯
	var best := INF
	for ix in ixs:
		if ix.state == "green":
			continue
		var bottom: float = ix.wy + scroll
		var top := bottom - IX_H
		if top > H + 300.0 or bottom < -500.0:
			continue
		var r := _rect(e)
		var g: float
		if e.dir < 0:
			if r.position.y < bottom - 1.0:
				continue
			g = r.position.y - bottom
		else:
			if r.end.y > top + 1.0:
				continue
			g = top - r.end.y
		if ix.state == "yellow" and g < e.v * e.v / (2.0 * e.dec) + 6.0:
			continue  # 黄灯刹不住就过去
		best = minf(best, g)
	return best


## 人行道上的行人：跟本向信号走，本向不是绿灯就停在横街路口外
func _ped_line_gap(e: Dictionary) -> float:
	var best := INF
	var r := _rect(e)
	for ix in ixs:
		if ix.state == "green":
			continue
		var bottom: float = ix.wy + scroll
		var top := bottom - IX_H
		if e.dir < 0 and r.position.y >= bottom - 1.0:
			best = minf(best, r.position.y - bottom)
		elif e.dir > 0 and r.end.y <= top + 1.0:
			best = minf(best, top - r.end.y)
	return best


func _in_red_band(e: Dictionary) -> bool:
	var r := _rect(e)
	for ix in ixs:
		if ix.state != "green" and _band_rect(ix).grow_individual(400.0, 0.0, 400.0, 0.0).intersects(r):
			return true
	return false


func _band_rect(ix: Dictionary) -> Rect2:
	return Rect2(road_l, ix.wy + scroll - IX_H, side_r - road_l, IX_H)


## 路口里还有车 / 电鸡（或合法进入的玩家）：横街车不能放行
func _band_busy(ix: Dictionary) -> bool:
	var br := _band_rect(ix).grow_individual(0.0, -42.0, 0.0, -42.0)  # 只看中央车道区域，斑马线上的行人和横街车同时通行
	for o in ents:
		if o.type != "xcar" and _rect(o).intersects(br):
			return true
	return not ix.ran_red and _rect(me).intersects(br)


func _update_lights(dt: float) -> void:
	var lt: Array = cfg.get("light", [7.0, 6.0])
	for i in ixs.size():
		var ix: Dictionary = ixs[i]
		var bottom: float = ix.wy + scroll
		var visible := bottom - IX_H < H + 60.0 and bottom > -320.0
		match ix.state:
			"green":
				ix.t -= dt
				if ix.t <= 0.0:
					ix.state = "yellow"
					ix.t = 2.0
			"yellow":
				ix.t -= dt
				if ix.t <= 0.0:
					ix.state = "red"
					ix.t = float(lt[1])
			"red":
				ix.t -= dt
				ix.xt -= dt
				if visible and ix.xt <= 0.0:
					ix.xt = randf_range(0.6, 1.3)
					_spawn_xcar(i)
				ix.pt = ix.get("pt", 0.0) - dt
				if visible and ix.pt <= 0.0 and ix.t > 1.5:
					ix.pt = randf_range(0.8, 1.8) / float(cfg.get("ped_rate", 1.0))
					_spawn_crosser(ix)
				if ix.t <= 0.0:
					ix.state = "clear"
			"clear":
				ix.clear_t = ix.get("clear_t", 0.0) + dt
				var busy := false
				for o in ents:
					if o.type == "xcar" and o.ix == i and _rect(o).end.x > road_l and _rect(o).position.x < side_r:
						busy = true
				if not busy or ix.clear_t > 2.5:  # 清场最多 2.5 秒，剩下的横街车按让行规则通过
					ix.state = "green"
					ix.t = float(lt[0])
					ix.clear_t = 0.0


func _spawn_xcar(i: int) -> void:
	var right := randf() < 0.5
	var lane_y: float = BAND_LANES[1] if right else BAND_LANES[0]
	var y: float = ixs[i].wy + scroll - IX_H + lane_y
	var is_bike := randf() < 0.25
	var e := {"type": "xcar", "ix": i, "pos": Vector2(-90.0 if right else W + 90.0, y),
		"hw": 44.0, "hh": 23.0, "dir": 0, "hx": 1 if right else -1, "v": 0.0,
		"vmax": randf_range(240.0, 380.0), "acc": 220.0, "dec": 900.0, "col": CAR_COLORS.pick_random(),
		"ignore_player": false, "rot": 0.0}
	e.v = e.vmax
	if is_bike:
		e.merge(_make_look(), true)
		e.type = "xcar"
		e.bike = true
		e.hw = BK_HH
		e.hh = BK_HW
		e.vmax = randf_range(180.0, 260.0)
	if _free(_rect(e).grow(30.0), e, false):
		ents.append(e)


func _spawn_tick(delta: float) -> void:
	npc_timer -= delta
	if npc_timer <= 0.0:
		npc_timer = randf_range(0.5, 1.2) / float(cfg.get("traffic", 1.0))
		_spawn_npc()
	ped_timer -= delta
	if ped_timer <= 0.0:
		ped_timer = randf_range(0.35, 0.8) / float(cfg.get("ped_rate", 1.0))
		_spawn_walker()
	if state != "play":
		return
	jay_timer -= delta
	if jay_timer <= 0.0:
		jay_timer = randf_range(7.0, 14.0) / float(cfg.get("jay_peds", 1.0))
		var wy := randf_range(150.0, PLAY_Y_SAFE)
		var ok := true
		for ix in ixs:
			var b: float = ix.wy + scroll
			if wy > b - IX_H - 120.0 and wy < b + 100.0:
				ok = false
		if ok:
			dwarn.append({"y": wy, "t": 1.2, "kind": "ped"})
	bike_timer -= delta
	if bike_timer <= 0.0:
		var p := elapsed / DRIVE_TIME
		bike_timer = lerpf(1.4, 0.6, p) * randf_range(0.7, 1.3) / float(cfg.get("bike_rate", 1.0))
		_spawn_bike_drive()
	for i in range(dwarn.size() - 1, -1, -1):
		var w: Dictionary = dwarn[i]
		w.t -= delta
		if w.t <= 0.0:
			if w.get("kind", "") == "ped":
				_spawn_jaywalker(w.y)
			else:
				_spawn_dart(w.y)
			dwarn.remove_at(i)


func _spawn_npc(y_hint := -99999.0) -> void:
	var opp := lanes_opp > 0 and randf() < 0.35
	var bus_share: float = cfg.get("bus_share", 0.12)
	var t := "car"
	var r := randf()
	if r < bus_share * 0.6:
		t = "bus"
	elif r < bus_share * 0.6 + 0.15:
		t = "taxi"
	var lane := -1
	var x: float
	if opp:
		x = median_l - LANE_W * (randi() % lanes_opp + 0.5)
	else:
		if t == "bus":
			lane = lanes_own - 1 - (randi() % maxi(bus_lanes, 1))
		else:
			var allowed := lanes_own - bus_lanes if lanes_own > bus_lanes else lanes_own
			lane = randi() % allowed
		x = _lane_x(lane)
	var vmax: float = limit_px * (randf_range(0.45, 0.7) if t == "bus" else randf_range(0.55, 0.95))
	var y := y_hint
	if y_hint < -9999.0:
		if opp:
			y = -170.0
		else:
			y = H + 170.0 if vmax > me.v + 20.0 else -170.0
	var bus := t == "bus"
	var e := {"type": t, "pos": Vector2(x, y), "hw": BUS_HW if bus else CAR_HW, "hh": BUS_HH if bus else CAR_HH,
		"dir": 1 if opp else -1, "hx": 0, "v": vmax, "vmax": vmax, "acc": 90.0 if bus else 150.0, "dec": 900.0,
		"lane": lane, "opp": opp, "tx": x, "lc_cool": 0.0, "col": CAR_COLORS.pick_random(), "rot": 0.0,
		"said": "", "said_t": 0.0}
	if not opp and (t == "bus" or t == "taxi") and randf() < 0.7:
		e.stop_at = randf_range(120.0, 420.0)
	if _free(_rect(e).grow(30.0), e):
		ents.append(e)


func _bike_ent(kind: String, pos: Vector2, dir: int, hx: int, vmax: float) -> Dictionary:
	var e := _make_look()
	e.merge({"type": "bike", "kind": kind, "pos": pos, "hw": BK_HW if hx == 0 else BK_HH,
		"hh": BK_HH if hx == 0 else BK_HW, "dir": dir, "hx": hx, "v": vmax, "vmax": vmax,
		"acc": 120.0, "dec": 700.0, "tx": pos.x, "home_x": pos.x, "said": "", "said_t": 0.0,
		"ignore_player": false, "near": false, "awarded": false}, true)
	return e


func _spawn_bike_drive() -> void:
	var kind := _pick_weighted(cfg.get("bikes", {"same": 0.3, "wrong": 0.2, "split": 0.15, "dart": 0.2, "stop": 0.1, "redrun": 0.05}))
	if kind == "split" and lanes_own < 2:
		kind = "same"
	var e: Dictionary = {}
	match kind:
		"redrun":
			for ix in ixs:
				var top: float = ix.wy + scroll - IX_H
				if ix.state in ["green", "yellow"] and top > 60.0 and top < PLAYER_Y - IX_H - 80.0:
					var right := randf() < 0.5
					e = _bike_ent("redrun", Vector2(road_l - 50.0 if right else side_r + 50.0, top + BAND_LANES[1 if right else 0] + randf_range(-25.0, 25.0)), 0, 1 if right else -1, randf_range(180.0, 240.0))
					e.ignore_player = true
					e.said = "闯红灯！"
					e.said_t = 1.4
					break
			if e.is_empty():
				kind = "dart"
		"dart":
			pass
		"split":
			var k := randi_range(1, lanes_own - 1)
			e = _bike_ent("split", Vector2(median_r + k * LANE_W, H + 80.0), -1, 0, maxf(me.v + 90.0, 230.0))
			e.said = "嘀嘀！借过"
			e.said_t = 1.2
			_sfx("beep")
		"wrong":
			e = _bike_ent("wrong", Vector2(curb_x - 14.0, -80.0), 1, 0, randf_range(90.0, 140.0))
			e.ignore_player = true
			e.said = WRONG_LINES.pick_random()
			e.said_t = 1.4
		_:  # same / stop：占用最右车道
			var vmax := randf_range(100.0, 160.0)
			e = _bike_ent(kind, Vector2(curb_x - 40.0, -80.0 if vmax < me.v else H + 80.0), -1, 0, vmax)
			if kind == "stop":
				e.stop_at = randf_range(160.0, 420.0)
	if kind == "dart":
		var wy := randf_range(150.0, PLAYER_Y - 120.0)
		for ix in ixs:
			var b: float = ix.wy + scroll
			if wy > b - IX_H - 120.0 and wy < b + 100.0:
				return
		dwarn.append({"y": wy, "t": 0.9})
		_sfx("beep")
		return
	if not e.is_empty() and _free(_rect(e).grow(20.0), e):
		ents.append(e)
	# 非机动车道上本来就有的电鸡（只做背景，和主路隔着护栏）
	if cfg.get("side", "none") == "bike_lane" and randf() < 0.6:
		var lb := _bike_ent("lane", Vector2(curb_x + 42.0 + randf_range(-6.0, 6.0), H + 80.0), -1, 0, randf_range(120.0, 200.0) + me.v)
		if _free(_rect(lb).grow(10.0), lb, false):
			ents.append(lb)


func _ped_ent(kind: String, pos: Vector2, dir: int, hx: int, v: float) -> Dictionary:
	return {"type": "ped", "kind": kind, "pos": pos, "hw": 7.0, "hh": 7.0, "dir": dir, "hx": hx, "v": v, "vmax": v,
		"acc": 60.0, "dec": 300.0, "r": 11.0, "phase": randf() * TAU, "shirt": PED_SHIRTS.pick_random(),
		"hair": PED_HAIR.pick_random(), "phone": randf() < 0.15, "umbrella": rain and randf() < 0.85,
		"umb": UMB_COLORS.pick_random(), "said": "", "said_t": 0.0, "rot": 0.0, "ignore_player": false}


## 人行道上正常走路的行人
func _spawn_walker() -> void:
	var right := randf() < 0.5 or sw_l.y - sw_l.x < 20.0
	var rng: Vector2 = sw_r if right else sw_l
	if rng.y - rng.x < 20.0:
		return
	var v := randf_range(PED_V[0], PED_V[1])
	var dir := -1 if randf() < 0.5 else 1
	var y := -20.0 if (dir > 0 or v < me.v) else H + 20.0
	var mid := (rng.x + rng.y) / 2.0
	var x := randf_range(mid + 4.0, rng.y) if dir < 0 else randf_range(rng.x, mid - 4.0)  # 靠右走
	var e := _ped_ent("walk", Vector2(x, y), dir, 0, v)
	e.xmin = rng.x
	e.xmax = rng.y
	if _free(_rect(e).grow(3.0), e):
		ents.append(e)


## 红灯时走斑马线过马路
func _spawn_crosser(ix: Dictionary) -> void:
	var bottom: float = ix.wy + scroll
	var y: float = bottom - 23.0 if randf() < 0.6 else bottom - IX_H + 23.0
	var from_right := randf() < 0.5
	var x: float = sw_r.x if from_right else sw_l.y
	if not from_right and sw_l.y - sw_l.x < 20.0:
		return
	var v := randf_range(PED_CROSS_V[0], PED_CROSS_V[1])
	var e := _ped_ent("cross", Vector2(x, y + randf_range(-6.0, 6.0)), 0, -1 if from_right else 1, v)
	if (side_r - road_l) / v > ix.t + 3.0:  # 一个红灯走不完
		if median_r - median_l < 30.0 or lanes_opp == 0:
			return
		e.refuge_x = (median_l + median_r) / 2.0  # 先走到中央安全岛等下一个红灯
	if _free(_rect(e).grow(3.0), e):
		ents.append(e)


## 不走斑马线、直接横穿马路的行人
func _spawn_jaywalker(y: float) -> void:
	var e := _ped_ent("jay", Vector2(sw_r.x, y), 0, -1, randf_range(34.0, 42.0))
	e.said = "横穿马路！"
	e.said_t = 2.0
	if _free(_rect(e).grow(3.0), e):
		ents.append(e)


## 过完马路的行人：在对面人行道上顺着走
func _ped_arrive(e: Dictionary) -> void:
	var rng: Vector2 = sw_l if e.hx < 0 else sw_r
	var x := clampf(e.pos.x, rng.x, rng.y)
	var r := Rect2(x - e.hw, e.pos.y - e.hh, e.hw * 2.0, e.hh * 2.0)
	if not _free(r.grow(1.0), e):
		return
	e.pos.x = x
	e.hx = 0
	e.dir = -1 if randf() < 0.5 else 1
	e.v = randf_range(PED_V[0], PED_V[1])
	e.vmax = e.v
	e.kind = "walk"
	e.xmin = rng.x
	e.xmax = rng.y


## 从路边（人行道 / 辅道 / 非机动车道）横穿过来
func _spawn_dart(y: float) -> void:
	var e := _bike_ent("dart", Vector2(curb_x + BK_HH + 4.0, y), 0, -1, randf_range(170.0, 230.0))
	e.ignore_player = true
	e.said = "冲！"
	e.said_t = 1.0
	if _free(_rect(e).grow_individual(4.0, 10.0, 4.0, 10.0), e, false):
		ents.append(e)


func _gen_obstacles() -> void:
	var rate: float = cfg.get("obs_rate", 1.0)
	while obs_next > -scroll - 340.0:
		var y := obs_next + scroll
		obs_next -= randf_range(520.0, 950.0) / maxf(rate, 0.1)
		var skip := false
		for ix in ixs:
			var b: float = ix.wy + scroll
			if y > b - IX_H - 260.0 and y < b + 320.0:
				skip = true
		if skip:
			continue
		var kind := _pick_weighted(cfg.get("obs", {"parked": 0.6, "cones": 0.4}))
		var e: Dictionary
		if kind == "cones":
			var lane := randi() % lanes_own
			if lanes_own - bus_lanes <= 1 and bus_lanes > 0:
				lane = lanes_own - 1 - randi() % bus_lanes  # 不把唯一的社会车道堵死
			var hh := randf_range(70.0, 140.0)
			e = {"type": "cones", "pos": Vector2(_lane_x(lane), y - hh), "hw": 40.0, "hh": hh, "dir": 0, "hx": 0, "v": 0.0}
		else:
			e = {"type": "parked", "pos": Vector2(curb_x - 26.0, y - CAR_HH), "hw": CAR_HW, "hh": CAR_HH,
				"dir": 0, "hx": 0, "v": 0.0, "col": CAR_COLORS.pick_random()}
		if _free(_rect(e).grow(40.0), e):
			ents.append(e)


func _near_miss() -> void:
	var pr := _rect(me)
	for e in ents:
		if not _is_bike(e) or e.get("awarded", false):
			continue
		var r := _rect(e)
		var dx := maxf(0.0, maxf(r.position.x - pr.end.x, pr.position.x - r.end.x))
		var dy := maxf(0.0, maxf(r.position.y - pr.end.y, pr.position.y - r.end.y))
		var d := sqrt(dx * dx + dy * dy)
		if d < 14.0:
			e.near = true
		elif e.near and d > 70.0:
			e.awarded = true
			near_misses += 1
			score += 50.0
			_popup(me.pos + Vector2(0, -60), tr(NEAR_LINES.pick_random()) + " +50", Color("#ffd23f"), 24)
			_sfx("near")


## 测试用自动驾驶：跟车、守红灯、被挡就换道
func _autopilot() -> Array:
	var acc := 1.0
	var gi := _gap_ahead(me, 0.0)
	var gap: float = gi[0]
	if gap < 50.0 + me.v * 0.75:
		acc = -1.0
	var front := PLAYER_Y - CAR_HH
	for ix in ixs:
		var bottom: float = ix.wy + scroll
		if bottom < front - 1.0 and bottom > front - 700.0 and ix.state != "green":
			var d := front - bottom
			var stop_d: float = me.v * me.v / (2.0 * 500.0)
			if ix.state == "yellow" and d < stop_d:
				continue
			if d < stop_d + 40.0:
				acc = -1.0
	if acc > 0.0 and me.v > limit_px * 0.85:
		acc = 0.0
	var cur := clampi(int((me.pos.x - median_r) / LANE_W), 0, lanes_own - 1)
	if ap_tx < 0.0 or absf(me.pos.x - ap_tx) < 3.0:
		ap_tx = -1.0
		if gap < 240.0:
			var best := gap + 120.0
			var stuck: bool = not gi[1].is_empty() and gi[1].type in STATIC_TYPES
			for c in [cur - 1, cur + 1]:
				if c < 0 or c >= lanes_own or (c >= lanes_own - bus_lanes and not stuck):
					continue
				var probe := me.duplicate()
				probe.pos = Vector2(_lane_x(c), me.pos.y)
				if not _free(_rect(probe).grow_individual(2.0, 30.0, 2.0, 30.0), me, false):
					continue
				var g: float = _gap_ahead(probe, 0.0)[0]
				if g > best:
					best = g
					ap_tx = _lane_x(c)
	if ap_tx < 0.0 and bus_lanes > 0 and cur >= lanes_own - bus_lanes and cur > 0:
		var probe := me.duplicate()
		probe.pos = Vector2(_lane_x(cur - 1), me.pos.y)
		if _free(_rect(probe).grow_individual(2.0, 30.0, 2.0, 30.0), me, false):
			ap_tx = _lane_x(cur - 1)
	var st := 0.0
	if ap_tx >= 0.0:
		st = clampf((ap_tx - me.pos.x) / 30.0, -1.0, 1.0)
	return [acc, st]


func _end(win: bool) -> void:
	state = "over"
	won = win
	end_timer = 1.8
	if win:
		_popup(Vector2(W / 2.0, H / 2.0), "准时到达！", Color("#7CFC00"), 64)
		_sfx("win")
	else:
		if late:
			_popup(Vector2(W / 2.0, H / 2.0), "迟到了！", Color("#ff5252"), 64)
		_sfx("lose")


func _result() -> Dictionary:
	var final := int(score)
	if won:
		final += lives * 300 + int((DRIVE_TIME - elapsed) * 10.0)
	return {
		"win": won, "time": minf(elapsed, DRIVE_TIME), "score": final, "near": near_misses, "hits": hits,
		"lives": lives, "mode": "drive", "wait": wait_total, "jaywalks": jaywalks, "run_over": run_over,
		"late": late, "dist": scroll / PX_PER_M, "target": target_px / PX_PER_M, "bus_pen": bus_pen,
		"launched": launched, "invincible": invincible,
	}


# ------------------------------------------------------------------ 绘制

func _draw() -> void:
	_shake_off = Vector2(randf_range(-1, 1), randf_range(-1, 1)) * shake * 10.0
	draw_set_transform(_shake_off)
	_draw_road()
	_draw_bands()
	for e in ents:
		if e.type in STATIC_TYPES:
			_draw_ent(e)
	for e in ents:
		if e.type not in STATIC_TYPES:
			_draw_ent(e)
	if not (invuln > 0.0 and fmod(invuln, 0.2) < 0.1):
		_draw_car(me.pos, lat_v / 250.0 * 0.08, PLAYER_COLOR)
		draw_rect(Rect2(-12, -6, 24, 14), Color("#fff3e0"))
		_text(Vector2(0, 7), "你", 13, Color("#ff7a00"))
	_draw_flyers()
	if cfg.get("median", "") == "viaduct":
		_draw_viaduct()
	if rain:
		_draw_rain()
	if night:
		_draw_night_drive()
	_draw_signals()
	draw_set_transform(_shake_off)
	for e in ents:
		if e.get("said_t", 0.0) > 0.0:
			_text(e.pos + Vector2(0, -e.hh - 12.0), e.said, 18, Color.WHITE)
	for p in popups:
		var col: Color = p.col
		col.a = clampf(p.t * 2.0, 0.0, 1.0)
		_text(p.pos, p.text, p.size, col)
	draw_set_transform(Vector2.ZERO)
	_draw_dwarn()
	_draw_hud_drive()


func _dashes(x: float, col: Color, w := 3.0) -> void:
	var off := fposmod(scroll, 80.0)
	var y := off - 80.0
	while y < H:
		draw_line(Vector2(x, y), Vector2(x, y + 40.0), col, w)
		y += 80.0


func _draw_road() -> void:
	var asphalt := Color("#45474a")
	var sw := Color(level.get("sidewalk", "#cdb9a0"))
	draw_rect(Rect2(0, 0, W, H), sw)
	# 两侧：人行道（贴着道路）+ 临街店铺
	var left_road := road_l - (3.0 * LANE_W if cfg.get("median", "") == "main_road" and lanes_opp == 0 else 0.0)
	_draw_roadside(side_r, minf(W, side_r + 110.0), minf(W, side_r + 110.0), W, sw)
	_draw_roadside(maxf(0.0, left_road - 110.0), left_road, 0.0, maxf(0.0, left_road - 110.0), sw)

	# 辅道 / 非机动车道
	match cfg.get("side", "none"):
		"aux2":
			draw_rect(Rect2(curb_x, 0, 40, H), Color("#5b7a3a"))
			for k in range(floori(scroll / 60.0), ceili((scroll + H) / 60.0) + 1):
				draw_circle(Vector2(curb_x + 20, scroll - k * 60.0 + H), 13, Color("#4a7f31"))
			draw_rect(Rect2(curb_x + 40, 0, side_r - curb_x - 40, H), asphalt)
			_dashes(curb_x + 40 + LANE_W, Color("#e0e0e0"))
			_text_plain(Vector2(curb_x + 60, 120), "辅道", 18, Color(1, 1, 1, 0.4))
		"bike_lane":
			draw_rect(Rect2(curb_x, 0, 14, H), Color("#cfd8dc"))
			for k in range(floori(scroll / 40.0), ceili((scroll + H) / 40.0) + 1):
				draw_rect(Rect2(curb_x + 3, scroll - k * 40.0 + H, 8, 8), Color("#607d8b"))
			draw_rect(Rect2(curb_x + 14, 0, side_r - curb_x - 14, H), Color("#3d6e52"))
			for k in range(floori(scroll / 360.0) - 1, ceili((scroll + H) / 360.0) + 1):
				_text_plain(Vector2(curb_x + 16, scroll - k * 360.0 + H), "非机动车", 13, Color(1, 1, 1, 0.55))

	# 本向车道
	draw_rect(Rect2(median_r, 0, curb_x - median_r, H), asphalt)
	for k in range(1, lanes_own):
		var x := median_r + k * LANE_W
		if bus_lanes > 0 and k == lanes_own - bus_lanes:
			_dashes(x, Color("#f2c230"), 4.0)
		else:
			_dashes(x, Color("#e8e8e8"))
	draw_line(Vector2(curb_x - 3, 0), Vector2(curb_x - 3, H), Color("#f0f0f0"), 3.0)
	if bus_lanes > 0:
		for j in bus_lanes:
			var bx := _lane_x(lanes_own - 1 - j)
			for k in range(floori(scroll / 420.0) - 1, ceili((scroll + H) / 420.0) + 1):
				var sy := scroll - k * 420.0 + H
				_text(Vector2(bx, sy), "公交专用", 22, Color("#f2c230", 0.85))
				_text(Vector2(bx, sy + 24), "7-9  17-19", 15, Color("#f2c230", 0.75))
	# 中央隔离
	match cfg.get("median", "none"):
		"yellow":
			draw_line(Vector2(median_l + 4, 0), Vector2(median_l + 4, H), Color("#f2c230"), 3.0)
			draw_line(Vector2(median_r - 4, 0), Vector2(median_r - 4, H), Color("#f2c230"), 3.0)
			draw_rect(Rect2(median_l + 6, 0, median_r - median_l - 12, H), asphalt)
		"barrier":
			draw_rect(Rect2(median_l, 0, median_r - median_l, H), Color("#d5d5d5"))
			for k in range(floori(scroll / 30.0), ceili((scroll + H) / 30.0) + 1):
				var sy := scroll - k * 30.0 + H
				draw_rect(Rect2(median_l + 3, sy, median_r - median_l - 6, 15), Color("#f2c230") if posmod(k, 2) == 0 else Color("#333333"))
		"green", "main_road":
			draw_rect(Rect2(median_l, 0, median_r - median_l, H), Color("#5b7a3a"))
			for k in range(floori(scroll / 50.0), ceili((scroll + H) / 50.0) + 1):
				draw_circle(Vector2((median_l + median_r) / 2.0, scroll - k * 50.0 + H), 14, Color("#4a7f31"))
		"viaduct":
			draw_rect(Rect2(median_l, 0, median_r - median_l, H), Color("#9e9e9e"))
	# 对向车道 / 主路
	if lanes_opp > 0:
		draw_rect(Rect2(road_l, 0, median_l - road_l, H), asphalt)
		for k in range(1, lanes_opp):
			_dashes(median_l - k * LANE_W, Color("#e8e8e8"))
		draw_line(Vector2(road_l + 3, 0), Vector2(road_l + 3, H), Color("#f0f0f0"), 3.0)
	elif cfg.get("median", "") == "main_road":
		var ml := maxf(0.0, median_l - 3.0 * LANE_W)
		draw_rect(Rect2(ml, 0, median_l - ml, H), asphalt)
		for k in range(1, 3):
			_dashes(median_l - k * LANE_W, Color("#e8e8e8"))
		_text_plain(Vector2(ml + 10, 120), "深南大道主路", 22, Color(1, 1, 1, 0.45))


## 人行道 [sx0, sx1] 和店铺 [bx0, bx1]
func _draw_roadside(sx0: float, sx1: float, bx0: float, bx1: float, sw: Color) -> void:
	if sx1 > sx0:
		draw_rect(Rect2(sx0, 0, sx1 - sx0, H), sw)
		for k in range(floori(scroll / 50.0), ceili((scroll + H) / 50.0) + 1):
			var sy := scroll - k * 50.0 + H
			draw_line(Vector2(sx0, sy), Vector2(sx1, sy), sw.darkened(0.12), 2.0)
		var tx := sx0 + 26.0 if sx0 >= side_r - 1.0 else sx1 - 26.0
		for k in range(floori(scroll / 220.0) - 1, ceili((scroll + H) / 220.0) + 1):
			var sy := scroll - k * 220.0 + H
			draw_circle(Vector2(tx, sy), 26, Color("#3f6b2a", 0.95))
			draw_circle(Vector2(tx - 6, sy - 6), 13, Color("#4f8a34"))
	if bx1 - bx0 < 20.0:
		return
	var shops: Array = level.get("shops", ["便利店"])
	var bh := 200.0
	var w := bx1 - bx0
	var seed := 0 if bx0 > 0.0 else 3
	for k in range(floori(scroll / bh) - 1, ceili((scroll + H) / bh) + 1):
		var sy := scroll - k * bh + H - bh
		var col: Color = block_colors[posmod(k * 7 + seed, block_colors.size())]
		draw_rect(Rect2(bx0, sy, w, bh - 6), col)
		if w > 60.0:
			var sc: Color = sign_colors[posmod(k * 5 + seed, sign_colors.size())]
			var sw2 := minf(128.0, w - 12.0)
			var sx := bx0 + 6.0 if bx0 > 0.0 else bx1 - 6.0 - sw2  # 招牌朝向马路
			draw_rect(Rect2(sx, sy + 40, sw2, 44), sc)
			var name: String = shops[posmod(k + seed, shops.size())]
			_text_plain(Vector2(sx, sy + 70), name if sw2 > 90.0 else name.substr(0, 3), 20 if sw2 > 90.0 else 15, Color("#fff8dc"), sw2, HORIZONTAL_ALIGNMENT_CENTER)
			if w > 160.0:
				draw_rect(Rect2(bx0 + 14, sy + 104, w - 28, 76), col.darkened(0.25))


func _draw_bands() -> void:
	var asphalt := Color("#424448")
	for ix in ixs:
		var bottom: float = ix.wy + scroll
		var top := bottom - IX_H
		if top > H + 10.0 or bottom < -10.0:
			continue
		draw_rect(Rect2(0, top, W, IX_H), asphalt)
		var rl := maxf(road_l, 0.0)
		for yy in [bottom - 40.0, top + 6.0]:  # 两条斑马线
			var x := rl + 8.0
			while x < side_r - 16.0:
				draw_rect(Rect2(x, yy, 22, 34), Color("#e9e9e9"))
				x += 44.0
		draw_line(Vector2(median_r, bottom + 3), Vector2(curb_x, bottom + 3), Color.WHITE, 5.0)  # 本向停止线
		if lanes_opp > 0:
			draw_line(Vector2(rl, top - 3), Vector2(median_l, top - 3), Color.WHITE, 5.0)
		_text_plain(Vector2(side_r + 6, top + IX_H / 2.0 + 8), ix.name, 20, Color(1, 1, 1, 0.8))


func _draw_signals() -> void:
	draw_set_transform(_shake_off)
	for ix in ixs:
		var top: float = ix.wy + scroll - IX_H
		if top > H + 10.0 or top < -80.0:
			continue
		var bx := curb_x - 70.0
		draw_rect(Rect2(bx + 64, top - 30, 6, 30), Color("#555555"))
		draw_rect(Rect2(bx - 40, top - 52, 110, 34), Color("#1b1b1b"))
		var cols := {"red": Color("#ff3b30"), "clear": Color("#ff3b30"), "yellow": Color("#ffcc00"), "green": Color("#3ddc84")}
		var lit: Color = cols[ix.state]
		draw_circle(Vector2(bx - 18, top - 35), 11, lit if ix.state in ["red", "clear"] else Color("#3a1414"))
		draw_circle(Vector2(bx + 12, top - 35), 11, lit if ix.state == "yellow" else Color("#3a3014"))
		draw_circle(Vector2(bx + 42, top - 35), 11, lit if ix.state == "green" else Color("#123020"))


func _draw_ent(e: Dictionary) -> void:
	var r := _rect(e)
	if r.position.y > H + 20.0 or r.end.y < -20.0:
		return
	match e.type:
		"car", "taxi", "parked":
			_draw_car(e.pos, 0.0 if e.dir <= 0 else PI, e.col)
			if e.type == "taxi":
				draw_rect(Rect2(-11, -2, 22, 9), Color("#fdd835"))
				_text(Vector2(0, 6), "TAXI", 9, Color("#333333"))
			elif e.type == "parked" and fmod(Time.get_ticks_msec() / 1000.0, 0.7) < 0.35:
				for c in [Vector2(-20, -42), Vector2(20, -42), Vector2(-20, 42), Vector2(20, 42)]:
					draw_circle(c, 5, Color("#ffa000"))
		"xcar":
			if e.get("bike", false):
				_draw_ebike(e, e.pos)
			else:
				_draw_car(e.pos, PI / 2.0 if e.hx > 0 else -PI / 2.0, e.col)
		"bus":
			draw_set_transform(e.pos + _shake_off, 0.0 if e.dir <= 0 else PI)
			draw_rect(Rect2(-24, -62, 54, 132), Color(0, 0, 0, 0.25))
			var bc := Color("#2e9d4f") if level.city == "深圳" else Color("#d84315")
			draw_rect(Rect2(-26, -66, 52, 132), bc)
			draw_rect(Rect2(-22, -62, 44, 12), Color("#26384a"))
			draw_rect(Rect2(-20, -40, 40, 96), bc.lightened(0.2))
			_text(Vector2(0, 8), "公交", 14, Color.WHITE)
			if e.get("stop_t", 0.0) > 0.0 and fmod(Time.get_ticks_msec() / 1000.0, 0.6) < 0.3:
				draw_circle(Vector2(24, 60), 5, Color("#ffa000"))
		"cones":
			draw_set_transform(_shake_off)
			draw_rect(Rect2(r.position + Vector2(5, 6), r.size), Color(0, 0, 0, 0.25))
			var y := r.position.y
			var i := 0
			while y < r.end.y:
				draw_rect(Rect2(r.position.x, y, r.size.x, minf(18.0, r.end.y - y)), Color("#ff9800") if i % 2 == 0 else Color("#f5f5f5"))
				y += 18.0
				i += 1
			for cy in [r.position.y - 14.0, r.end.y + 4.0]:
				draw_colored_polygon(PackedVector2Array([Vector2(e.pos.x, cy), Vector2(e.pos.x - 9, cy + 12), Vector2(e.pos.x + 9, cy + 12)]), Color("#ff6d00"))
			_text(Vector2(e.pos.x, r.position.y - 20), "前方施工", 16, Color("#ffcc80"))
		"bike":
			_draw_ebike(e, e.pos)
		"ped":
			_draw_ped(e, e.pos, e.rot, 0.62)
		"fallen_ped":
			_draw_ped(e, e.pos, PI / 2.0, 0.62)
			_text(e.pos + Vector2(0, -14), "！", 16, Color("#ff5252"))
		"fallen":
			_draw_ebike(e, e.pos, false)
			draw_set_transform(_shake_off)
			draw_circle(e.pos + Vector2(0, 16), 8, e.helmet)
	draw_set_transform(_shake_off)


func _draw_viaduct() -> void:
	draw_set_transform(_shake_off)
	var cx := (median_l + median_r) / 2.0
	draw_rect(Rect2(cx - 190, 0, 380, H), Color(0.08, 0.08, 0.1, 0.33))  # 高架桥面的阴影
	for k in range(floori(scroll / 300.0) - 1, ceili((scroll + H) / 300.0) + 1):
		var sy := scroll - k * 300.0 + H
		draw_rect(Rect2(cx - 24, sy - 24, 48, 48), Color("#757575"))
		draw_rect(Rect2(cx - 24, sy - 24, 48, 48), Color("#424242"), false, 3.0)
	_text_plain(Vector2(cx - 180, 100), "机场高速高架", 18, Color(1, 1, 1, 0.35))


func _draw_night_drive() -> void:
	draw_set_transform(Vector2.ZERO)
	draw_rect(Rect2(0, 0, W, H), Color(0.02, 0.03, 0.1, 0.58))
	draw_set_transform(_shake_off)
	for k in range(floori(scroll / 240.0) - 1, ceili((scroll + H) / 240.0) + 1):
		var sy := scroll - k * 240.0 + H - 120.0
		draw_circle(Vector2(side_r + 6, sy), 130, Color(1.0, 0.85, 0.5, 0.07))
		draw_circle(Vector2(side_r + 6, sy), 6, Color("#fff3c4"))
	for e in ents:
		if e.type in ["car", "taxi", "bus", "bike", "xcar"]:
			_headlight(e.pos, e.rot, 190.0 if e.type != "bike" else 140.0, 0.14)
	_headlight(me.pos, 0.0, 240.0, 0.2)


func _draw_dwarn() -> void:
	for w in dwarn:
		var blink: bool = fmod(w.t, 0.2) < 0.12
		var col := Color("#ff3b30") if blink else Color("#ffcc00")
		var x := curb_x - 6.0
		draw_colored_polygon(PackedVector2Array([Vector2(x - 36, w.y), Vector2(x, w.y - 20), Vector2(x, w.y + 20)]), col)
		_text(Vector2(x - 90, w.y - 26), "有人横穿马路！" if w.get("kind", "") == "ped" else "路边冲出！", 20, col)


func _draw_hud_drive() -> void:
	draw_rect(Rect2(0, 0, W, 64), Color(0, 0, 0, 0.55))
	_text_plain(Vector2(20, 30), tr("%s · %s（开车）") % [tr(level.city), tr(cfg.get("road", ""))], 24, Color.WHITE, 440)
	var tags := tr("限速 %d") % cfg.get("limit", 50)
	if rain:
		tags += " · " + tr("暴雨")
	if night:
		tags += " · " + tr("夜间")
	if invincible:
		tags += " · " + tr("无敌（已创飞 %d）") % launched
	_text_plain(Vector2(20, 54), tags + "   " + tr("W 加速  S 刹车  A/D 变道  ESC 暂停"), 16, Color("#ffd23f") if invincible else Color("#bbbbbb"), 440)
	var tl := maxf(0.0, DRIVE_TIME - elapsed)
	_text(Vector2(W / 2.0, 38), "00:%02d" % ceili(tl), 34, Color("#ff6b6b") if tl < 10.0 else Color.WHITE)
	var prog := clampf(scroll / target_px, 0.0, 1.0)
	draw_rect(Rect2(W / 2.0 - 150, 48, 300, 8), Color(1, 1, 1, 0.2))
	draw_rect(Rect2(W / 2.0 - 150, 48, 300 * prog, 8), Color("#00e5ff"))
	for i in MAX_LIVES:
		_heart(Vector2(W - 150 + i * 44, 22), 13, Color("#ff4757") if i < lives else Color(1, 1, 1, 0.25))
	_text_plain(Vector2(W - 172, 58), tr("得分 %d") % int(score), 18, Color("#ffd23f"), 150, HORIZONTAL_ALIGNMENT_RIGHT)

	# 仪表：车速 + 限速牌 + 剩余距离
	draw_rect(Rect2(14, H - 96, 300, 84), Color(0, 0, 0, 0.6))
	var kmh: float = me.v / PX_PER_M * 3.6
	_text_plain(Vector2(28, H - 40), "%d" % roundi(kmh), 46, Color.WHITE)
	_text_plain(Vector2(118, H - 40), "km/h", 18, Color("#bbbbbb"))
	draw_circle(Vector2(214, H - 54), 30, Color("#e53935"))
	draw_circle(Vector2(214, H - 54), 23, Color.WHITE)
	_text(Vector2(214, H - 45), str(cfg.get("limit", 50)), 22, Color("#222222"))
	_text_plain(Vector2(252, H - 62), "剩余", 14, Color("#bbbbbb"))
	_text_plain(Vector2(252, H - 40), "%dm" % maxi(0, roundi((target_px - scroll) / PX_PER_M)), 18, Color("#00e5ff"))
	if bus_lanes > 0 and me.pos.x > curb_x - bus_lanes * LANE_W:
		if _bypass_needed():
			_text(Vector2(W / 2.0, 110), "借道公交专用道绕过路障（不扣分）", 26, Color("#7CFC00"))
		else:
			_text(Vector2(W / 2.0, 110), "正在占用公交专用道！", 28, Color("#ffd23f"))

	# 前方信号灯
	var front := PLAYER_Y - CAR_HH
	for ix in ixs:
		var bottom: float = ix.wy + scroll
		if bottom < front and bottom > front - 900.0:
			var px := W - 150.0
			var cols := {"red": Color("#ff3b30"), "clear": Color("#ff3b30"), "yellow": Color("#ffcc00"), "green": Color("#3ddc84")}
			draw_rect(Rect2(px, 74, 130, 64), Color(0, 0, 0, 0.7))
			draw_circle(Vector2(px + 32, 106), 22, cols[ix.state])
			var label: String = tr({"red": "红灯", "clear": "红灯", "yellow": "黄灯", "green": "绿灯"}[ix.state])
			if ix.state != "clear":
				label += " %d" % ceili(maxf(ix.t, 0.0))
			_text_plain(Vector2(px + 60, 113), label, 20, cols[ix.state])
			_text_plain(Vector2(px, 156), "%s %dm" % [tr(ix.name), roundi((front - bottom) / PX_PER_M)], 16, Color("#dddddd"), 130, HORIZONTAL_ALIGNMENT_CENTER)
			break

	if flash > 0.0:
		draw_rect(Rect2(0, 0, W, H), Color(1, 0, 0, flash * 0.3))
	if state == "countdown":
		draw_rect(Rect2(0, H / 2.0 - 140, W, 270), Color(0, 0, 0, 0.55))
		_text(Vector2(W / 2.0, H / 2.0 - 80), tr("%s · %s（开车）") % [tr(level.city), tr(cfg.get("road", ""))], 40, Color.WHITE)
		_text(Vector2(W / 2.0, H / 2.0 - 46), tr("60 秒内开到 %d 米外的目的地 · 限速 %d") % [cfg.get("target_m", 400), cfg.get("limit", 50)], 20, Color("#cccccc"))
		_text(Vector2(W / 2.0, H / 2.0 + 30), str(ceili(countdown)), 72, Color("#ffd23f"))
		_text(Vector2(W / 2.0, H / 2.0 + 72), cfg.get("desc", ""), 20, Color("#ffd23f"))
		_text(Vector2(W / 2.0, H / 2.0 + 106), "W 加速  S 刹车  A/D 变道 · 红灯要自己停车", 18, Color.WHITE)
	elif go_timer > 0.0:
		_text(Vector2(W / 2.0, H / 2.0), "出发！", 72, Color("#7CFC00"))
	if paused:
		draw_rect(Rect2(0, 0, W, H), Color(0, 0, 0, 0.6))
		_text(Vector2(W / 2.0, H / 2.0 - 20), "暂停", 64, Color.WHITE)
		_text(Vector2(W / 2.0, H / 2.0 + 40), "ESC 继续    Q 返回菜单", 24, Color("#dddddd"))
