extends SceneTree
## 触屏测试：模拟手指按下 / 拖动，验证摇杆移动、油门刹车、闯红灯按钮、暂停、不干扰键盘。

const GameScript := preload("res://scripts/game.gd")
const DriveScript := preload("res://scripts/drive.gd")
const TouchScript := preload("res://scripts/touch.gd")
const MainScript := preload("res://scripts/main.gd")
const LEVELS: Array = preload("res://scripts/levels.gd").LIST
var bad := 0


func _touch(t: Node, idx: int, pos: Vector2, down: bool) -> void:
	var e := InputEventScreenTouch.new()
	e.index = idx
	e.position = pos
	e.pressed = down
	t._input(e)


func _drag(t: Node, idx: int, pos: Vector2) -> void:
	var e := InputEventScreenDrag.new()
	e.index = idx
	e.position = pos
	t._input(e)


func _step(g: Node, t: Node, n: int) -> void:
	for i in n:
		t._process(1.0 / 60.0)
		g._process(1.0 / 60.0)


func _check(name: String, ok: bool, info := "") -> void:
	print("%-28s %s %s" % [name, "OK" if ok else "失败", info])
	if not ok:
		bad += 1


func _make(mode: String, li := 0) -> Array:
	# 注意：调用方需要 await process_frame，让节点的 _ready 先执行
	var g: Node2D = DriveScript.new() if mode == "drive" else GameScript.new()
	g.setup(LEVELS[li], mode, false, Callable())
	g.god = true
	root.add_child(g)
	g.countdown = 0.0
	g.touch_ui = true
	var t: CanvasLayer = TouchScript.new()
	t.setup(g, Callable())
	root.add_child(t)
	return [g, t]


func _initialize() -> void:
	var m = MainScript.new()
	m._setup_input()
	m.free()

	# 1. 步行：摇杆向右拖，人物往右走
	var gt := _make("walk")
	var g: Node2D = gt[0]
	var t: CanvasLayer = gt[1]
	await process_frame
	g.player_pos = Vector2(500, 600)
	var x0: float = g.player_pos.x
	_touch(t, 0, Vector2(300, 500), true)
	_drag(t, 0, Vector2(390, 500))
	_step(g, t, 30)
	_check("摇杆向右 → 人物右移", g.player_pos.x > x0 + 60.0, "x %.0f → %.0f" % [x0, g.player_pos.x])
	# 2. 暂停：摇杆不起作用；继续后恢复
	t._toggle_pause()
	var x1: float = g.player_pos.x
	_step(g, t, 20)
	_check("暂停时不移动", g.paused and absf(g.player_pos.x - x1) < 0.01)
	t._toggle_pause()
	_touch(t, 0, Vector2(300, 500), false)
	_touch(t, 0, Vector2(300, 500), true)
	_drag(t, 0, Vector2(300, 410))
	var y1: float = g.player_pos.y
	_step(g, t, 20)
	_check("继续后摇杆向上 → 人物上移", not g.paused and g.player_pos.y < y1 - 20.0, "y %.0f → %.0f" % [y1, g.player_pos.y])
	_touch(t, 0, Vector2(300, 410), false)
	# 3. 没有触摸时不释放键盘按着的键
	Input.action_press("move_left")
	_step(g, t, 5)
	_check("不干扰键盘输入", Input.is_action_pressed("move_left"))
	Input.action_release("move_left")
	# 4. 闯红灯按钮：走到红灯路缘，点按钮
	var f := 0
	while not g.waiting and f < 3000:
		_step(g, t, 1)
		f += 1
	g.player_pos = Vector2(640, g.ix.wy + g.scroll + g.IX_H + 30.0)
	_step(g, t, 2)
	_touch(t, 1, t.JAY_RECT.get_center(), true)
	_step(g, t, 3)
	_touch(t, 1, t.JAY_RECT.get_center(), false)
	_check("闯红灯按钮", g.jaywalks == 1, "near_curb=%s jaywalks=%d" % [g.near_curb, g.jaywalks])
	t.free()
	g.free()

	# 5. 开车：按住油门加速，踩刹车减速
	gt = _make("drive", 4)
	g = gt[0]
	t = gt[1]
	await process_frame
	_touch(t, 0, t.GAS_RECT.get_center(), true)
	_step(g, t, 90)
	var v1: float = g.me.v
	_check("按住油门 → 加速", v1 > 100.0, "v=%.0f" % v1)
	_touch(t, 0, t.GAS_RECT.get_center(), false)
	_touch(t, 1, t.BRAKE_RECT.get_center(), true)
	_step(g, t, 30)
	_check("踩刹车 → 减速", g.me.v < v1 - 50.0, "v %.0f → %.0f" % [v1, g.me.v])
	_touch(t, 1, t.BRAKE_RECT.get_center(), false)
	# 一只手拨摇杆变道，另一只手踩油门（多点触控）
	var lane_x: float = g.me.pos.x
	_touch(t, 2, Vector2(300, 500), true)
	_drag(t, 2, Vector2(390, 500))
	_touch(t, 3, t.GAS_RECT.get_center(), true)
	_step(g, t, 60)
	_check("多点：摇杆变道 + 油门", g.me.pos.x > lane_x + 20.0 and g.me.v > 50.0, "x %.0f → %.0f v=%.0f" % [lane_x, g.me.pos.x, g.me.v])
	t.free()
	g.free()
	quit(1 if bad else 0)
