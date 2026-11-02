extends Node
## 入口：菜单 / 选关 / 规则 / 结算界面切换，存档与关卡解锁，输入映射与程序化音效。

const GameScript := preload("res://scripts/game.gd")
const DriveScript := preload("res://scripts/drive.gd")
const DRIVE: Dictionary = preload("res://scripts/levels.gd").DRIVE
## 支持作者页面。提交 Steam 审核时如需隐藏，改成 false
const SUPPORT_ENABLED := true
const SUPPORT_ADDRS := [
	["ETH", "0xbbc1fe874422f61fb135e72c3229fffc3cb266fb"],
	["ENS", "yanbo.eth"],
	["SOL", "39RwdwM8dCkVeRqbtxgeMKvv3x1pgQKDavYJ8dFzcnhy"],
]
const MODE_NAMES := {"walk": "步行", "bike": "骑车", "drive": "开车"}
const LEVELS: Array = preload("res://scripts/levels.gd").LIST
const SAVE_PATH := "user://save.cfg"
const RANK_ORDER := {"C": 1, "B": 2, "A": 3, "S": 4}

var game: Node2D
var ui: CanvasLayer
var players := {}
var save := ConfigFile.new()
var last_level := 0
var last_mode := "walk"
var args: PackedStringArray
var invincible := false


func _ready() -> void:
	randomize()
	# 中文字体：Mac 苹方 / Windows 微软雅黑等系统字体（不打包字体文件）
	ThemeDB.fallback_font = preload("res://fonts/ui_font.tres")
	args = OS.get_cmdline_user_args()
	_setup_input()
	_make_sfx()
	if "--reset-save" not in args:
		save.load(SAVE_PATH)
	if "--unlock-all" in args:
		save.set_value("progress", "unlocked", LEVELS.size() - 1)
	last_mode = save.get_value("progress", "mode", "walk")
	invincible = save.get_value("flags", "invincible", false) or "--invincible" in args
	var auto := ""
	var lv := 0
	for a in args:
		if a.begins_with("--autostart="):
			auto = a.get_slice("=", 1)
		elif a.begins_with("--level="):
			lv = clampi(a.get_slice("=", 1).to_int(), 0, LEVELS.size() - 1)
	if auto != "":
		_launch(lv, auto)
	elif "--rules" in args:
		_show_rules(Callable())
	elif "--support" in args:
		_demo_background()
		_show_support()
	else:
		_show_menu()


# ------------------------------------------------------------------ 存档

func _unlocked() -> int:
	return save.get_value("progress", "unlocked", 0)


func _write_save() -> void:
	save.save(SAVE_PATH)


func _rank(r: Dictionary) -> String:
	if not r.win:
		return "C"
	return "S" if r.hits == 0 else ("A" if r.hits == 1 else "B")


## 记录成绩，返回是否解锁了新关卡
func _record(idx: int, r: Dictionary) -> bool:
	var id: String = LEVELS[idx].id
	var rank := _rank(r)
	if r.score > save.get_value("best", id + "_score", 0):
		save.set_value("best", id + "_score", r.score)
	if RANK_ORDER[rank] > RANK_ORDER.get(save.get_value("best", id + "_rank", ""), 0):
		save.set_value("best", id + "_rank", rank)
	var unlocked_new := false
	if r.win:
		save.set_value("best", id + "_cleared", true)
		if idx + 1 < LEVELS.size() and _unlocked() < idx + 1:
			save.set_value("progress", "unlocked", idx + 1)
			unlocked_new = true
	_write_save()
	return unlocked_new


func _unhandled_input(e: InputEvent) -> void:
	if e is InputEventKey and e.pressed and not e.echo:
		if e.keycode == KEY_F11 or (e.keycode == KEY_ENTER and e.alt_pressed):
			var full := DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED if full else DisplayServer.WINDOW_MODE_FULLSCREEN)


func _setup_input() -> void:
	var keys := {
		"move_left": [KEY_A, KEY_LEFT], "move_right": [KEY_D, KEY_RIGHT],
		"move_up": [KEY_W, KEY_UP], "move_down": [KEY_S, KEY_DOWN],
	}
	var dpad := {
		"move_left": JOY_BUTTON_DPAD_LEFT, "move_right": JOY_BUTTON_DPAD_RIGHT,
		"move_up": JOY_BUTTON_DPAD_UP, "move_down": JOY_BUTTON_DPAD_DOWN,
	}
	var axes := {
		"move_left": [JOY_AXIS_LEFT_X, -1.0], "move_right": [JOY_AXIS_LEFT_X, 1.0],
		"move_up": [JOY_AXIS_LEFT_Y, -1.0], "move_down": [JOY_AXIS_LEFT_Y, 1.0],
	}
	# 闯红灯：空格 / 手柄 A
	if not InputMap.has_action("jaywalk"):
		InputMap.add_action("jaywalk")
		var sp := InputEventKey.new()
		sp.physical_keycode = KEY_SPACE
		InputMap.action_add_event("jaywalk", sp)
		var ja := InputEventJoypadButton.new()
		ja.button_index = JOY_BUTTON_A
		InputMap.action_add_event("jaywalk", ja)
	for action in keys:
		if not InputMap.has_action(action):
			InputMap.add_action(action, 0.25)
		for k in keys[action]:
			var ev := InputEventKey.new()
			ev.physical_keycode = k
			InputMap.action_add_event(action, ev)
		var jb := InputEventJoypadButton.new()
		jb.button_index = dpad[action]
		InputMap.action_add_event(action, jb)
		var jm := InputEventJoypadMotion.new()
		jm.axis = axes[action][0]
		jm.axis_value = axes[action][1]
		InputMap.action_add_event(action, jm)


# ------------------------------------------------------------------ 程序化音效

func _sq(phase: float) -> float:
	return 1.0 if fmod(phase, 1.0) < 0.5 else -1.0


func _synth(dur: float, f: Callable, vol := 0.3) -> AudioStreamWAV:
	var rate := 22050
	var n := int(rate * dur)
	var data := PackedByteArray()
	data.resize(n * 2)
	for i in n:
		var t := float(i) / rate
		var env := minf(1.0, t * 200.0) * minf(1.0, (dur - t) * 30.0)
		var s: float = f.call(t)
		data.encode_s16(i * 2, int(clampf(s * env * vol, -1.0, 1.0) * 32767.0))
	var w := AudioStreamWAV.new()
	w.format = AudioStreamWAV.FORMAT_16_BITS
	w.mix_rate = rate
	w.stereo = false
	w.data = data
	return w


func _make_sfx() -> void:
	var sounds := {
		# 电动车的“嘀嘀”喇叭
		"beep": _synth(0.32, func(t): return (_sq(t * 1450.0) + _sq(t * 1820.0)) * 0.5 if fmod(t, 0.16) < 0.1 else 0.0, 0.18),
		"hit": _synth(0.35, func(t): return (randf() * 2.0 - 1.0) * pow(1.0 - t / 0.35, 2.0) * 0.8 + _sq(t * (140.0 - t * 150.0)) * 0.4, 0.4),
		# 急刹：刺耳的摩擦声
		"brake": _synth(0.4, func(t): return sin(TAU * (2600.0 * t - 900.0 * t * t)) * 0.6 + (randf() * 2.0 - 1.0) * 0.25, 0.16),
		# 交警哨子（闯红灯）
		"whistle": _synth(0.6, func(t): return sin(TAU * (2900.0 * t + 6.0 * sin(TAU * 28.0 * t))) if fmod(t, 0.3) < 0.24 else 0.0, 0.28),
		# 创飞：卡通弹簧音
		"boing": _synth(0.35, func(t): return sin(TAU * (180.0 * t + 1300.0 * t * t) + 3.0 * sin(TAU * 18.0 * t)) * (1.0 - t / 0.35), 0.35),
		"near": _synth(0.14, func(t): return sin(TAU * (700.0 * t + 2500.0 * t * t)), 0.3),
		"tick": _synth(0.1, func(t): return sin(TAU * 660.0 * t), 0.35),
		"go": _synth(0.3, func(t): return sin(TAU * 990.0 * t) + 0.3 * _sq(t * 990.0), 0.3),
		"win": _synth(0.75, func(t): return _sq(t * [523.0, 659.0, 784.0, 1047.0][mini(int(t / 0.12), 3)]) * 0.5, 0.25),
		"lose": _synth(0.6, func(t): return sin(TAU * t * [392.0, 330.0, 262.0][mini(int(t / 0.2), 2)]), 0.35),
	}
	for k in sounds:
		var p := AudioStreamPlayer.new()
		p.stream = sounds[k]
		p.max_polyphony = 4
		add_child(p)
		players[k] = p


func play_sfx(n: String) -> void:
	if players.has(n):
		players[n].play()


# ------------------------------------------------------------------ 场景切换

func _clear_game() -> void:
	if game:
		game.queue_free()
		game = null


func _new_ui() -> Control:
	if ui:
		ui.queue_free()
	ui = CanvasLayer.new()
	ui.layer = 10
	add_child(ui)
	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	ui.add_child(root)
	return root


func _label(text: String, size: int, col := Color.WHITE, outline := 8) -> Label:
	var l := Label.new()
	l.text = text
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", col)
	l.add_theme_constant_override("outline_size", outline)
	l.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.85))
	return l


func _button(text: String, cb: Callable, disabled := false) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(380, 54)
	b.add_theme_font_size_override("font_size", 24)
	b.disabled = disabled
	b.pressed.connect(cb)
	return b


func _spacer(h: float) -> Control:
	var c := Control.new()
	c.custom_minimum_size = Vector2(0, h)
	return c


func _centered_box(root: Control, dim: float) -> VBoxContainer:
	var bg := ColorRect.new()
	bg.color = Color(0.05, 0.07, 0.1, dim)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_child(bg)
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_child(center)
	var box := VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 12)
	center.add_child(box)
	return box


func _shrink_buttons(box: Control) -> void:
	for c in box.get_children():
		if c is Button:
			c.size_flags_horizontal = Control.SIZE_SHRINK_CENTER


func _demo_background() -> void:
	_clear_game()
	game = GameScript.new()
	var unlocked := LEVELS.slice(0, _unlocked() + 1)
	game.setup(unlocked.pick_random(), "bike", true, play_sfx)
	add_child(game)


func _level_desc(i: int) -> String:
	var lv: Dictionary = LEVELS[i]
	var tags := []
	if lv.get("weather", "clear") == "rain":
		tags.append("暴雨")
	if lv.get("night", false):
		tags.append("夜间")
	if last_mode == "drive":
		var d: Dictionary = DRIVE.get(lv.id, {})
		tags.append("%s 限速%d" % [d.get("road", ""), d.get("limit", 50)])
		tags.append("%d 个路口" % d.get("crossings", []).size())
		return "%s · %s ｜ %s ｜ %s" % [lv.city, lv.name, " · ".join(tags), d.get("desc", "")]
	tags.append("%d 个路口" % lv.get("crossings", []).size())
	return "%s · %s ｜ %s ｜ %s" % [lv.city, lv.name, " · ".join(tags), lv.desc]


func _toggle_button(text: String, on: bool, w: float) -> Button:
	var mb := Button.new()
	mb.text = ("● " if on else "") + text
	mb.add_theme_color_override("font_pressed_color", Color("#ffd23f"))
	mb.add_theme_color_override("font_hover_pressed_color", Color("#ffd23f"))
	mb.toggled.connect(func(v: bool): mb.text = ("● " if v else "") + text)
	mb.toggle_mode = true
	mb.button_pressed = on
	mb.custom_minimum_size = Vector2(w, 42)
	mb.add_theme_font_size_override("font_size", 19)
	return mb


func _show_menu() -> void:
	_demo_background()
	var box := _centered_box(_new_ui(), 0.6)
	box.add_theme_constant_override("separation", 8)
	box.add_child(_label("躲避电鸡", 66, Color("#ffd23f"), 14))
	box.add_child(_label("Avoiding Electric Vehicles  ·  没有非机动车道的广深街头", 20, Color("#dddddd"), 6))

	# 出行方式 + 无敌模式
	var mode_row := HBoxContainer.new()
	mode_row.alignment = BoxContainer.ALIGNMENT_CENTER
	mode_row.add_theme_constant_override("separation", 10)
	mode_row.add_child(_label("出行方式：", 20))
	var group := ButtonGroup.new()
	var desc := _label("", 18, Color("#ffd23f"), 6)
	for m in [["walk", "步行"], ["bike", "骑车"], ["drive", "开车"]]:
		var mb := _toggle_button(m[1], last_mode == m[0], 130)
		mb.button_group = group
		var mode_id: String = m[0]
		mb.pressed.connect(func():
			last_mode = mode_id
			save.set_value("progress", "mode", mode_id)
			_write_save())
		mode_row.add_child(mb)
	mode_row.add_child(_spacer(0))
	var inv := _toggle_button("无敌模式：创飞一切电鸡！", invincible, 300)
	inv.add_theme_color_override("font_pressed_color", Color("#ff5252"))
	inv.add_theme_color_override("font_hover_pressed_color", Color("#ff5252"))
	inv.toggled.connect(func(v: bool):
		invincible = v
		save.set_value("flags", "invincible", v)
		_write_save()
		_show_menu.call_deferred())
	mode_row.add_child(inv)
	box.add_child(mode_row)

	# 选关（无敌模式全部开放）
	var grid := GridContainer.new()
	grid.columns = 4
	grid.add_theme_constant_override("h_separation", 10)
	grid.add_theme_constant_override("v_separation", 10)
	desc.custom_minimum_size = Vector2(1100, 28)
	var first: Button
	for i in LEVELS.size():
		var lv: Dictionary = LEVELS[i]
		var locked := i > _unlocked() and not invincible
		var best := "未通关"
		if save.get_value("best", lv.id + "_cleared", false):
			best = "最佳 %s · %d 分" % [save.get_value("best", lv.id + "_rank", "B"), save.get_value("best", lv.id + "_score", 0)]
		if invincible:
			best = "无敌畅玩"
		var b := Button.new()
		b.text = "第 %d 关 · %s\n%s\n%s" % [i + 1, lv.city, lv.name, "未解锁" if locked else best]
		b.disabled = locked
		b.custom_minimum_size = Vector2(262, 80)
		b.add_theme_font_size_override("font_size", 17)
		var idx := i
		b.pressed.connect(func(): _launch(idx, last_mode))
		b.focus_entered.connect(func(): desc.text = _level_desc(idx))
		b.mouse_entered.connect(func(): desc.text = _level_desc(idx) if idx <= _unlocked() or invincible else "通关第 %d 关后解锁" % idx)
		grid.add_child(b)
		if not locked and (first == null or i <= _unlocked()):
			first = b  # 默认选中最新解锁的关卡
	var gc := CenterContainer.new()
	gc.add_child(grid)
	box.add_child(gc)
	box.add_child(desc)
	if invincible:
		box.add_child(_label("无敌模式：不掉血、无视红灯，撞到的电鸡全部创飞；成绩不计入存档", 16, Color("#ff8a80"), 6))

	var bottom := HBoxContainer.new()
	bottom.alignment = BoxContainer.ALIGNMENT_CENTER
	bottom.add_theme_constant_override("separation", 16)
	var rules := _button("游戏规则", func(): _show_rules(Callable()))
	var quit := _button("退出游戏", func(): get_tree().quit())
	rules.custom_minimum_size = Vector2(200, 44)
	quit.custom_minimum_size = Vector2(200, 44)
	bottom.add_child(rules)
	if SUPPORT_ENABLED:
		var sup := _button("支持作者", _show_support)
		sup.custom_minimum_size = Vector2(200, 44)
		bottom.add_child(sup)
	bottom.add_child(quit)
	box.add_child(bottom)
	box.add_child(_label("步行 / 骑车：WASD 移动 · 开车：W 加速 S 刹车 A/D 变道 · 空格闯红灯 · ESC 暂停 · F11 全屏", 15, Color("#bbbbbb"), 6))
	first.grab_focus()


const RULES := """[center][font_size=36][color=#ffd23f]游戏规则[/color][/font_size][/center]
[color=#7CFC00]目标[/color]　步行 / 骑车：每关 60 秒，沿没有非机动车道的人行道往前走，被撞 3 次失败。
[color=#7CFC00]开车[/color]　按每关真实路段的车道、限速、公交专用道设计：60 秒内开到目的地，W 加速 S 刹车 A/D 变道。
[color=#7CFC00]操作[/color]　WASD / 方向键 / 手柄移动，空格闯红灯，ESC 暂停，F11 全屏。
[color=#ffd23f]电鸡[/color]　迎面逆行、身后超车（[color=#ff5252]红三角 + 嘀嘀声[/color]预警）、蛇形、钻车缝、店门口 / 路边冲出、急刹后变路障。
[color=#ffd23f]路障[/color]　地铁口、共享单车、停着的电鸡、石墩、摊位、违停车、施工围挡都是实心的，撞上要扣命。
[color=#ffd23f]红绿灯[/color]　步行红灯时画面停下等绿灯；开车要自己刹停在停止线前。占用公交专用道会持续扣分。
[color=#ff5252]闯红灯[/color]　步行在路缘前[color=#ffcc80]按住 ↑ 半秒或按空格[/color]硬闯，开车直接冲线：[color=#ff5252]扣当前分数 25%[/color]，在路口里[color=#ff5252]被车撞到直接 GAME OVER[/color]。
[color=#00b8d4]得分[/color]　坚持越久 / 开得越远分越高，擦身而过 +50，通关每条剩余的命 +300。
[color=#00b8d4]评级[/color]　S 零失误 · A 被撞 1 次 · B 通关 · C 失败。[color=#7CFC00]通关前一关才能解锁下一关[/color]，广州、深圳共 12 关。
[color=#ff8a80]无敌模式[/color]　主页打开后不掉血、无视红灯，撞到的电鸡全部[color=#ffd23f]创飞[/color]（每只 +100），成绩不计入存档。"""


func _show_support() -> void:
	var box := _centered_box(_new_ui(), 0.85)
	box.add_theme_constant_override("separation", 14)
	box.add_child(_label("支持作者", 44, Color("#ffd23f"), 10))
	box.add_child(_label("喜欢这个游戏的话，可以请作者喝杯奶茶", 22, Color("#dddddd"), 6))
	box.add_child(_spacer(6))
	var tip := _label("点击地址即可复制", 18, Color("#bbbbbb"), 6)
	var first: Button
	for a in SUPPORT_ADDRS:
		var chain: String = a[0]
		var addr: String = a[1]
		var b := Button.new()
		b.text = "%s    %s" % [chain, addr]
		b.custom_minimum_size = Vector2(820, 56)
		b.add_theme_font_size_override("font_size", 20)
		b.pressed.connect(func():
			DisplayServer.clipboard_set(addr)
			tip.text = "已复制 %s：%s" % [chain, addr]
			tip.add_theme_color_override("font_color", Color("#7CFC00")))
		box.add_child(b)
		if first == null:
			first = b
	box.add_child(tip)
	box.add_child(_spacer(6))
	box.add_child(_button("返回菜单", _show_menu))
	_shrink_buttons(box)
	first.grab_focus()


## next 为空表示从菜单进入，看完返回菜单；否则看完直接开始关卡
func _show_rules(next: Callable) -> void:
	if game == null:
		_demo_background()
	var box := _centered_box(_new_ui(), 0.85)
	var rt := RichTextLabel.new()
	rt.bbcode_enabled = true
	rt.fit_content = true
	rt.scroll_active = false
	rt.custom_minimum_size = Vector2(1180, 0)
	rt.add_theme_font_size_override("normal_font_size", 19)
	rt.add_theme_constant_override("line_separation", 9)
	rt.text = RULES
	box.add_child(rt)
	box.add_child(_spacer(4))
	var ok := _button("明白了，开始！" if next.is_valid() else "返回菜单", func():
		save.set_value("flags", "seen_rules", true)
		_write_save()
		if next.is_valid():
			next.call()
		else:
			_show_menu())
	box.add_child(ok)
	_shrink_buttons(box)
	ok.grab_focus()


## 开始关卡；第一次玩先看规则
func _launch(level_idx: int, mode: String) -> void:
	if not save.get_value("flags", "seen_rules", false) and "--autostart" not in " ".join(args):
		_show_rules(func(): _start_game(level_idx, mode))
	else:
		_start_game(level_idx, mode)


func _start_game(level_idx: int, mode: String) -> void:
	_clear_game()
	if ui:
		ui.queue_free()
		ui = null
	last_level = level_idx
	last_mode = mode
	game = DriveScript.new() if mode == "drive" else GameScript.new()
	game.setup(LEVELS[level_idx], mode, false, play_sfx)
	game.god = "--god" in args
	game.invincible = invincible
	game.finished.connect(_on_finished)
	add_child(game)


func _on_finished(r: Dictionary) -> void:
	if r.get("quit", false):
		_show_menu()
		return
	game.process_mode = Node.PROCESS_MODE_DISABLED
	var unlocked_new := false if r.invincible else _record(last_level, r)
	var lv: Dictionary = LEVELS[last_level]
	var drive: bool = r.mode == "drive"
	var box := _centered_box(_new_ui(), 0.7)
	box.add_theme_constant_override("separation", 10)
	if r.win:
		box.add_child(_label(("准时到达！%s" if drive else "成功穿越 %s！") % (DRIVE[lv.id].road if drive else lv.name), 50, Color("#7CFC00"), 12))
	elif r.run_over:
		box.add_child(_label("闯红灯被车撞了，GAME OVER", 50, Color("#ff5252"), 12))
	elif r.get("late", false):
		box.add_child(_label("迟到了！60 秒没开到目的地", 50, Color("#ff5252"), 12))
	else:
		box.add_child(_label("撞车太多次，今天别开了……" if drive else "你被电鸡创飞了……", 50, Color("#ff5252"), 12))
	if not r.win:
		box.add_child(_label("现实可能比游戏更残酷。", 24, Color("#ff8a80"), 6))
	box.add_child(_label("评级  %s" % _rank(r), 40, Color("#ffd23f"), 10))
	if drive:
		box.add_child(_label("行驶  %d / %d 米      用时  %.1f 秒      等红灯  %.1f 秒" % [r.dist, r.target, r.time, r.wait], 23))
		box.add_child(_label("擦身而过  %d 次      撞车  %d 次      闯红灯  %d 次      公交道扣分  %d" % [r.near, r.hits, r.jaywalks, r.bus_pen], 23))
	else:
		box.add_child(_label("坚持时间  %.1f 秒      等红灯  %.1f 秒" % [r.time, r.wait], 23))
		box.add_child(_label("擦身而过  %d 次      被撞  %d 次      闯红灯  %d 次" % [r.near, r.hits, r.jaywalks], 23))
	if r.invincible:
		box.add_child(_label("创飞电鸡  %d 只！" % r.launched, 30, Color("#ff8a80")))
	box.add_child(_label("总得分  %d" % r.score, 30, Color("#ffd23f")))
	if r.invincible:
		box.add_child(_label("（无敌模式成绩不计入存档）", 18, Color("#bbbbbb"), 6))
	if unlocked_new:
		var nxt: Dictionary = LEVELS[last_level + 1]
		box.add_child(_label("解锁新关卡：%s · %s" % [nxt.city, nxt.name], 24, Color("#00e5ff")))
	box.add_child(_spacer(4))
	var again := _button("再来一次  Retry", func(): _start_game(last_level, last_mode))
	var focus := again
	if last_level + 1 < LEVELS.size() and (last_level + 1 <= _unlocked() or r.invincible):
		var nxt: Dictionary = LEVELS[last_level + 1]
		focus = _button("下一关：%s · %s" % [nxt.city, nxt.name], func(): _start_game(last_level + 1, last_mode))
		box.add_child(focus)
	box.add_child(again)
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 10)
	for m in ["walk", "bike", "drive"]:
		if m != last_mode:
			var mm: String = m
			var mb := _button("换成%s" % MODE_NAMES[m], func(): _start_game(last_level, mm))
			mb.custom_minimum_size = Vector2(185, 48)
			row.add_child(mb)
	box.add_child(row)
	box.add_child(_button("返回菜单  Menu", _show_menu))
	_shrink_buttons(box)
	focus.grab_focus()
