extends CanvasLayer
## 触屏操作层（手机 / 平板网页版，没有键盘手柄也能玩）。由 main.gd 在有触摸屏时为每局创建。
##   左半屏：按下的位置出现浮动摇杆（步行 / 骑车移动；开车左右变道、上下也能加速刹车）
##   开车：右下角油门、刹车踏板，按住生效
##   步行 / 骑车：走到红灯路缘时右侧出现“闯红灯”按钮
##   右上角 II：暂停，暂停时出现“继续 / 返回菜单”
## 只在按住时向游戏注入输入动作；没有触摸时不会去释放键盘按下的动作。

const W := 1280.0
const H := 720.0
const JOY_R := 90.0
const GAS_RECT := Rect2(1120, 440, 140, 240)
const BRAKE_RECT := Rect2(960, 540, 140, 140)
const JAY_RECT := Rect2(1040, 300, 220, 84)

var game: Node2D
var on_quit: Callable
var joy_id := -1
var joy_origin := Vector2.ZERO
var joy_vec := Vector2.ZERO
var pedals := {}          # 触点 index -> "gas" / "brake"
var jay_frames := 0
var pressed := {}         # 本层按下的动作 -> 力度
var canvas: Control
var pause_box: VBoxContainer


func setup(p_game: Node2D, p_on_quit: Callable) -> void:
	game = p_game
	on_quit = p_on_quit


func _ready() -> void:
	process_priority = -10  # 先于关卡处理，按钮注入的“刚按下”关卡当帧就能读到
	layer = 15
	canvas = Control.new()
	canvas.set_anchors_preset(Control.PRESET_FULL_RECT)
	canvas.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.draw.connect(_draw_controls)
	add_child(canvas)

	var pause_btn := Button.new()
	pause_btn.text = "II"
	pause_btn.position = Vector2(W / 2.0 + 175.0, 6.0)
	pause_btn.custom_minimum_size = Vector2(64, 52)
	pause_btn.add_theme_font_size_override("font_size", 26)
	pause_btn.focus_mode = Control.FOCUS_NONE
	pause_btn.pressed.connect(_toggle_pause)
	add_child(pause_btn)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(center)
	pause_box = VBoxContainer.new()
	pause_box.add_theme_constant_override("separation", 18)
	pause_box.visible = false
	center.add_child(pause_box)
	pause_box.add_child(_big_button("继续", _toggle_pause))
	pause_box.add_child(_big_button("返回菜单", func(): on_quit.call()))


func _big_button(text: String, cb: Callable) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(360, 76)
	b.add_theme_font_size_override("font_size", 30)
	b.focus_mode = Control.FOCUS_NONE
	b.pressed.connect(cb)
	return b


func _toggle_pause() -> void:
	if not is_instance_valid(game) or game.state in ["over", "done"]:
		return
	game.paused = not game.paused
	_release_all()


func _exit_tree() -> void:
	_release_all()


func _drive() -> bool:
	return is_instance_valid(game) and game.mode == "drive"


func _jay_visible() -> bool:
	return is_instance_valid(game) and not _drive() and game.get("near_curb") == true and not game.paused


func _input(e: InputEvent) -> void:
	if not is_instance_valid(game) or game.paused:
		return
	if e is InputEventScreenTouch:
		var t := e as InputEventScreenTouch
		if t.pressed:
			if _drive() and GAS_RECT.has_point(t.position):
				pedals[t.index] = "gas"
			elif _drive() and BRAKE_RECT.has_point(t.position):
				pedals[t.index] = "brake"
			elif _jay_visible() and JAY_RECT.has_point(t.position):
				jay_frames = 2
			elif joy_id == -1 and t.position.x < W * 0.6 and t.position.y > 70.0:
				joy_id = t.index
				joy_origin = t.position
				joy_vec = Vector2.ZERO
		else:
			pedals.erase(t.index)
			if t.index == joy_id:
				joy_id = -1
				joy_vec = Vector2.ZERO
	elif e is InputEventScreenDrag:
		var d := e as InputEventScreenDrag
		if d.index == joy_id:
			var v := (d.position - joy_origin) / JOY_R
			if v.length() > 1.0:  # 拖出圈外：摇杆中心跟着手指走
				joy_origin = d.position - v.normalized() * JOY_R
				v = v.normalized()
			joy_vec = v if v.length() > 0.15 else Vector2.ZERO


func _process(_delta: float) -> void:
	if canvas == null:
		return
	var want := {
		"move_left": maxf(0.0, -joy_vec.x), "move_right": maxf(0.0, joy_vec.x),
		"move_up": maxf(0.0, -joy_vec.y), "move_down": maxf(0.0, joy_vec.y), "jaywalk": 0.0,
	}
	for k in pedals:
		if pedals[k] == "gas":
			want.move_up = 1.0
		else:
			want.move_down = 1.0
	if jay_frames > 0:
		jay_frames -= 1
		want.jaywalk = 1.0 if jay_frames == 1 else 0.0
	if is_instance_valid(game) and game.paused:
		for k in want:
			want[k] = 0.0
	for a in want:
		var s: float = want[a]
		if s > 0.05:
			Input.action_press(a, s)
			pressed[a] = s
		elif pressed.has(a):
			Input.action_release(a)
			pressed.erase(a)
	pause_box.visible = is_instance_valid(game) and game.paused
	canvas.queue_redraw()


func _release_all() -> void:
	for a in pressed:
		Input.action_release(a)
	pressed.clear()
	pedals.clear()
	joy_id = -1
	joy_vec = Vector2.ZERO


func _draw_controls() -> void:
	if not is_instance_valid(game) or game.paused or game.state in ["over", "done"]:
		return
	# 浮动摇杆（没按的时候在左下角显示一个淡淡的提示）
	var o := joy_origin if joy_id != -1 else Vector2(180, 450)
	var a := 0.55 if joy_id != -1 else 0.25
	canvas.draw_circle(o, JOY_R, Color(1, 1, 1, a * 0.35))
	canvas.draw_arc(o, JOY_R, 0, TAU, 48, Color(1, 1, 1, a), 3.0)
	canvas.draw_circle(o + joy_vec * JOY_R, 36, Color(1, 1, 1, a + 0.15))
	if _drive():
		_pedal(GAS_RECT, pedals.values().has("gas"), true)
		_pedal(BRAKE_RECT, pedals.values().has("brake"), false)
	if _jay_visible():
		canvas.draw_rect(JAY_RECT, Color(0.85, 0.15, 0.15, 0.8))
		canvas.draw_rect(JAY_RECT, Color.WHITE, false, 3.0)
		var f: Font = ThemeDB.fallback_font
		var txt := tr("闯红灯！")
		var size := 30
		while size > 12 and f.get_string_size(txt, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x > JAY_RECT.size.x - 16.0:
			size -= 1
		canvas.draw_string(f, Vector2(JAY_RECT.position.x, JAY_RECT.get_center().y + size * 0.35), txt,
			HORIZONTAL_ALIGNMENT_CENTER, JAY_RECT.size.x, size, Color.WHITE)


## 踏板：油门画向上的箭头（绿），刹车画横杠（红）
func _pedal(r: Rect2, down: bool, gas: bool) -> void:
	var col := Color(0.2, 0.75, 0.35) if gas else Color(0.85, 0.2, 0.2)
	canvas.draw_rect(r, Color(col, 0.75 if down else 0.4))
	canvas.draw_rect(r, Color(1, 1, 1, 0.8), false, 3.0)
	var c := r.get_center()
	if gas:
		canvas.draw_colored_polygon(PackedVector2Array([c + Vector2(0, -50), c + Vector2(-38, 10), c + Vector2(38, 10)]), Color.WHITE)
		canvas.draw_rect(Rect2(c + Vector2(-14, 10), Vector2(28, 40)), Color.WHITE)
	else:
		canvas.draw_rect(Rect2(c + Vector2(-40, -12), Vector2(80, 24)), Color.WHITE)
