extends SceneTree
## 用真实按键事件模拟玩家闯红灯：按住 W、按空格、开局一直按 W（不应在路口出现前误判）。

const GameScript := preload("res://scripts/game.gd")
const MainScript := preload("res://scripts/main.gd")
const LEVELS: Array = preload("res://scripts/levels.gd").LIST


func _key(code: Key, pressed: bool) -> void:
	var ev := InputEventKey.new()
	ev.physical_keycode = code
	ev.keycode = code
	ev.pressed = pressed
	Input.parse_input_event(ev)
	Input.flush_buffered_events()


func _initialize() -> void:
	var m = MainScript.new()
	m._setup_input()
	m.free()
	var bad := 0
	for li in [0, 1, 6, 8]:
		for mode in ["walk", "bike"]:
			for how in ["hold", "space", "early"]:
				var g: Node2D = GameScript.new()
				g.setup(LEVELS[li], mode, false, Callable())
				root.add_child(g)
				g.countdown = 0.0
				g.lives = 99
				var waited := -1.0
				var curb_at := -999.0
				if how == "early":
					_key(KEY_W, true)
				for f in 3600:
					if g.waiting and waited < 0.0:
						waited = g.elapsed
						if how != "early":
							_key(KEY_W, true)
					if how == "space" and waited >= 0.0 and g.near_curb and g.player_pos.y < 470.0:
						_key(KEY_W, false)
						_key(KEY_SPACE, true)
					var before: int = g.jaywalks
					g._process(1.0 / 60.0)
					if how == "space":
						_key(KEY_SPACE, false)
					if g.jaywalks > before:
						curb_at = g.ix.wy + g.scroll + g.IX_H
						break
					if g.state != "play":
						break
				_key(KEY_W, false)
				var ok: bool = g.jaywalks == 1 and curb_at > 120.0
				if not ok:
					bad += 1
				print("%-12s %s %-5s: 等灯 t=%5.1f  闯红灯 t=%5.1f  路缘在屏幕 y=%4.0f  %s" % [LEVELS[li].id, mode, how, waited, g.elapsed, curb_at, "OK" if ok else "失败"])
				g.free()
	quit(1 if bad else 0)
