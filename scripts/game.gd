extends Node2D
## 单个关卡：俯视角人行道，用 WASD / 方向键躲避电动车，坚持 60 秒即通关。
## 包含路口红绿灯等待、地面障碍（地铁口、共享单车、路边停放 / 急刹的电动车、石墩）。
## 所有画面都用 _draw() 程序化绘制，暂不依赖美术资源。
##
## 坐标约定：屏幕 y = 世界 y + scroll。玩家一直向上（世界 y 减小方向）前进。

signal finished(result: Dictionary)

const W := 1280.0
const H := 720.0
const PLAY_R := 1000.0  # 右边界（行道树绿化带）
const LEVEL_TIME := 60.0
const MAX_LIVES := 3
const IX_H := 240.0     # 路口横街的宽度
const JAYWALK_HOLD := 0.5
const STOP_Y := 380.0   # 红灯时近侧路缘停在屏幕上的高度

const HIT_LINES := ["哎哟！", "被电鸡创了！", "看路啊靓仔！", "赶着送外卖啊？", "我的腰……"]
const NEAR_LINES := ["险！", "好险！", "擦身而过！", "丝滑！"]
const BEEP_LINES := ["嘀嘀！", "让一让！", "借过借过！", "嘀——"]
const TRIP_LINES := ["被绊倒了！", "挤不过去了！", "谁乱停的车！"]
const RED_RUN_LINES := ["闯红灯！", "红灯也冲！", "赶时间！"]
const LAUNCH_LINES := ["创飞！", "飞咯～", "再见了您嘞！", "起飞！", "一路走好！"]
const BRAKE_LINES := ["急刹！", "到了到了！", "送个外卖先"]

const BODY_COLORS := [Color("#e8e8e8"), Color("#2b2b2b"), Color("#c0392b"), Color("#2e86de"), Color("#f5f5dc"), Color("#7f8c8d"), Color("#e67e22")]
const HELMET_COLORS := [Color("#f1c40f"), Color("#3498db"), Color("#e74c3c"), Color("#ffffff"), Color("#2ecc71"), Color("#f39c12")]
const SHIRT_COLORS := [Color("#f1c40f"), Color("#2980b9"), Color("#34495e"), Color("#ecf0f1"), Color("#8e44ad"), Color("#16a085")]
const BOX_COLORS := [Color("#f7c600"), Color("#1e90ff")]
const QUILT_COLORS := [Color("#7b1f2a"), Color("#1d2b53"), Color("#3d3d3d")]
const CAR_COLORS := [Color("#ecf0f1"), Color("#1abc9c"), Color("#2c3e50"), Color("#c0392b"), Color("#95a5a6"), Color("#2ecc71"), Color("#34495e")]
const PONCHO_COLORS := [Color("#e53935", 0.85), Color("#1e88e5", 0.85), Color("#fdd835", 0.85), Color("#e0e0e0", 0.7), Color("#7cb342", 0.85)]
const STALL_COLORS := [Color("#e53935"), Color("#1e88e5"), Color("#fb8c00"), Color("#43a047")]
const PED_SHIRTS := [Color("#e57373"), Color("#64b5f6"), Color("#81c784"), Color("#fff176"), Color("#ba68c8"), Color("#ffffff"), Color("#424242"), Color("#ff8a65"), Color("#4db6ac")]
const PED_HAIR := [Color("#1b1b1b"), Color("#3e2723"), Color("#5d4037"), Color("#9e9e9e"), Color("#212121")]
const UMB_COLORS := [Color("#1565c0"), Color("#c62828"), Color("#2e7d32"), Color("#6a1b9a"), Color("#f9a825"), Color("#37474f")]
const PED_HIT_LINES := ["撞到人了！", "对不起对不起！", "看路啊！", "哎哟喂！"]
const SHARED_COLORS := [Color("#f7c600"), Color("#1e88e5"), Color("#43a047")]

var PLAY_L := 250.0  # 人行道可活动区域左边界（店铺台阶外），按关卡调整
var level: Dictionary = {}
var rain := false
var night := false
var mix: Dictionary = {}
var mode := "walk"
var demo := false
var sfx_cb: Callable
var block_colors: Array = []
var sign_colors: Array = []
var difficulty := 1.0

var scroll := 0.0
var scroll_rate := 0.0  # 本帧实际滚动速度（等红灯时为 0）
var scroll_speed := 110.0
var elapsed := 0.0
var lives := MAX_LIVES
var score := 0.0
var near_misses := 0
var hits := 0
var wait_total := 0.0
var state := "countdown"  # countdown / play / over / done
var countdown := 3.0
var go_timer := 0.0
var end_timer := 0.0
var won := false
var spawn_timer := 0.8
var car_timer := 0.0
var invuln := 0.0
var shake := 0.0
var flash := 0.0
var paused := false
var touch_ui := false  # 由 main.gd 在触屏设备上设置
var god := false  # 测试用：不掉血（命令行 --god）
var invincible := false  # 无敌模式：不掉血、无视红灯，撞到的电鸡全部创飞
var launched := 0
var combo := 0
var combo_t := 0.0
var flyers: Array = []  # 被创飞的电鸡

var player_pos := Vector2(620, 590)
var player_vel := Vector2.ZERO
var player_speed := 270.0
var player_r := 13.0
var walk_phase := 0.0
var lean := 0.0
var red_nag := 0.0
var push_t := 0.0     # 顶着红灯往前按的时间，超过 JAYWALK_HOLD 算闯红灯
var near_curb := false  # 正在路缘前等红灯，显示闯红灯提示
var jaywalks := 0
var run_over := false

var bikes: Array = []
var warnings: Array = []
var popups: Array = []
var cars: Array = []
var obstacles: Array = []
var next_gen_wy := -120.0
var last_metro_wy := 0.0

var ix: Dictionary = {}  # 当前路口，空字典表示没有
var ix_index := 0
var waiting := false
var cross_cars: Array = []
var cross_timer := 0.0
var peds: Array = []   # 行人
var ped_timer := 0.5

var font: Font
var _shake_off := Vector2.ZERO


func setup(p_level: Dictionary, p_mode: String, p_demo: bool, p_sfx: Callable) -> void:
	level = p_level
	mode = p_mode
	demo = p_demo
	sfx_cb = p_sfx
	for c in level.get("block_colors", ["#b8a58c", "#9fa8a3", "#c7b299", "#a39589", "#b3b8a0"]):
		block_colors.append(Color(c))
	for c in level.get("sign_colors", ["#c0392b", "#27ae60", "#2c3e50", "#d35400", "#8e44ad", "#16a085"]):
		sign_colors.append(Color(c))
	difficulty = level.get("difficulty", 1.0)
	PLAY_L = level.get("play_l", 250.0)
	rain = level.get("weather", "clear") == "rain"
	night = level.get("night", false)
	mix = level.get("mix", {})
	player_pos.x = (PLAY_L + PLAY_R) / 2.0
	if mode == "bike":
		scroll_speed = 200.0
		player_speed = 360.0
		player_r = 16.0
	if demo:
		state = "play"
		elapsed = 30.0


func _ready() -> void:
	font = ThemeDB.fallback_font
	for i in 4:
		_spawn_car(randf_range(0.0, H))


func _sfx(n: String) -> void:
	if sfx_cb.is_valid() and not demo:
		sfx_cb.call(n)


func _unhandled_input(e: InputEvent) -> void:
	if demo or not (e is InputEventKey) or not e.pressed or e.echo:
		return
	if e.keycode == KEY_ESCAPE and state != "over":
		paused = not paused
		get_viewport().set_input_as_handled()
	elif paused and e.keycode == KEY_Q:
		finished.emit({"quit": true})


# ------------------------------------------------------------------ 更新

func _process(delta: float) -> void:
	if paused:
		queue_redraw()
		return
	shake = maxf(0.0, shake - delta * 3.0)
	flash = maxf(0.0, flash - delta * 2.0)
	go_timer = maxf(0.0, go_timer - delta)
	red_nag = maxf(0.0, red_nag - delta)
	scroll_rate = 0.0

	match state:
		"countdown":
			var before := ceili(countdown)
			countdown -= delta
			if ceili(countdown) != before and countdown > 0.0:
				_sfx("tick")
			_update_player(delta)
			if countdown <= 0.0:
				state = "play"
				go_timer = 0.8
				_sfx("go")
		"play":
			if not demo:
				elapsed += delta
				score += delta * 10.0
			invuln = maxf(0.0, invuln - delta)
			_advance_scroll(delta)
			_update_intersection(delta)
			_gen_obstacles()
			_update_player(delta)
			_update_spawning(delta)
			_update_bikes(delta)
			_update_peds(delta)
			_final_separate()
			_check_traffic()
			if not demo and elapsed >= LEVEL_TIME:
				_end(true)
		"over":
			if won:
				_advance_scroll(delta)
			_update_intersection(delta)
			_update_bikes(delta)
			_update_peds(delta)
			_final_separate()
			end_timer -= delta
			if end_timer <= 0.0:
				state = "done"
				finished.emit(_result())

	_update_cars(delta)
	_update_cross_cars(delta)
	_update_popups(delta)
	_update_flyers(delta)
	_cull_obstacles()
	queue_redraw()


func _advance_scroll(delta: float) -> void:
	var target := scroll + scroll_speed * delta
	waiting = false
	if not ix.is_empty() and ix.state != "green" and not ix.get("jaywalk", false):
		var max_scroll: float = STOP_Y - IX_H - ix.wy
		if target >= max_scroll:
			target = maxf(scroll, max_scroll)
			waiting = true
			wait_total += delta
	scroll_rate = (target - scroll) / maxf(delta, 0.0001)
	scroll = target


func _update_player(delta: float) -> void:
	if demo:
		return
	var inp := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if mode == "walk" and not rain:
		player_vel = inp * player_speed
	else:  # 骑车有惯性；雨天地面湿滑，惯性更大
		var grip := (7.0 if mode == "walk" else 2.8) if rain else 5.0
		player_vel = player_vel.lerp(inp * player_speed, clampf(delta * grip, 0.0, 1.0))
	player_pos += player_vel * delta

	var rects := _solid_rects()
	_resolve_player(rects)
	if state == "play" and not invincible and invuln <= 0.0:
		for p in peds:
			if player_pos.distance_to(p.pos) < player_r + p.r + 1.5:
				_player_hit(p.pos, PED_HIT_LINES.pick_random())
				p.said = "看路啊！"
				p.said_t = 1.2
				break
	var crs := []
	if not ix.is_empty():
		for c in cross_cars:
			crs.append(_cross_rect(c))
	for it in 3:  # 路障、行人、电鸡、横街车可能互相推回去，迭代几次
		_resolve_circles()
		_resolve_bikes()
		_resolve_player(crs, true)
		_resolve_player(rects, true)

	var minx := PLAY_L + player_r + 4.0
	var maxx := PLAY_R - player_r - 4.0
	if player_pos.x < minx or player_pos.x > maxx:
		player_pos.x = clampf(player_pos.x, minx, maxx)
		player_vel.x = 0.0
	var miny := 150.0
	near_curb = false
	if not ix.is_empty() and ix.state != "green" and not ix.get("jaywalk", false):
		var curb: float = ix.wy + scroll + IX_H
		if player_pos.y > curb - IX_H * 0.5:
			miny = maxf(miny, curb + 8.0 + player_r)
			# 路口进入画面、人在路缘附近：按住 ↑ 或按空格硬闯
			near_curb = state == "play" and curb > 120.0 and player_pos.y <= miny + 60.0
			if near_curb and Input.is_action_just_pressed("jaywalk"):
				_jaywalk()
			elif near_curb and inp.y < -0.3:  # 被等灯的电鸡挡住也能硬闯
				push_t += delta
				if push_t >= JAYWALK_HOLD:
					_jaywalk()
			else:
				push_t = maxf(0.0, push_t - delta * 2.0)
	if player_pos.y < miny or player_pos.y > H - 34.0:
		player_pos.y = clampf(player_pos.y, miny, H - 34.0)
		player_vel.y = 0.0

	# 被路障 / 横街车顶到画面底边：路障会绊倒扣血；然后从旁边挤出去（不会穿模）
	var solids: Array = rects.duplicate()
	if not ix.is_empty():
		for c in cross_cars:
			solids.append(_cross_rect(c))
	for k in solids.size():
		var rc: Rect2 = solids[k]
		if _circle_hits_rect(player_pos, player_r - 0.5, rc):
			if k < rects.size() and state == "play" and invuln <= 0.0 and not invincible:
				_player_hit(rc.get_center(), TRIP_LINES.pick_random())
			_escape_sideways(rc, solids, minx, maxx)

	var fwd := scroll_rate if state == "play" else 0.0
	walk_phase += delta * (player_vel.length() + fwd) / 9.0
	lean = lerpf(lean, player_vel.x / player_speed * 0.35, clampf(delta * 8.0, 0.0, 1.0))


func _circle_hits_rect(c: Vector2, r: float, rect: Rect2) -> bool:
	var cp := Vector2(clampf(c.x, rect.position.x, rect.end.x), clampf(c.y, rect.position.y, rect.end.y))
	return c.distance_to(cp) < r


## 被挤住时横向挤出：选离得近、且不会撞上别的路障的一侧
func _escape_sideways(rc: Rect2, rects: Array, minx: float, maxx: float) -> void:
	var cands := [rc.position.x - player_r - 0.5, rc.end.x + player_r + 0.5]
	for k in range(1, 60):  # 两侧都被挡住：在整条人行道上找最近的空位
		cands.append(player_pos.x + k * 12.0)
		cands.append(player_pos.x - k * 12.0)
	cands.sort_custom(func(a, b): return absf(a - player_pos.x) < absf(b - player_pos.x))
	for x in cands:
		if x < minx or x > maxx:
			continue
		var ok := true
		for r in rects:
			if _circle_hits_rect(Vector2(x, player_pos.y), player_r - 0.5, r):
				ok = false
				break
		if ok:
			player_pos.x = x
			player_vel.x = 0.0
			return


## 每帧最后统一分离：玩家 / 路障 / 停着的电鸡不动，行人和行驶中的电鸡反复推开直到谁都不挨着
func _final_separate() -> void:
	var rects := _solid_rects()
	var rr2 := player_r + 11.0
	for it in 4:
		var moved := false
		for p in peds:
			for r in rects:
				var rr: Rect2 = r
				var cp := Vector2(clampf(p.pos.x, rr.position.x, rr.end.x), clampf(p.pos.y, rr.position.y, rr.end.y))
				var d: Vector2 = p.pos - cp
				if d.length() < p.r:
					var n := d.normalized() if d.length() > 0.01 else Vector2(signf(p.pos.x - rr.get_center().x + 0.01), 0)
					p.pos = cp + n * (p.r + 0.3)
					moved = true
			if not demo:
				var dp: Vector2 = p.pos - player_pos
				if dp.length() < p.r + player_r:
					p.pos = player_pos + (dp.normalized() if dp.length() > 0.01 else Vector2.UP) * (p.r + player_r + 0.3)
					moved = true
			for o in peds:
				if is_same(o, p):
					continue
				var dv: Vector2 = o.pos - p.pos
				var need2: float = p.r + o.r
				if dv.length() < need2:
					var n := dv.normalized() if dv.length() > 0.01 else Vector2.RIGHT
					var push := (need2 - dv.length()) / 2.0 + 0.2
					o.pos += n * push
					p.pos -= n * push
					moved = true
			for b in bikes:
				var need: float = p.r + 11.0
				var dir := Vector2.UP.rotated(b.rot)
				var cp2 := Geometry2D.get_closest_point_to_segment(p.pos, b.pos + dir * 22.0, b.pos - dir * 22.0)
				var dd: Vector2 = p.pos - cp2
				if dd.length() < need:
					var n := dd.normalized() if dd.length() > 0.01 else Vector2(signf(p.pos.x - b.pos.x + 0.01), 0)
					var push := need - dd.length() + 0.3
					if b.stopped:
						p.pos += n * push
					else:
						b.pos -= n * push
					moved = true
		if not demo:
			for b in bikes:
				var dir := Vector2.UP.rotated(b.rot)
				var cp3 := Geometry2D.get_closest_point_to_segment(player_pos, b.pos + dir * 22.0, b.pos - dir * 22.0)
				var dd: Vector2 = cp3 - player_pos
				if dd.length() < rr2:
					var n := dd.normalized() if dd.length() > 0.01 else Vector2(signf(b.pos.x - player_pos.x + 0.01), 0)
					b.pos += n * (rr2 - dd.length() + 0.3)
					moved = true
		if not moved:
			break
	# 兜底：还被夹住的行人挪到旁边最近的空位，实在没地方就走进旁边的店里
	for i in range(peds.size() - 1, -1, -1):
		var p: Dictionary = peds[i]
		if not _ped_overlaps_any(p, p.pos, rects):
			continue
		var placed := false
		for off in [Vector2(14, 0), Vector2(-14, 0), Vector2(28, 0), Vector2(-28, 0), Vector2(0, 14), Vector2(0, -14), Vector2(42, 0), Vector2(-42, 0), Vector2(0, 28), Vector2(0, -28)]:
			var np: Vector2 = p.pos + off
			if np.x > PLAY_L + p.r and np.x < PLAY_R - p.r and not _ped_overlaps_any(p, np, rects):
				p.pos = np
				placed = true
				break
		if not placed:
			peds.remove_at(i)


func _ped_overlaps_any(p: Dictionary, at: Vector2, rects: Array) -> bool:
	if _ped_blocked(p, at, rects):
		return true
	return not demo and at.distance_to(player_pos) < p.r + player_r


## 电鸡是胶囊形的实心体：把玩家推出去
func _resolve_bikes() -> void:
	var rr := player_r + 11.0
	for b in bikes:
		var dir := Vector2.UP.rotated(b.rot)
		var cp := Geometry2D.get_closest_point_to_segment(player_pos, b.pos + dir * 22.0, b.pos - dir * 22.0)
		var d: Vector2 = player_pos - cp
		var dist := d.length()
		if dist < rr:
			var n := d / dist if dist > 0.01 else Vector2.DOWN
			player_pos = cp + n * (rr + 0.2)
			var vn := player_vel.dot(n)
			if vn < 0.0:
				player_vel -= n * vn


## 行人是圆形的实心体：把玩家推出去
func _resolve_circles() -> void:
	for p in peds:
		var d: Vector2 = player_pos - p.pos
		var need: float = player_r + p.r
		var dist := d.length()
		if dist < need:
			var n := d / dist if dist > 0.01 else Vector2.DOWN
			player_pos = p.pos + n * need
			var vn := player_vel.dot(n)
			if vn < 0.0:
				player_vel -= n * vn


func _resolve_player(rects: Array, force := false) -> void:
	if invuln > 0.0 and not force:
		return  # 受击无敌时可以穿过路障，避免卡死（车辆、行人除外）
	for r in rects:
		var rr: Rect2 = r
		var cp := Vector2(clampf(player_pos.x, rr.position.x, rr.end.x), clampf(player_pos.y, rr.position.y, rr.end.y))
		var d := player_pos - cp
		var dist := d.length()
		if dist >= player_r:
			continue
		var n: Vector2
		if dist < 0.01:
			var pushes := [
				[player_pos.x - rr.position.x, Vector2.LEFT],
				[rr.end.x - player_pos.x, Vector2.RIGHT],
				[player_pos.y - rr.position.y, Vector2.UP],
				[rr.end.y - player_pos.y, Vector2.DOWN],
			]
			pushes.sort_custom(func(a, b): return a[0] < b[0])
			n = pushes[0][1]
			player_pos += n * (pushes[0][0] + player_r)
		else:
			n = d / dist
			player_pos = cp + n * player_r
		var vn := player_vel.dot(n)
		if vn < 0.0:
			player_vel -= n * vn


# ------------------------------------------------------------------ 路口 / 红绿灯

func _update_intersection(delta: float) -> void:
	if demo:
		return
	var times: Array = level.get("crossings", [])
	if ix.is_empty() and ix_index < times.size() and elapsed >= times[ix_index] and state == "play":
		_spawn_intersection()
		ix_index += 1
	if ix.is_empty():
		return
	var top: float = ix.wy + scroll
	match ix.state:
		"red":
			ix.red_t -= delta
			cross_timer -= delta
			if cross_timer <= 0.0:
				cross_timer = randf_range(0.6, 1.3)
				_spawn_cross_car()
			if ix.red_t <= 0.0:
				ix.state = "clear"
		"clear":
			# 等横街车辆开出斑马线再转绿（最多 2.5 秒）
			ix.clear_t = ix.get("clear_t", 0.0) + delta
			var busy := false
			for c in cross_cars:
				if _car_inside(c):
					busy = true
			if not busy or ix.clear_t > 2.5:
				ix.state = "green"
				_sfx("go")
				if top + IX_H > 0.0 and top < H:
					_popup(Vector2(W / 2.0, 160), "绿灯！走！", Color("#7CFC00"), 44)
				for b in bikes:
					if b.stopped and b.kind == "queue":
						b.stopped = false
						b.vel = Vector2(randf_range(-10.0, 10.0), -randf_range(260.0, 340.0))
						b.said = "冲！"
						b.said_t = 0.8
	if top > H + 40.0:
		ix = {}


func _spawn_intersection() -> void:
	var names: Array = level.get("cross_names", ["横街"])
	var rt: Array = level.get("red_time", [4.0, 7.0])
	var wy := -scroll - 420.0
	var travel := (STOP_Y - IX_H - wy - scroll) / scroll_speed
	ix = {
		"wy": wy, "state": "red", "red_t": travel + randf_range(rt[0], rt[1]),
		"name": names[posmod(ix_index, names.size())],
	}
	cross_timer = 0.0
	# 清掉落在路口里的障碍
	var band := Rect2(PLAY_L - 10.0, wy - 60.0, PLAY_R - PLAY_L + 20.0, IX_H + 120.0)
	for i in range(obstacles.size() - 1, -1, -1):
		if _oworld(obstacles[i]).intersects(band):
			obstacles.remove_at(i)


func _spawn_cross_car() -> void:
	var right := randf() < 0.5
	var lane_y := 170.0 if right else 70.0
	var start_x := -70.0 if right else W + 70.0
	for c in cross_cars:
		if absf(c.lane_y - lane_y) < 40.0 and absf(c.x - start_x) < 130.0:
			return
	var is_bike := randf() < 0.3
	cross_cars.append({
		"x": start_x, "lane_y": lane_y + (randf_range(-30.0, 30.0) if is_bike else 0.0),
		"dir": 1.0 if right else -1.0, "vel": randf_range(220.0, 340.0) if is_bike else randf_range(260.0, 420.0),
		"col": CAR_COLORS.pick_random(), "bike": _make_look() if is_bike else {},
	})


func _update_cross_cars(delta: float) -> void:
	if ix.is_empty():
		cross_cars.clear()
		return
	for i in range(cross_cars.size() - 1, -1, -1):
		var c: Dictionary = cross_cars[i]
		var nx: float = c.x + c.dir * c.vel * delta
		# 斑马线上有电鸡（或有电鸡在路边等着过）：在斑马线入口外停车让行，绝不停在斑马线中间
		var hl: float = 44.0 if c.bike.is_empty() else 36.0
		# 行人绿灯时横街车也一律停在斑马线外
		c.holding = false
		var before: bool = (c.x + hl <= PLAY_L - 5.5) if c.dir > 0.0 else (c.x - hl >= PLAY_R + 5.5)
		if before and (ix.state != "red" or _crosswalk_busy()):
			var lim: float = PLAY_L - 6.0 - hl
			if c.dir < 0.0:
				lim = W + 10.0 + hl if c.x - hl > W else PLAY_R + 6.0 + hl  # 还没开进主路的停在画面外
			if (c.dir > 0.0 and nx >= lim) or (c.dir < 0.0 and nx <= lim):
				nx = minf(nx, lim) if c.dir > 0.0 else maxf(nx, lim)
				c.holding = true
		# 前方是玩家或行人就停（无敌闯红灯时不再从玩家身上开过去）
		var nr := _cross_rect(c)
		nr.position.x += nx - c.x
		if _circle_hits_rect(player_pos, player_r + 0.5, nr):
			nx = c.x
		for p in peds:
			if _circle_hits_rect(p.pos, p.r + 1.0, nr):
				nx = c.x
		for o in cross_cars:  # 跟车，不追尾
			if is_same(o, c) or o.dir != c.dir or absf(o.lane_y - c.lane_y) > 40.0:
				continue
			if (o.x - c.x) * c.dir > 0.0:
				nx = minf(nx, o.x - 100.0) if c.dir > 0.0 else maxf(nx, o.x + 100.0)
		c.x = nx
		if c.x < -140.0 or c.x > W + 140.0:
			cross_cars.remove_at(i)


func _crosswalk_zone() -> Rect2:
	return Rect2(PLAY_L - 6.0, ix.wy + scroll, PLAY_R - PLAY_L + 12.0, IX_H)


func _car_inside(c: Dictionary) -> bool:
	var r := _cross_rect(c)
	return r.end.x > PLAY_L - 6.0 and r.position.x < PLAY_R + 6.0


## 斑马线里有车，或有车正要开进来（已停车让行的不算）
func _cars_crossing() -> bool:
	for c in cross_cars:
		if _car_inside(c):
			return true
		if c.get("holding", false):
			continue
		var hl: float = 44.0 if c.bike.is_empty() else 36.0
		var gap: float = (PLAY_L - 6.0 - (c.x + hl)) if c.dir > 0.0 else ((c.x - hl) - (PLAY_R + 6.0))
		if gap >= 0.0 and gap < 90.0:
			return true
	return false


## 斑马线里有电鸡，或有电鸡在路边等着过
func _crosswalk_busy() -> bool:
	var zone := _crosswalk_zone()
	for b in bikes:
		if b.get("xwait", false) or zone.intersects(_bike_rect(b.pos)):
			return true
	return false


func _cross_rect(c: Dictionary) -> Rect2:
	var hl: float = 44.0 if c.bike.is_empty() else 36.0
	var hw: float = 23.0 if c.bike.is_empty() else 17.0
	return Rect2(c.x - hl, ix.wy + scroll + c.lane_y - hw, hl * 2.0, hw * 2.0)


func _bike_rect(p: Vector2) -> Rect2:
	return Rect2(p.x - 13.0, p.y - 34.0, 26.0, 68.0)


func _jaywalk() -> void:
	ix.jaywalk = true
	push_t = 0.0
	near_curb = false
	jaywalks += 1
	if invincible:
		_popup(player_pos + Vector2(0, -60), "无敌！红灯算什么", Color("#ffd23f"), 28)
		_sfx("whistle")
		return
	var loss := int(score * 0.25)
	score -= loss
	_popup(player_pos + Vector2(0, -60), tr("闯红灯！-%d 分") % loss, Color("#ff5252"), 30)
	_popup(Vector2(W / 2.0, 170), "被车撞到直接 GAME OVER！", Color("#ff9800"), 30)
	_sfx("whistle")


## 闯红灯时被横街车辆撞到：直接结束
func _check_traffic() -> void:
	if ix.is_empty() or demo or state != "play" or invincible:
		return
	for c in cross_cars:
		if _circle_hits_rect(player_pos, player_r + 6.0, _cross_rect(c)):
			if god:
				if invuln <= 0.0:
					invuln = 1.0
					_popup(player_pos + Vector2(0, -50), "（无敌）被车撞了", Color("#ff5252"), 24)
				return
			run_over = true
			hits += 1
			lives = 0
			shake = 1.5
			flash = 1.0
			_popup(player_pos + Vector2(0, -50), "闯红灯被车撞了！", Color("#ff5252"), 36)
			_sfx("hit")
			_end(false)
			return


func _red_active() -> bool:
	return not ix.is_empty() and ix.state != "green"


# ------------------------------------------------------------------ 电鸡

func _update_spawning(delta: float) -> void:
	spawn_timer -= delta
	if spawn_timer <= 0.0:
		var p := elapsed / LEVEL_TIME
		spawn_timer = lerpf(1.15, 0.42, p) * randf_range(0.75, 1.25) / difficulty
		if mode == "bike":
			spawn_timer *= 0.9
		_spawn_random(p)

	for i in range(warnings.size() - 1, -1, -1):
		var w: Dictionary = warnings[i]
		w.t -= delta
		if w.kind == "cross":
			w.pos.y += scroll_rate * delta
		if w.t <= 0.0:
			_spawn_bike(w.kind, w.pos)
			warnings.remove_at(i)


func _spawn_random(p: float) -> void:
	var r := randf()
	var x := randf_range(PLAY_L + 30.0, PLAY_R - 30.0)
	var w_over: float = mix.get("overtake", 0.22) + p * 0.08
	var w_weave: float = w_over + mix.get("weave", 0.18)
	var w_cross: float = w_weave + mix.get("cross", 0.12)
	if elapsed > 4.0 and r < w_over:
		var kind := "overtake"
		if _red_active() and ix.wy + scroll + IX_H > 0.0 and randf() < 0.65:
			kind = "queue"  # 红灯：挤到你旁边一起等
		_warn(kind, Vector2(x, H + 70.0))
	elif elapsed > mix.get("weave_after", 12.0) and r < w_weave:
		_spawn_bike("weave", Vector2(x, -80.0))
	elif elapsed > mix.get("cross_after", 22.0) and r < w_cross:
		var cy := randf_range(170.0, 430.0)
		if not ix.is_empty() and cy > ix.wy + scroll - 80.0 and cy < ix.wy + scroll + IX_H + 80.0:
			cy = ix.wy + scroll + IX_H + 90.0
		if cy < H - 80.0:
			_warn("cross", Vector2(PLAY_L - 70.0, cy))
	else:
		if randf() < 0.35 and not demo:
			x = clampf(player_pos.x + randf_range(-40.0, 40.0), PLAY_L + 30.0, PLAY_R - 30.0)
		_spawn_bike("oncoming", Vector2(x, -80.0))
	# 后半段偶尔来一排电鸡
	if elapsed > mix.get("convoy_after", 35.0) and randf() < mix.get("convoy", 0.25):
		var x2 := fposmod(x + randf_range(160.0, 420.0) - PLAY_L, PLAY_R - PLAY_L - 60.0) + PLAY_L + 30.0
		_spawn_bike("oncoming", Vector2(x2, -140.0))


func _warn(kind: String, pos: Vector2) -> void:
	warnings.append({"kind": kind, "pos": pos, "t": 0.9, "max": 0.9})
	_sfx("beep")


func _make_look() -> Dictionary:
	var cargo: bool = randf() < level.get("cargo_chance", 0.05)
	return {
		"body": BODY_COLORS.pick_random(), "helmet": HELMET_COLORS.pick_random(),
		"shirt": SHIRT_COLORS.pick_random(), "box": BOX_COLORS.pick_random(),
		"has_box": not cargo and randf() < level.get("box_chance", 0.45), "cargo": cargo,
		"quilt": randf() < 0.25, "quilt_color": QUILT_COLORS.pick_random(), "rot": 0.0,
		"poncho": PONCHO_COLORS.pick_random() if rain else Color(0, 0, 0, 0),
	}


func _spawn_bike(kind: String, pos: Vector2) -> void:
	if not ix.is_empty() and pos.y > ix.wy + scroll - 60.0 and pos.y < ix.wy + scroll + IX_H + 60.0:
		return  # 不在路口里凭空出现
	var p := elapsed / LEVEL_TIME
	var k := difficulty * (1.0 + p * 0.4)
	var b := _make_look()
	b.merge({
		"kind": kind, "pos": pos, "vel": Vector2.ZERO, "t": 0.0,
		"base_x": pos.x, "amp": 0.0, "freq": 0.0,
		"near": false, "hit": false, "awarded": false, "said": "", "said_t": 0.0,
		"stopped": false, "brake": false, "braking": false, "brake_y": 0.0, "queue_off": 0.0,
	}, true)
	# vel 为相对地面的速度（屏幕速度 = vel + 滚动速度）
	match kind:
		"oncoming":
			b.vel = Vector2(randf_range(-20.0, 20.0), randf_range(170.0, 280.0) * k + scroll_speed)
			b.rot = PI
			if elapsed > 6.0 and randf() < mix.get("brake", 0.15):
				b.brake = true
				b.brake_y = randf_range(140.0, 300.0)
			if _red_active() and randf() < 0.5:
				b.said = RED_RUN_LINES.pick_random()
				b.said_t = 1.4
		"weave":
			b.vel = Vector2(0.0, randf_range(140.0, 220.0) * difficulty)
			b.amp = randf_range(60.0, 140.0)
			b.freq = randf_range(1.5, 2.6)
			b.base_x = clampf(pos.x, PLAY_L + b.amp + 20.0, PLAY_R - b.amp - 20.0)
			b.rot = PI
		"overtake", "queue":
			b.vel = Vector2(randf_range(-15.0, 15.0), -randf_range(230.0, 330.0) * (1.0 + p * 0.3) * difficulty - scroll_speed)
			b.said = BEEP_LINES.pick_random()
			b.said_t = 1.2
			b.queue_off = randf_range(16.0, 90.0)
			if kind == "overtake" and elapsed > 10.0 and randf() < mix.get("brake", 0.15) * 1.6:
				b.brake = true
				b.brake_y = randf_range(180.0, 380.0)
		"cross":
			b.vel = Vector2(randf_range(260.0, 340.0) * difficulty, 0.0)
			b.rot = PI / 2.0
			b.said = "冲出来了！"
			b.said_t = 1.0
	if randf() < 0.15 and b.said == "":
		b.said = BEEP_LINES.pick_random()
		b.said_t = 1.0
	if _bike_hits_ped(b.pos, b.rot):
		return  # 生成点上有行人，这只电鸡不出现
	bikes.append(b)


func _update_bikes(delta: float) -> void:
	for i in range(bikes.size() - 1, -1, -1):
		var b: Dictionary = bikes[i]
		var old: Vector2 = b.pos
		b.t += delta
		b.said_t = maxf(0.0, b.said_t - delta)
		var world_v: Vector2 = b.vel
		if b.stopped:
			b.pos.y += scroll_rate * delta
		elif b.kind == "weave":
			b.base_x = clampf(b.base_x + _steer(b, delta), PLAY_L + b.amp + 18.0, PLAY_R - b.amp - 18.0)
			var nx: float = b.base_x + sin(b.t * b.freq) * b.amp
			world_v = Vector2((nx - b.pos.x) / maxf(delta, 0.0001), b.vel.y)
			b.pos = Vector2(nx, b.pos.y + (b.vel.y + scroll_rate) * delta)
		else:
			b.pos += (b.vel + Vector2(0.0, scroll_rate)) * delta
			if b.kind != "cross":
				b.pos.x += _steer(b, delta)
				if b.pos.x < PLAY_L + 18.0 or b.pos.x > PLAY_R - 18.0:
					b.vel.x = -b.vel.x
					b.pos.x = clampf(b.pos.x, PLAY_L + 18.0, PLAY_R - 18.0)
		if b.kind == "cross" and b.pos.x > PLAY_R - 60.0:
			b.kind = "overtake"
			b.vel = Vector2(0.0, -randf_range(200.0, 280.0) * difficulty - scroll_speed)
		# 斑马线上有车在过：在路口边等，等车让出空档再走
		b.xwait = false
		if not b.stopped and not ix.is_empty():
			var zone := _crosswalk_zone()
			var now_in := zone.intersects(_bike_rect(b.pos))
			if now_in and not b.get("inzone", false) and _cars_crossing():
				var below: bool = old.y > zone.get_center().y
				b.pos = Vector2(old.x, zone.end.y + 35.0 if below else zone.position.y - 35.0)
				b.t -= delta
				b.xwait = true
				world_v = Vector2.ZERO
				now_in = false
			b.inzone = now_in
		if world_v.length() > 20.0:
			b.rot = lerp_angle(b.rot, world_v.angle() + PI / 2.0, clampf(delta * 10.0, 0.0, 1.0))

		# 急刹：停下后变成路上的障碍
		if b.brake and not b.braking:
			if (b.vel.y > 0.0 and b.pos.y > b.brake_y) or (b.vel.y < 0.0 and b.pos.y < b.brake_y):
				b.braking = true
				b.said = BRAKE_LINES.pick_random()
				b.said_t = 1.5
				_sfx("brake")
		if b.braking:
			b.vel = (b.vel as Vector2).move_toward(Vector2.ZERO, 1100.0 * delta)
			if b.vel.length() < 5.0:
				_park_bike(b)
				bikes.remove_at(i)
				continue

		# 红灯：到停止线后停下排队
		if b.kind == "queue" and not b.stopped and _red_active():
			var stop_y: float = ix.wy + scroll + IX_H + 8.0 + 36.0 + b.queue_off
			if b.pos.y <= stop_y and b.pos.y > stop_y - 120.0:
				b.pos.y = stop_y
				b.stopped = true
				b.vel = Vector2.ZERO
				b.rot = 0.0
				b.said = "等灯咯"
				b.said_t = 1.2

		# 最后统一检查：不压到行人（先试只横移，不行就原地等）
		var stay := Vector2(old.x, old.y + scroll_rate * delta)
		var dy := scroll_rate * delta
		if b.pos != stay and _bike_hits_ped(b.pos, b.rot, dy) and not _bike_hits_ped(stay, b.rot, dy):
			var side := Vector2(b.pos.x, stay.y)
			b.pos = side if not _bike_hits_ped(side, b.rot, dy) else stay
			if b.kind == "weave":
				b.t -= delta
		if state == "play" and not demo:
			_check_collision(b, old)
			if b.get("launched", false):
				bikes.remove_at(i)
				continue
		if b.pos.y > H + 140.0 or b.pos.y < -200.0 or b.pos.x > W + 100.0:
			bikes.remove_at(i)


## 前方有障碍时横向绕开，返回本帧 x 方向位移
func _steer(b: Dictionary, delta: float) -> float:
	var v: Vector2 = b.vel
	if v.length() < 10.0:
		return 0.0
	var dir := v.normalized()
	var rs := []
	for o in obstacles:
		rs.append(_orect(o))
	for p in peds:
		rs.append(Rect2(p.pos - Vector2(p.r, p.r), Vector2(p.r, p.r) * 2.0))
	for r0 in rs:
		var r: Rect2 = (r0 as Rect2).grow(20.0)
		for k in [25.0, 55.0, 85.0]:
			if r.has_point(b.pos + dir * k):
				var go_left: bool = r.get_center().x > b.pos.x
				if go_left and r.position.x - PLAY_L < 40.0:
					go_left = false
				elif not go_left and PLAY_R - r.end.x < 40.0:
					go_left = true
				return (-1.0 if go_left else 1.0) * 280.0 * delta
	return 0.0


# ------------------------------------------------------------------ 行人

func _bike_seg_dist(p: Vector2, bpos: Vector2, rot: float) -> float:
	var dir := Vector2.UP.rotated(rot)
	return Geometry2D.get_closest_point_to_segment(p, bpos + dir * 22.0, bpos - dir * 22.0).distance_to(p)


## dy：行人这一帧至少会跟着画面滚动下移的距离（按移动后的位置判断，留 2px 余量）
func _bike_hits_ped(bpos: Vector2, rot: float, dy := 0.0) -> bool:
	for p in peds:
		if _bike_seg_dist(p.pos + Vector2(0, dy), bpos, rot) < p.r + 13.0:
			return true
	return false


func _new_ped(kind: String, pos: Vector2, vel: Vector2) -> Dictionary:
	return {"kind": kind, "pos": pos, "vel": vel, "r": 11.0, "phase": randf() * TAU,
		"shirt": PED_SHIRTS.pick_random(), "hair": PED_HAIR.pick_random(),
		"phone": kind == "phone", "umbrella": rain and randf() < 0.85, "umb": UMB_COLORS.pick_random(),
		"face": 0.0 if vel.y < 0.0 else PI, "said": "", "said_t": 0.0}


func _spawn_ped() -> void:
	var kind := _pick_weighted(level.get("peds", {"along": 0.35, "oncoming": 0.3, "phone": 0.15, "pair": 0.12, "stand": 0.08}))
	var x := randf_range(PLAY_L + 24.0, PLAY_R - 50.0)
	var group := []
	match kind:
		"along", "pair":  # 同向慢慢走：比玩家慢，玩家会超过去
			var v := Vector2(0, -randf_range(55.0, 85.0))
			var y := -40.0 if scroll_rate > -v.y else H + 40.0
			group.append(_new_ped("along", Vector2(x, y), v))
			if kind == "pair":
				group.append(_new_ped("along", Vector2(x + 25.0, y), v))
		"oncoming":
			group.append(_new_ped("oncoming", Vector2(x, -40.0), Vector2(0, randf_range(55.0, 85.0))))
		"phone":  # 低头族：走得慢，还会走歪
			var p := _new_ped("phone", Vector2(x, -40.0), Vector2(randf_range(-14.0, 14.0), randf_range(30.0, 45.0)))
			p.said = "低头看手机…"
			p.said_t = 2.0
			group.append(p)
		"stand":
			var p := _new_ped("stand", Vector2(x, -40.0), Vector2.ZERO)
			p.face = randf() * TAU
			group.append(p)
	var rects := _solid_rects()
	for p in group:
		if not _ped_blocked(p, p.pos, rects):
			peds.append(p)


func _ped_blocked(p: Dictionary, np: Vector2, rects: Array) -> bool:
	for r in rects:
		if _circle_hits_rect(np, p.r, r):
			return true
	for o in peds:
		if not is_same(o, p) and np.distance_to(o.pos) < p.r + o.r:
			return true
	for b in bikes:
		if _bike_seg_dist(np, b.pos, b.rot) < p.r + 11.0:
			return true
	if not ix.is_empty():
		for c in cross_cars:
			if _circle_hits_rect(np, p.r + 1.0, _cross_rect(c)):
				return true
	return false


func _update_peds(delta: float) -> void:
	ped_timer -= delta
	if ped_timer <= 0.0:
		ped_timer = randf_range(0.8, 1.7) / float(level.get("ped_rate", 1.0))
		_spawn_ped()
	var rects := _solid_rects()
	for i in range(peds.size() - 1, -1, -1):
		var p: Dictionary = peds[i]
		p.said_t = maxf(0.0, p.said_t - delta)
		var v: Vector2 = p.vel
		# 红灯：行人也在路缘等
		if not ix.is_empty() and ix.state != "green":
			var top: float = ix.wy + scroll
			var bottom := top + IX_H
			if v.y < 0.0 and p.pos.y > bottom and p.pos.y - p.r + v.y * delta < bottom + 10.0:
				v = Vector2.ZERO
			elif v.y > 0.0 and p.pos.y < top and p.pos.y + p.r + v.y * delta > top - 10.0:
				v = Vector2.ZERO
		if not ix.is_empty() and ix.state != "green":
			var bt: float = ix.wy + scroll
			if p.pos.y > bt - p.r and p.pos.y < bt + IX_H + p.r:
				v = p.vel * 2.2  # 灯变了，小跑过去
		var prev: Vector2 = p.pos
		var np: Vector2 = p.pos + (v + Vector2(0, scroll_rate)) * delta
		if np.x < PLAY_L + p.r + 2.0 or np.x > PLAY_R - p.r - 2.0:
			p.vel.x = -p.vel.x
			np.x = clampf(np.x, PLAY_L + p.r + 2.0, PLAY_R - p.r - 2.0)
		if _ped_blocked(p, np, rects):
			var stay: Vector2 = p.pos + Vector2(0, scroll_rate * delta)
			np = stay
			for dx in [1.0, -1.0]:  # 侧身绕开
				var side := Vector2(p.pos.x + dx * 70.0 * delta, stay.y)
				if side.x > PLAY_L + p.r + 2.0 and side.x < PLAY_R - p.r - 2.0 and not _ped_blocked(p, side, rects):
					np = side
					break
		p.pos = np
		var want_move: bool = v.length() > 1.0
		p.stuck_t = p.get("stuck_t", 0.0) + delta if want_move and np.distance_to(prev + Vector2(0, scroll_rate * delta)) < 0.2 else 0.0
		if p.stuck_t > 3.0:
			peds.remove_at(i)
			continue
		if v.length() > 1.0:
			p.phase += delta * v.length() / 6.0
			p.face = lerp_angle(p.face, v.angle() + PI / 2.0, clampf(delta * 8.0, 0.0, 1.0))
		# 走到玩家身上：退回原位（被玩家挡着走）
		if not demo and p.pos.distance_to(player_pos) < p.r + player_r:
			p.pos = prev
		if p.pos.y > H + 60.0 or p.pos.y < -100.0:
			peds.remove_at(i)


func _draw_ped(p: Dictionary, pos: Vector2, rot: float, scl := 1.0) -> void:
	draw_set_transform(pos + _shake_off, rot, Vector2(scl, scl))
	_ellipse(Vector2(3, 4), 12, 9, Color(0, 0, 0, 0.22))
	var s: float = sin(p.phase) * 5.0
	_ellipse(Vector2(-4, s), 3.2, 5, Color("#3b3b3b"))
	_ellipse(Vector2(4, -s), 3.2, 5, Color("#3b3b3b"))
	var skin := Color("#f0c8a0")
	draw_circle(Vector2(-12, -s * 0.5), 3.4, skin)
	draw_circle(Vector2(12, s * 0.5), 3.4, skin)
	_ellipse(Vector2.ZERO, 12, 7, p.shirt)
	draw_circle(Vector2(0, -0.5), 6, p.hair)
	if p.get("phone", false):
		draw_rect(Rect2(-3, -13, 6, 7), Color("#1e1e1e"))
		draw_rect(Rect2(-2, -12, 4, 5), Color("#8fd3ff"))
	if p.get("umbrella", false):
		var uc: Color = p.umb
		draw_circle(Vector2(0, -1), 17, Color(uc, 0.9))
		for k in 6:
			draw_line(Vector2(0, -1), Vector2(0, -1) + Vector2.UP.rotated(TAU * k / 6.0) * 17.0, uc.darkened(0.3), 1.5)
		draw_circle(Vector2(0, -1), 2.5, uc.darkened(0.5))
	draw_set_transform(_shake_off)


func _check_collision(b: Dictionary, old: Vector2) -> void:
	var d := _bike_seg_dist(player_pos, b.pos, b.rot)
	var rr := player_r + 11.0
	var touching := d < rr + 1.0
	if touching and not b.hit and not b.stopped and invincible:
		b.launched = true
		_launch_flyer(b, b.pos, (b.pos - player_pos).normalized())
		return
	if touching and not b.hit and not b.stopped:
		b.hit = true
		if invuln <= 0.0:
			_player_hit(b.pos, HIT_LINES.pick_random())
		b.vel.x += 140.0 * signf(b.pos.x - player_pos.x + 0.01)  # 撞开到旁边
	if d < rr:  # 不从玩家身上穿过去：先试只横移，不行就退回上一帧位置
		var side := Vector2(b.pos.x, old.y)
		if _bike_seg_dist(player_pos, side, b.rot) >= rr:
			b.pos = side
		else:
			b.pos = old
		return
	if b.hit or b.stopped:
		return
	if d < rr + 26.0:
		b.near = true
	elif b.near and not b.awarded and d > rr + 50.0:
		b.awarded = true
		near_misses += 1
		score += 50.0
		_popup(player_pos + Vector2(0, -40), tr(NEAR_LINES.pick_random()) + " +50", Color("#ffd23f"), 26)
		_sfx("near")


func _player_hit(src: Vector2, line: String) -> void:
	if not god:
		lives -= 1
	hits += 1
	invuln = 1.6
	shake = 1.0
	flash = 1.0
	player_vel += (player_pos - src).normalized() * 250.0
	_popup(player_pos + Vector2(0, -50), line, Color("#ff5252"), 32)
	_sfx("hit")
	if lives <= 0:
		_end(false)


func _end(win: bool) -> void:
	state = "over"
	won = win
	end_timer = 1.8
	if win:
		_popup(Vector2(W / 2.0, H / 2.0), "成功通关！", Color("#7CFC00"), 64)
		_sfx("win")
	else:
		_sfx("lose")


func _result() -> Dictionary:
	var final := int(score) + (lives * 300 if won else 0)
	return {
		"win": won, "time": minf(elapsed, LEVEL_TIME), "score": final,
		"near": near_misses, "hits": hits, "lives": lives, "mode": mode, "wait": wait_total,
		"jaywalks": jaywalks, "run_over": run_over, "launched": launched, "invincible": invincible,
	}


## 把电鸡创飞：转着圈飞向镜头再落出画面
func _launch_flyer(look: Dictionary, pos: Vector2, away: Vector2) -> void:
	if away.length() < 0.1:
		away = Vector2.UP
	away = away.normalized().rotated(randf_range(-0.5, 0.5))
	flyers.append({"look": look, "pos": pos, "vel": away * randf_range(520.0, 760.0) + Vector2(0, -180),
		"rot": look.get("rot", 0.0), "spin": randf_range(9.0, 15.0) * (1.0 if randf() < 0.5 else -1.0), "t": 0.0})
	launched += 1
	combo = combo + 1 if combo_t > 0.0 else 1
	combo_t = 1.6
	score += 100.0
	shake = maxf(shake, 0.45)
	var line: String = tr(LAUNCH_LINES.pick_random()) + " +100"
	if combo >= 2:
		line = tr("%d 连创飞！+100") % combo
	_popup(pos + Vector2(0, -40), line, Color("#ffd23f"), 28 + mini(combo, 6) * 2)
	_sfx("boing")


func _update_flyers(delta: float) -> void:
	combo_t = maxf(0.0, combo_t - delta)
	for i in range(flyers.size() - 1, -1, -1):
		var f: Dictionary = flyers[i]
		f.t += delta
		f.pos += f.vel * delta
		f.vel *= 0.985
		f.rot += f.spin * delta
		if f.t > 1.3:
			flyers.remove_at(i)


func _draw_flyers() -> void:
	for f in flyers:
		var k: float = f.t / 1.3
		var scl := 1.0 + sin(k * PI) * 1.4  # 先飞向镜头变大，再落下
		var look: Dictionary = f.look
		look.rot = f.rot
		_draw_ebike(look, f.pos, true, scl)
	draw_set_transform(_shake_off)


func _popup(pos: Vector2, text: String, col: Color, size: int) -> void:
	popups.append({"pos": pos, "text": text, "col": col, "size": size, "t": 1.0})


func _update_popups(delta: float) -> void:
	for i in range(popups.size() - 1, -1, -1):
		var p: Dictionary = popups[i]
		p.t -= delta
		p.pos.y -= 40.0 * delta
		if p.t <= 0.0:
			popups.remove_at(i)


# ------------------------------------------------------------------ 地面障碍

## 障碍物字典：type, x, wy(世界坐标顶边), w, h, 以及各类型的外观数据
func _orect(o: Dictionary) -> Rect2:
	return Rect2(o.x, o.wy + scroll, o.w, o.h)


func _oworld(o: Dictionary) -> Rect2:
	return Rect2(o.x, o.wy, o.w, o.h)


func _solid_rects() -> Array:
	var out := []
	for o in obstacles:
		out.append(_orect(o))
	for b in bikes:
		if b.stopped:
			out.append(Rect2(b.pos - Vector2(11, 33), Vector2(22, 66)))
	return out


func _gen_obstacles() -> void:
	while next_gen_wy > -scroll - 320.0:
		var used := _place_group(next_gen_wy)
		next_gen_wy -= used + randf_range(180.0, 380.0) / level.get("obstacle_rate", 1.0)


func _cull_obstacles() -> void:
	for i in range(obstacles.size() - 1, -1, -1):
		if obstacles[i].wy + scroll > H + 60.0:
			obstacles.remove_at(i)


func _bollard(x: float, wy: float) -> Dictionary:
	return {"type": "bollard", "x": x, "wy": wy, "w": 26.0, "h": 26.0}


func _shared_row(n: int, x: float, wy: float) -> Dictionary:
	var brand: Color = SHARED_COLORS.pick_random()
	var list := []
	for i in n:
		list.append({"dx": 16.0 + i * 22.0, "rot": randf_range(-0.22, 0.22),
			"col": brand if randf() < 0.75 else SHARED_COLORS.pick_random()})
	return {"type": "shared", "x": x, "wy": wy, "w": 32.0 + (n - 1) * 22.0, "h": 64.0, "bikes": list}


func _parked_row(n: int, x: float, wy: float) -> Dictionary:
	var list := []
	for i in n:
		var b := _make_look()
		b.dx = 21.0 + i * 38.0
		b.rot = (PI if randf() < 0.5 else 0.0) + randf_range(-0.2, 0.2)
		list.append(b)
	return {"type": "parked", "x": x, "wy": wy, "w": n * 38.0 + 4.0, "h": 78.0, "bikes": list}


func _park_bike(b: Dictionary) -> void:
	b.rot = 0.0 if absf(angle_difference(b.rot, 0.0)) < PI / 2.0 else PI
	obstacles.append({"type": "stopped", "x": b.pos.x - 15.0, "wy": b.pos.y - 36.0 - scroll,
		"w": 30.0, "h": 72.0, "bike": b})
	_popup(b.pos + Vector2(0, -50), b.said, Color.WHITE, 20)


func _stall(x: float, wy: float) -> Dictionary:
	var names: Array = level.get("stall_names", ["小吃"])
	return {"type": "stall", "x": x, "wy": wy, "w": 92.0, "h": 72.0,
		"name": names.pick_random(), "col": STALL_COLORS.pick_random()}


func _pick_weighted(weights: Dictionary) -> String:
	var total := 0.0
	for k in weights:
		total += float(weights[k])
	var r := randf() * total
	for k in weights:
		r -= float(weights[k])
		if r <= 0.0:
			return k
	return weights.keys()[0]


## 在世界坐标 bottom 之上放一组障碍，返回占用的高度
func _place_group(bottom: float) -> float:
	var group := []
	var used := 60.0
	var kind := _pick_weighted(level.get("obs", {"metro": 0.2, "shared": 0.25, "parked": 0.3, "bollard": 0.25}))
	if kind == "metro" and bottom >= last_metro_wy - float(level.get("metro_gap", 1400.0)):
		kind = "shared"
	match kind:
		"metro":
			# 地铁口：一列石墩 + 门口一排共享单车
			last_metro_wy = bottom
			var left := randf() < 0.5
			var mx := PLAY_L if left else PLAY_R - 170.0
			group.append({"type": "metro", "x": mx, "wy": bottom - 210.0, "w": 170.0, "h": 210.0, "left": left})
			var bx := PLAY_L + 230.0 if left else PLAY_R - 256.0
			for i in 3:
				group.append(_bollard(bx, bottom - 190.0 + i * 75.0))
			var n := randi_range(6, 9)
			var w := 32.0 + (n - 1) * 22.0
			group.append(_shared_row(n, PLAY_L + 4.0 if left else PLAY_R - w - 4.0, bottom - 300.0))
			used = 320.0
		"shared":
			var n := randi_range(4, 10)
			var w := 32.0 + (n - 1) * 22.0
			var s := randf()
			var x := PLAY_L + 4.0
			if s > 0.84:
				x = randf_range(PLAY_L + 120.0, PLAY_R - 120.0 - w)
			elif s > 0.42:
				x = PLAY_R - w - 4.0
			group.append(_shared_row(n, x, bottom - 64.0))
			used = 80.0
		"parked":
			var n := randi_range(1, 3)
			var w := n * 38.0 + 4.0
			group.append(_parked_row(n, PLAY_L + 4.0 if randf() < 0.6 else PLAY_R - w - 4.0, bottom - 78.0))
			used = 90.0
		"stall":
			group.append(_stall(PLAY_L + 6.0 if randf() < 0.65 else PLAY_R - 98.0, bottom - 72.0))
			used = 90.0
		_:
			var n := randi_range(4, 6)
			var x0 := randf_range(PLAY_L + 20.0, PLAY_R - 46.0 - (n - 1) * 80.0)
			for i in n:
				group.append(_bollard(x0 + i * 80.0, bottom - 26.0))
			used = 40.0
	if not ix.is_empty():
		var band := Rect2(PLAY_L - 10.0, ix.wy - 60.0, PLAY_R - PLAY_L + 20.0, IX_H + 120.0)
		for o in group:
			if _oworld(o).intersects(band):
				return used
	obstacles.append_array(group)
	return used


# ------------------------------------------------------------------ 主路车辆

func _spawn_car(y := -999.0) -> void:
	var up := randf() < 0.5
	var c := {"col": CAR_COLORS.pick_random(), "up": up}
	if up:  # 同向车道：比行人快，屏幕上向上开
		c.pos = Vector2(1107.0, H + 70.0 if y < -500.0 else y)
		c.vel = -randf_range(150.0, 380.0)
	else:
		c.pos = Vector2(1222.0, -70.0 if y < -500.0 else y)
		c.vel = randf_range(250.0, 450.0)
		# 红灯时不能直接生成在路口里，放到停止线后面排队
		if _red_active() and c.pos.y + 44.0 > ix.wy + scroll - 2.0 and c.pos.y - 44.0 < ix.wy + scroll + IX_H:
			c.pos.y = ix.wy + scroll - 52.0
	for o in cars:
		if o.up == up and absf(o.pos.y - c.pos.y) < 110.0:
			return
	cars.append(c)


func _update_cars(delta: float) -> void:
	car_timer -= delta
	if car_timer <= 0.0:
		car_timer = randf_range(0.5, 1.4)
		_spawn_car()
	var red := _red_active()
	if not red and not ix.is_empty():
		for cc in cross_cars:
			if cc.x > PLAY_R and cc.x < W + 60.0:
				red = true
	var top: float = ix.wy + scroll if red else 0.0
	for i in range(cars.size() - 1, -1, -1):
		var c: Dictionary = cars[i]
		var ny: float = c.pos.y + (c.vel + scroll_rate) * delta
		if red:  # 行人红灯 = 主路也红灯，停在路口外
			if c.up and c.pos.y - 44.0 >= top + IX_H - 2.0:
				ny = maxf(ny, top + IX_H + 52.0)
			elif not c.up and c.pos.y + 44.0 <= top + 2.0:
				ny = minf(ny, top - 52.0)
		for o in cars:
			if is_same(o, c) or o.up != c.up:
				continue
			if c.up and o.pos.y < c.pos.y:
				ny = maxf(ny, o.pos.y + 100.0)
			elif not c.up and o.pos.y > c.pos.y:
				ny = minf(ny, o.pos.y - 100.0)
		c.pos.y = ny
		if c.pos.y < -120.0 or c.pos.y > H + 120.0:
			cars.remove_at(i)


# ------------------------------------------------------------------ 绘制

func _draw() -> void:
	_shake_off = Vector2(randf_range(-1, 1), randf_range(-1, 1)) * shake * 10.0
	draw_set_transform(_shake_off)
	_draw_background()
	_draw_intersection()
	for o in obstacles:
		_draw_obstacle(o)
	for c in cars:
		_draw_car(c.pos, 0.0 if c.up else PI, c.col)
	if not ix.is_empty():
		for c in cross_cars:
			var p := Vector2(c.x, ix.wy + scroll + c.lane_y)
			var rot := PI / 2.0 if c.dir > 0.0 else -PI / 2.0
			if c.bike.is_empty():
				_draw_car(p, rot, c.col)
			else:
				c.bike.rot = rot
				_draw_ebike(c.bike, p)
	for b in bikes:
		_draw_ebike(b, b.pos)
	for p in peds:
		_draw_ped(p, p.pos, p.face)
	if not demo:
		_draw_player()
	_draw_flyers()
	_draw_canopies()
	if rain:
		_draw_rain()
	if night:
		_draw_night()
	_draw_lights()
	draw_set_transform(_shake_off)
	for b in bikes:
		if b.said_t > 0.0:
			_text(b.pos + Vector2(0, -46), b.said, 20, Color.WHITE)
	for p in peds:
		if p.said_t > 0.0:
			_text(p.pos + Vector2(0, -24), p.said, 16, Color("#e0f7fa"))
	for p in popups:
		var col: Color = p.col
		col.a = clampf(p.t * 2.0, 0.0, 1.0)
		_text(p.pos, p.text, p.size, col)
	draw_set_transform(Vector2.ZERO)
	if not demo:
		_draw_warnings()
		_draw_hud()


func _draw_background() -> void:
	draw_rect(Rect2(0, 0, W, H), Color("#3d3f42"))

	# 左侧：骑楼（广州）/ 玻璃幕墙（深圳）/ 握手楼（城中村）
	var style: String = level.get("style", "qilou")
	var sx := PLAY_L - 50.0  # 店铺区右边界
	var bh := 240.0
	for k in range(floori(scroll / bh) - 1, ceili((scroll + H) / bh) + 2):
		var sy := scroll - k * bh + H - bh
		var col: Color = block_colors[posmod(k * 7, block_colors.size())]
		draw_rect(Rect2(0, sy, sx, bh - 6), col)
		if sx > 230.0:  # 店铺纵深：货架
			draw_rect(Rect2(150, sy + 16, sx - 200, bh - 40), col.darkened(0.25))
			for gy in range(0, 4):
				draw_line(Vector2(150, sy + 50 + gy * 45), Vector2(sx - 50, sy + 50 + gy * 45), col.darkened(0.4), 3.0)
		match style:
			"modern":
				for mx in range(0, int(sx), 40):
					draw_line(Vector2(mx, sy), Vector2(mx, sy + bh - 6), col.lightened(0.2), 2.0)
				draw_rect(Rect2(20, sy + 110, 116, 90), Color("#2a3a4a"))  # LED 屏
				var sc: Color = sign_colors[posmod(k * 5, sign_colors.size())]
				for ly in range(0, 4):
					draw_rect(Rect2(28, sy + 118 + ly * 20, 100 - ly * 18, 8), sc.lightened(0.2 * ly))
				draw_rect(Rect2(sx - 40, sy + 10, 40, bh - 26), Color("#5f6f7f"))  # 雨棚
			"village":
				for wy2 in range(0, 2):  # 窗户 + 空调外机
					draw_rect(Rect2(24, sy + 110 + wy2 * 56, 50, 40), Color("#4e5b66"))
					draw_rect(Rect2(86, sy + 114 + wy2 * 56, 34, 26), Color("#d6d6d6"))
					draw_circle(Vector2(103, sy + 127 + wy2 * 56), 9, Color("#9e9e9e"))
				draw_rect(Rect2(sx - 30, sy + 4, 30, bh - 14), col.darkened(0.15))
				draw_line(Vector2(0, sy + 96), Vector2(sx, sy + 102), Color("#333333"), 2.0)  # 电线
			_:
				draw_rect(Rect2(sx - 50, sy + 10, 50, bh - 26), col.lightened(0.25))  # 骑楼柱廊
				draw_rect(Rect2(sx - 14, sy + bh - 30, 14, 24), col.darkened(0.3))   # 柱子
				draw_rect(Rect2(20, sy + 110, 116, 90), Color("#5d7385"))  # 橱窗
				draw_rect(Rect2(20, sy + 110, 116, 90), col.darkened(0.4), false, 3.0)
		_draw_sign(k, sy)

	# 台阶
	draw_rect(Rect2(sx, 0, 50, H), Color("#8e8a85"))
	for k in range(floori(scroll / 30.0), ceili((scroll + H) / 30.0) + 1):
		var sy := scroll - k * 30.0 + H
		draw_line(Vector2(sx, sy), Vector2(PLAY_L, sy), Color("#7a7671"), 2.0)

	# 人行道地砖
	var sw: Color = Color(level.get("sidewalk", "#cdb9a0"))
	var tile: float = 60.0 if style == "modern" else 50.0
	draw_rect(Rect2(PLAY_L, 0, PLAY_R - PLAY_L, H), sw)
	var line_col := sw.darkened(0.12)
	for k in range(floori(scroll / tile), ceili((scroll + H) / tile) + 1):
		var sy := scroll - k * tile + H
		draw_line(Vector2(PLAY_L, sy), Vector2(PLAY_R, sy), line_col, 2.0)
	var gx := PLAY_L
	while gx < PLAY_R:
		draw_line(Vector2(gx, 0), Vector2(gx, H), line_col, 2.0)
		gx += tile

	# 盲道
	var bp := PLAY_L + 50.0
	draw_rect(Rect2(bp, 0, 32, H), Color("#e8c547"))
	for k in range(floori(scroll / 16.0), ceili((scroll + H) / 16.0) + 1):
		var sy := scroll - k * 16.0 + H
		draw_line(Vector2(bp + 4, sy), Vector2(bp + 28, sy), Color("#c9a72c"), 3.0)

	# 井盖
	for k in range(floori(scroll / 520.0) - 1, ceili((scroll + H) / 520.0) + 1):
		var sy := scroll - k * 520.0 + H
		var x := PLAY_L + 230.0 + posmod(k * 197, int(PLAY_R - PLAY_L - 300.0))
		draw_circle(Vector2(x, sy), 20, Color("#6b6560"))
		draw_arc(Vector2(x, sy), 15, 0, TAU, 20, Color("#58524d"), 2.0)
	if rain:  # 积水
		for k in range(floori(scroll / 330.0) - 1, ceili((scroll + H) / 330.0) + 1):
			var sy := scroll - k * 330.0 + H
			var x := PLAY_L + 120.0 + posmod(k * 263, int(PLAY_R - PLAY_L - 220.0))
			_ellipse(Vector2(x, sy), 60, 22, Color(0.35, 0.42, 0.5, 0.45))
			_ellipse(Vector2(x - 12, sy - 6), 22, 6, Color(1, 1, 1, 0.18))

	# 绿化带 + 路缘 + 栏杆
	draw_rect(Rect2(PLAY_R, 0, 45, H), Color("#5b7a3a"))
	for k in range(floori(scroll / 210.0) - 1, ceili((scroll + H) / 210.0) + 1):
		var sy := scroll - k * 210.0 + H
		draw_circle(Vector2(PLAY_R + 22, sy), 7, Color("#5a3d22"))
	draw_rect(Rect2(PLAY_R + 45, 0, 8, H), Color("#d5d5d5"))
	draw_line(Vector2(PLAY_R + 49, 0), Vector2(PLAY_R + 49, H), Color("#e0e0e0"), 3.0)

	# 机动车道
	draw_rect(Rect2(PLAY_R + 53, 0, W - PLAY_R - 53, H), Color("#45474a"))
	draw_line(Vector2(1061, 0), Vector2(1061, H), Color("#f0f0f0"), 3.0)
	draw_line(Vector2(1162, 0), Vector2(1162, H), Color("#f2c230"), 3.0)
	draw_line(Vector2(1168, 0), Vector2(1168, H), Color("#f2c230"), 3.0)
	for k in range(floori(scroll / 260.0) - 1, ceili((scroll + H) / 260.0) + 1):
		var sy := scroll - k * 260.0 + H
		draw_circle(Vector2(1110.0 + posmod(k, 2) * 110.0, sy), 13, Color("#3a3c3f"))


func _draw_sign(k: int, sy: float, glow := false) -> void:
	var shops: Array = level.get("shops", ["便利店"])
	var style: String = level.get("style", "qilou")
	var sc: Color = sign_colors[posmod(k * 5, sign_colors.size())]
	var name: String = shops[posmod(k, shops.size())]
	if glow:  # 夜间光晕
		draw_rect(Rect2(4, sy + 20, 148, 76), Color(sc, 0.25))
	match style:
		"modern":
			draw_rect(Rect2(10, sy + 26, 136, 62), sc.darkened(0.6))
			draw_rect(Rect2(14, sy + 30, 128, 54), Color(0.05, 0.05, 0.1))
			draw_rect(Rect2(14, sy + 30, 128, 54), sc, false, 3.0)
			_text_plain(Vector2(14, sy + 67), name, 24, sc.lightened(0.4), 128, HORIZONTAL_ALIGNMENT_CENTER)
		"village":  # 灯箱
			draw_rect(Rect2(14, sy + 30, 128, 54), sc)
			draw_rect(Rect2(18, sy + 34, 120, 46), sc.lightened(0.15))
			_text_plain(Vector2(14, sy + 67), name, 24, Color("#fff59d"), 128, HORIZONTAL_ALIGNMENT_CENTER)
		_:
			draw_rect(Rect2(14, sy + 30, 128, 56), sc)
			draw_rect(Rect2(14, sy + 30, 128, 56), Color.WHITE, false, 2.0)
			_text_plain(Vector2(14, sy + 68), name, 26, Color("#fff8dc"), 128, HORIZONTAL_ALIGNMENT_CENTER)


func _draw_intersection() -> void:
	if ix.is_empty():
		return
	var top: float = ix.wy + scroll
	if top > H + 10.0 or top + IX_H < -10.0:
		return
	draw_rect(Rect2(0, top, W, IX_H), Color("#424448"))
	draw_rect(Rect2(0, top - 8, PLAY_R + 53, 8), Color("#d5d5d5"))
	draw_rect(Rect2(0, top + IX_H, PLAY_R + 53, 8), Color("#d5d5d5"))
	# 斑马线
	var x := PLAY_L + 30.0
	while x < PLAY_R - 40.0:
		draw_rect(Rect2(x, top + 28, 26, IX_H - 56), Color("#e9e9e9"))
		x += 52.0
	# 横街停止线、中线、路名
	draw_line(Vector2(PLAY_L + 12, top + IX_H / 2.0 + 6), Vector2(PLAY_L + 12, top + IX_H - 6), Color.WHITE, 4.0)
	draw_line(Vector2(PLAY_R - 12, top + 6), Vector2(PLAY_R - 12, top + IX_H / 2.0 - 6), Color.WHITE, 4.0)
	var dx := 0.0
	while dx < PLAY_L - 20.0:
		draw_line(Vector2(dx, top + IX_H / 2.0), Vector2(dx + 30, top + IX_H / 2.0), Color("#f2c230"), 3.0)
		dx += 55.0
	_text_plain(Vector2(14, top + IX_H / 2.0 - 14), ix.name, 24, Color(1, 1, 1, 0.55))


func _draw_lights() -> void:
	if ix.is_empty():
		return
	var top: float = ix.wy + scroll
	if top > H + 80.0 or top < -20.0:
		return
	draw_set_transform(_shake_off)
	var red: bool = ix.state != "green"
	for lx in [PLAY_L + 14.0, PLAY_R - 50.0]:
		draw_rect(Rect2(lx + 15, top - 30, 6, 26), Color("#555555"))
		draw_rect(Rect2(lx, top - 92, 36, 64), Color("#1b1b1b"))
		draw_circle(Vector2(lx + 18, top - 76), 11, Color("#ff3b30") if red else Color("#3a1414"))
		draw_circle(Vector2(lx + 18, top - 46), 11, Color("#3ddc84") if not red else Color("#123020"))
		if ix.state == "red":
			_text(Vector2(lx + 18, top - 98), str(ceili(ix.red_t)), 20, Color("#ff6b6b"))


func _draw_rain() -> void:
	draw_set_transform(Vector2.ZERO)
	draw_rect(Rect2(0, 0, W, H), Color(0.2, 0.3, 0.45, 0.14))
	var t := Time.get_ticks_msec() / 1000.0
	for i in 110:
		var x := fposmod(i * 137.0 + t * 80.0, W)
		var y := fposmod(i * 91.0 + t * 950.0, H)
		draw_line(Vector2(x, y), Vector2(x - 5, y + 20), Color(0.85, 0.9, 1.0, 0.35), 1.5)


func _headlight(pos: Vector2, rot: float, length: float, alpha: float) -> void:
	var d := Vector2.UP.rotated(rot)
	var side := Vector2(-d.y, d.x)
	var p0 := pos + d * 30.0
	draw_colored_polygon(PackedVector2Array([p0 + side * 6.0, p0 - side * 6.0,
		p0 + d * length - side * length * 0.38, p0 + d * length + side * length * 0.38]), Color(1.0, 0.95, 0.7, alpha))


func _draw_night() -> void:
	draw_set_transform(Vector2.ZERO)
	draw_rect(Rect2(0, 0, W, H), Color(0.02, 0.03, 0.1, 0.58))
	draw_set_transform(_shake_off)
	# 路灯
	for k in range(floori(scroll / 210.0) - 1, ceili((scroll + H) / 210.0) + 1):
		var sy := scroll - k * 210.0 + H - 105.0
		draw_circle(Vector2(PLAY_R - 20, sy), 120, Color(1.0, 0.85, 0.5, 0.07))
		draw_circle(Vector2(PLAY_R - 20, sy), 60, Color(1.0, 0.85, 0.5, 0.08))
		draw_circle(Vector2(PLAY_R + 24, sy), 6, Color("#fff3c4"))
	# 招牌发光
	var bh := 240.0
	for k in range(floori(scroll / bh) - 1, ceili((scroll + H) / bh) + 2):
		_draw_sign(k, scroll - k * bh + H - bh, true)
	# 摊位灯泡
	for o in obstacles:
		if o.type == "stall":
			var c := _orect(o).get_center()
			draw_circle(c, 70, Color(1.0, 0.8, 0.4, 0.12))
	# 车灯
	for b in bikes:
		_headlight(b.pos, b.rot, 150.0, 0.16)
	for c in cars:
		_headlight(c.pos + Vector2(0, -14 if c.up else 14), 0.0 if c.up else PI, 190.0, 0.13)
	if not ix.is_empty():
		for c in cross_cars:
			_headlight(Vector2(c.x, ix.wy + scroll + c.lane_y), PI / 2.0 if c.dir > 0.0 else -PI / 2.0, 170.0, 0.13)
	if not demo:
		draw_circle(player_pos, 46, Color(1, 1, 1, 0.07))


func _draw_canopies() -> void:
	draw_set_transform(_shake_off)
	var band_top: float = ix.wy + scroll if not ix.is_empty() else -9999.0
	for k in range(floori(scroll / 210.0) - 1, ceili((scroll + H) / 210.0) + 1):
		var sy := scroll - k * 210.0 + H
		if sy > band_top - 40.0 and sy < band_top + IX_H + 40.0:
			continue
		var c := Vector2(PLAY_R + 22, sy)
		draw_circle(c + Vector2(6, 8), 44, Color(0, 0, 0, 0.18))
		draw_circle(c, 42, Color("#3f6b2a", 0.93))
		draw_circle(c + Vector2(-12, -10), 22, Color("#4f8a34", 0.9))
		draw_circle(c + Vector2(14, 6), 18, Color("#4a7f31", 0.9))


func _ellipse(c: Vector2, rx: float, ry: float, col: Color) -> void:
	var pts := PackedVector2Array()
	for i in 18:
		var a := TAU * i / 18.0
		pts.append(c + Vector2(cos(a) * rx, sin(a) * ry))
	draw_colored_polygon(pts, col)


func _draw_car(pos: Vector2, rot: float, col: Color) -> void:
	draw_set_transform(pos + _shake_off, rot)
	draw_rect(Rect2(-20, -40, 46, 88), Color(0, 0, 0, 0.25))
	draw_rect(Rect2(-23, -44, 46, 88), col)
	draw_rect(Rect2(-19, -26, 38, 14), Color("#26384a"))
	draw_rect(Rect2(-19, 26, 38, 10), Color("#26384a"))
	draw_rect(Rect2(-18, -12, 36, 38), col.lightened(0.15))
	draw_rect(Rect2(-21, -44, 9, 4), Color("#fff6c0"))
	draw_rect(Rect2(12, -44, 9, 4), Color("#fff6c0"))
	draw_rect(Rect2(-21, 41, 9, 3), Color("#e74c3c"))
	draw_rect(Rect2(12, 41, 9, 3), Color("#e74c3c"))


func _draw_ebike(b: Dictionary, pos: Vector2, rider := true, scl := 1.0) -> void:
	draw_set_transform(pos + _shake_off, b.rot, Vector2(scl, scl))
	_ellipse(Vector2(5, 7), 17, 36, Color(0, 0, 0, 0.25))
	draw_rect(Rect2(-4, -36, 8, 17), Color("#111111"))
	draw_rect(Rect2(-4, 19, 8, 17), Color("#111111"))
	_ellipse(Vector2.ZERO, 11, 27, b.body)
	draw_rect(Rect2(-17, -25, 34, 4), Color("#222222"))
	if rider:
		draw_circle(Vector2(0, -36), 3.5, Color("#fff3b0"))
	if b.get("braking", false) or b.get("stopped", false) or not rider:
		draw_rect(Rect2(-6, 33, 12, 4), Color("#ff3030") if rider else Color("#7a2020"))
	if b.cargo:  # 拉货：叠起来的纸箱
		draw_rect(Rect2(-18, 0, 36, 36), Color("#b5835a"))
		draw_rect(Rect2(-18, 0, 36, 36), Color("#8a5f3c"), false, 2.0)
		draw_line(Vector2(-18, 18), Vector2(18, 18), Color("#8a5f3c"), 2.0)
		draw_line(Vector2(0, 0), Vector2(0, 36), Color("#d9c27a"), 3.0)
	elif b.has_box:
		draw_rect(Rect2(-15, 8, 30, 27), b.box)
		draw_rect(Rect2(-15, 18, 30, 4), (b.box as Color).darkened(0.35))
	if b.quilt:  # 挡风被
		draw_rect(Rect2(-18, -31, 36, 16), b.quilt_color)
	if not rider:
		_ellipse(Vector2(0, -2), 8, 12, (b.body as Color).darkened(0.3))  # 座垫
		return
	_ellipse(Vector2(0, -3), 15, 9, b.shirt)
	draw_line(Vector2(-12, -6), Vector2(-15, -22), b.shirt, 5.0)
	draw_line(Vector2(12, -6), Vector2(15, -22), b.shirt, 5.0)
	var poncho: Color = b.get("poncho", Color(0, 0, 0, 0))
	if poncho.a > 0.0:  # 雨披把人和车头都罩住
		_ellipse(Vector2(0, -8), 21, 30, poncho)
	draw_circle(Vector2(0, -5), 8.5, b.helmet)
	draw_circle(Vector2(0, -9), 3.0, (b.helmet as Color).lightened(0.5))


func _draw_shared_bike(col: Color) -> void:
	draw_rect(Rect2(-2, -29, 4, 18), Color("#1a1a1a"))
	draw_rect(Rect2(-2, 11, 4, 18), Color("#1a1a1a"))
	draw_line(Vector2(0, -18), Vector2(0, 16), col, 4.0)
	draw_line(Vector2(-10, -19), Vector2(10, -19), Color("#333333"), 3.0)
	draw_rect(Rect2(-6, -31, 12, 8), col.darkened(0.25))
	_ellipse(Vector2(0, 7), 3.5, 6, Color("#222222"))


func _draw_obstacle(o: Dictionary) -> void:
	var r := _orect(o)
	if r.position.y > H + 10.0 or r.end.y < -10.0:
		return
	match o.type:
		"bollard":
			draw_set_transform(_shake_off)
			var c := r.get_center()
			draw_circle(c + Vector2(4, 5), 13, Color(0, 0, 0, 0.25))
			draw_circle(c, 13, Color("#a8a8a8"))
			draw_circle(c + Vector2(-3, -3), 6, Color("#c8c8c8"))
		"shared":
			for sb in o.bikes:
				draw_set_transform(r.position + Vector2(sb.dx, r.size.y / 2.0) + _shake_off, sb.rot)
				_draw_shared_bike(sb.col)
		"parked":
			for pb in o.bikes:
				_draw_ebike(pb, r.position + Vector2(pb.dx, r.size.y / 2.0), false)
		"stopped":
			_draw_ebike(o.bike, r.get_center())
		"metro":
			_draw_metro(r, o.left)
		"stall":
			draw_set_transform(_shake_off)
			draw_rect(Rect2(r.position + Vector2(6, 8), r.size), Color(0, 0, 0, 0.25))
			draw_rect(r, Color("#8d6e63"))
			draw_rect(Rect2(r.position.x + 6, r.position.y + 6, r.size.x - 12, 20), Color("#cfd8dc"))
			var c := r.get_center() + Vector2(0, -8)
			for i in 8:  # 太阳伞
				var a0 := TAU * i / 8.0
				var a1 := TAU * (i + 1) / 8.0
				var pts := PackedVector2Array([c])
				for j in 5:
					var a := lerpf(a0, a1, j / 4.0)
					pts.append(c + Vector2(cos(a), sin(a)) * 40.0)
				draw_colored_polygon(pts, o.col if i % 2 == 0 else Color("#f5f5f5"))
			draw_circle(c, 4, Color("#555555"))
			_text(Vector2(c.x, r.end.y + 4), o.name, 18, Color("#fff59d"))


func _draw_metro(r: Rect2, left: bool) -> void:
	draw_set_transform(_shake_off)
	var mc := Color(level.get("metro_color", "#c8102e"))
	draw_rect(Rect2(r.position + Vector2(8, 10), r.size), Color(0, 0, 0, 0.3))
	draw_rect(r, Color("#cfd8dc"))
	draw_rect(r.grow(-10), Color("#90a4ae"))
	# 出入口朝人行道中间开口，里面是楼梯
	var door := Rect2(r.end.x - 60, r.position.y + 30, 60, r.size.y - 60) if left \
		else Rect2(r.position.x, r.position.y + 30, 60, r.size.y - 60)
	draw_rect(door, Color("#37474f"))
	var sx := door.position.x + 6
	while sx < door.end.x - 4:
		draw_line(Vector2(sx, door.position.y + 4), Vector2(sx, door.end.y - 4), Color("#546e7a"), 3.0)
		sx += 10
	draw_rect(Rect2(r.position.x, r.position.y, r.size.x, 16), mc)
	draw_rect(Rect2(r.position.x, r.end.y - 16, r.size.x, 16), mc)
	var lc := Vector2(r.position.x + (55.0 if left else r.size.x - 55.0), r.position.y + 70)
	draw_circle(lc, 30, mc)
	_text(lc + Vector2(0, 9), "地铁", 22, Color.WHITE)
	_text(lc + Vector2(0, 66), "Metro", 18, Color("#263238"))
	_text(lc + Vector2(0, 92), level.get("metro_name", ""), 16, Color("#263238"))


func _draw_player() -> void:
	if invuln > 0.0 and fmod(invuln, 0.2) < 0.1:
		return
	draw_set_transform(player_pos + _shake_off, lean)
	var shirt := Color("#2f80ed")
	var hair := Color("#2c1e14")
	var skin := Color("#f0c8a0")
	if mode == "walk":
		_ellipse(Vector2(4, 6), 16, 13, Color(0, 0, 0, 0.25))
		var s := sin(walk_phase) * 8.0
		_ellipse(Vector2(-6, s), 4.5, 7, Color("#f5f5f5"))
		_ellipse(Vector2(6, -s), 4.5, 7, Color("#f5f5f5"))
		draw_circle(Vector2(-16, -s * 0.6), 4.5, skin)
		draw_circle(Vector2(16, s * 0.6), 4.5, skin)
		_ellipse(Vector2.ZERO, 15, 9, shirt)
		draw_circle(Vector2(0, -1), 8.5, hair)
	else:
		_ellipse(Vector2(4, 6), 14, 34, Color(0, 0, 0, 0.25))
		draw_rect(Rect2(-2.5, -34, 5, 22), Color("#111111"))
		draw_rect(Rect2(-2.5, 12, 5, 22), Color("#111111"))
		draw_line(Vector2(0, -22), Vector2(0, 18), Color("#16a085"), 4.0)
		draw_line(Vector2(-15, -20), Vector2(15, -20), Color("#222222"), 3.0)
		var s := sin(walk_phase * 0.8) * 5.0
		_ellipse(Vector2(-6, 6 + s), 4, 6, Color("#f5f5f5"))
		_ellipse(Vector2(6, 6 - s), 4, 6, Color("#f5f5f5"))
		_ellipse(Vector2(0, -2), 14, 8, shirt)
		draw_line(Vector2(-11, -4), Vector2(-14, -19), shirt, 4.5)
		draw_line(Vector2(11, -4), Vector2(14, -19), shirt, 4.5)
		draw_circle(Vector2(0, -1), 8, hair)
	draw_set_transform(_shake_off)
	_text(player_pos + Vector2(0, 46), "你", 16, Color(1, 1, 1, 0.85))


func _draw_warnings() -> void:
	for w in warnings:
		var blink: bool = fmod(w.t, 0.2) < 0.12
		var col := Color("#ff3b30") if blink else Color("#ffcc00")
		if w.kind == "cross":
			var y: float = w.pos.y
			draw_colored_polygon(PackedVector2Array([Vector2(PLAY_L + 40, y), Vector2(PLAY_L + 6, y - 20), Vector2(PLAY_L + 6, y + 20)]), col)
			_text(Vector2(PLAY_L + 100, y - 26), "店门口冲出！", 20, col)
		else:
			var x: float = w.pos.x
			draw_colored_polygon(PackedVector2Array([Vector2(x, H - 58), Vector2(x - 20, H - 24), Vector2(x + 20, H - 24)]), col)
			_text(Vector2(x, H - 64), "后方来车！嘀嘀！", 20, col)


func _heart(c: Vector2, s: float, col: Color) -> void:
	draw_circle(c + Vector2(-s * 0.5, 0), s * 0.56, col)
	draw_circle(c + Vector2(s * 0.5, 0), s * 0.56, col)
	draw_colored_polygon(PackedVector2Array([c + Vector2(-s * 1.04, s * 0.18), c + Vector2(s * 1.04, s * 0.18), c + Vector2(0, s * 1.3)]), col)


func _draw_hud() -> void:
	draw_rect(Rect2(0, 0, W, 64), Color(0, 0, 0, 0.55))
	_text_plain(Vector2(20, 30), "%s · %s" % [tr(level.get("city", "")), tr(level.get("name", ""))], 24, Color.WHITE, 440)
	var tags := tr("步行模式") if mode == "walk" else tr("骑车模式")
	if rain:
		tags += " · " + tr("暴雨")
	if night:
		tags += " · " + tr("夜间")
	if invincible:
		tags += " · " + tr("无敌（已创飞 %d）") % launched
	_text_plain(Vector2(20, 54), _hud_line(tags, tr("ESC 暂停")), 16, Color("#ffd23f") if invincible else Color("#bbbbbb"), 440)

	var tl := maxf(0.0, LEVEL_TIME - elapsed)
	var tcol := Color("#ff6b6b") if tl < 10.0 else Color.WHITE
	_text(Vector2(W / 2.0, 38), "00:%02d" % ceili(tl), 34, tcol)
	draw_rect(Rect2(W / 2.0 - 150, 48, 300, 8), Color(1, 1, 1, 0.2))
	draw_rect(Rect2(W / 2.0 - 150, 48, 300 * (elapsed / LEVEL_TIME), 8), Color("#7CFC00"))

	for i in MAX_LIVES:
		_heart(Vector2(W - 150 + i * 44, 22), 13, Color("#ff4757") if i < lives else Color(1, 1, 1, 0.25))
	_text_plain(Vector2(W - 172, 58), tr("得分 %d") % int(score), 18, Color("#ffd23f"), 150, HORIZONTAL_ALIGNMENT_RIGHT)

	# 路口信号灯面板
	if not ix.is_empty() and ix.wy + scroll < H and ix.wy + scroll + IX_H > -300.0:
		var red: bool = ix.state != "green"
		var px := W - 150.0
		draw_rect(Rect2(px, 74, 130, 64), Color(0, 0, 0, 0.7))
		draw_circle(Vector2(px + 32, 106), 22, Color("#ff3b30") if red else Color("#3ddc84"))
		_text_plain(Vector2(px + 13, 113), "停" if red else "行", 20, Color.WHITE, 38, HORIZONTAL_ALIGNMENT_CENTER)
		var label := tr("红灯") if red else tr("绿灯")
		if ix.state == "red":
			label = tr("红灯 %d") % ceili(ix.red_t)
		_text_plain(Vector2(px + 60, 113), label, 22, Color("#ff6b6b") if red else Color("#7CFC00"), 66)
	if not ix.is_empty() and ix.get("jaywalk", false) and ix.state != "green" and state == "play":
		var top: float = ix.wy + scroll
		if player_pos.y > top - 20.0 and player_pos.y < top + IX_H + 20.0 and fmod(elapsed, 0.4) < 0.25:
			_text(Vector2(W / 2.0, 110), "闯红灯中！小心车！", 32, Color("#ff3b30"))
	if near_curb and not ix.get("jaywalk", false):
		var hp := player_pos + Vector2(0, -58)
		_text(hp, "按住 ↑ 或 空格 闯红灯（扣 25% 分）", 18, Color("#ffcc80"))
		draw_rect(Rect2(hp.x - 60, hp.y + 8, 120, 8), Color(0, 0, 0, 0.6))
		draw_rect(Rect2(hp.x - 60, hp.y + 8, 120 * clampf(push_t / JAYWALK_HOLD, 0.0, 1.0), 8), Color("#ff5252"))
	if waiting and state == "play":
		var n := ceili(ix.red_t) if ix.state == "red" else 0
		_text(Vector2(W / 2.0, 110), tr("红灯 · 等一等  %d 秒") % n if n > 0 else tr("红灯 · 等一等…"), 32, Color("#ff6b6b"))

	if flash > 0.0:
		draw_rect(Rect2(0, 0, W, H), Color(1, 0, 0, flash * 0.3))

	if state == "countdown":
		draw_rect(Rect2(0, H / 2.0 - 140, W, 270), Color(0, 0, 0, 0.5))
		_text(Vector2(W / 2.0, H / 2.0 - 80), "%s · %s" % [tr(level.get("city", "")), tr(level.get("name", ""))], 40, Color.WHITE)
		if TranslationServer.get_locale().begins_with("zh"):  # 其他语言的关卡名本身就是译名
			_text(Vector2(W / 2.0, H / 2.0 - 46), level.get("en", ""), 20, Color("#cccccc"))
		_text(Vector2(W / 2.0, H / 2.0 + 30), str(ceili(countdown)), 72, Color("#ffd23f"))
		_text(Vector2(W / 2.0, H / 2.0 + 72), level.get("desc", ""), 22, Color("#ffd23f"))
		_text(Vector2(W / 2.0, H / 2.0 + 106), "WASD / 方向键 移动，躲开电鸡和路障，遇红灯要停", 18, Color.WHITE)
	elif go_timer > 0.0:
		_text(Vector2(W / 2.0, H / 2.0), "出发！", 72, Color("#7CFC00"))

	if paused:
		draw_rect(Rect2(0, 0, W, H), Color(0, 0, 0, 0.6))
		_text(Vector2(W / 2.0, H / 2.0 - (150.0 if touch_ui else 20.0)), "暂停", 64, Color.WHITE)
		if not touch_ui:  # 触屏上有“继续 / 返回菜单”按钮
			_text(Vector2(W / 2.0, H / 2.0 + 40), "ESC 继续    Q 返回菜单", 24, Color("#dddddd"))


## 左上角状态行：放不下操作说明时只显示状态（操作说明在开场介绍里有）
func _hud_line(tags: String, controls: String) -> String:
	if touch_ui:  # 触屏上没有键盘，不显示按键说明
		return tags
	var full := tags + "   " + controls
	if font.get_string_size(full, HORIZONTAL_ALIGNMENT_LEFT, -1, 16).x <= 440.0:
		return full
	return tags


func _text(pos: Vector2, txt: String, size: int, col: Color) -> void:
	_text_plain(pos + Vector2(-620, 0), txt, size, col, 1240, HORIZONTAL_ALIGNMENT_CENTER)


func _text_plain(pos: Vector2, txt: String, size: int, col: Color, width := -1.0, align := HORIZONTAL_ALIGNMENT_LEFT) -> void:
	txt = tr(txt)  # 纯文字（店名、路名、对白、提示）在这里统一翻译；带格式的在调用处先翻译模板
	if width > 0.0:  # 译文太长：缩小字号直到放得下
		while size > 10 and font.get_string_size(txt, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x > width:
			size -= 1
	var outline := Color(0, 0, 0, 0.75 * col.a)
	draw_string_outline(font, pos, txt, align, width, size, maxi(4, size / 5), outline)
	draw_string(font, pos, txt, align, width, size, col)
