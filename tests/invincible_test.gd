extends SceneTree
## 无敌模式穿模测试：一直往前冲 + 随机左右乱撞（会闯红灯、撞车、撞人），
## 逐帧检查玩家不和横街车 / 行人 / 路障 / 车辆重叠（电鸡撞上就被创飞，不算）。

const GameScript := preload("res://scripts/game.gd")
const DriveScript := preload("res://scripts/drive.gd")
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
	for mode in ["walk", "bike", "drive"]:
		for li in [0, 1, 6, 8, 11]:
			var g: Node2D = DriveScript.new() if mode == "drive" else GameScript.new()
			g.setup(LEVELS[li], mode, false, Callable())
			g.invincible = true
			root.add_child(g)
			g.countdown = 0.0
			_key(KEY_W, true)
			var steer := KEY_A
			var ov := 0
			var printed := 0
			for f in 3600:
				if f % 50 == 0:
					_key(steer, false)
					steer = [KEY_A, KEY_D, KEY_S].pick_random()
					_key(steer, true)
					if mode != "drive" and randf() < 0.3:
						_key(KEY_SPACE, true)
				g._process(1.0 / 60.0)
				_key(KEY_SPACE, false)
				var why := ""
				if mode == "drive":
					var pr: Rect2 = g._rect(g.me).grow(-1.0)
					for e in g.ents:
						if g._rect(e).intersects(pr):
							why = "玩家×%s" % e.type
				else:
					if not g.ix.is_empty():
						for c in g.cross_cars:
							if g._circle_hits_rect(g.player_pos, g.player_r - 1.5, g._cross_rect(c)):
								why = "玩家×横街车"
					for p in g.peds:
						if p.pos.distance_to(g.player_pos) < p.r + g.player_r - 1.5:
							why = "玩家×行人"
					for o in g.obstacles:
						if g._circle_hits_rect(g.player_pos, g.player_r - 1.5, g._orect(o)):
							why = "玩家×路障(%s) 玩家=(%.0f,%.0f) 路障=%s" % [o.type, g.player_pos.x, g.player_pos.y, g._orect(o)]
					for b in g.bikes:
						if b.stopped and g._circle_hits_rect(g.player_pos, g.player_r - 1.5, Rect2(b.pos - Vector2(11, 33), Vector2(22, 66))):
							why = "玩家×停着的电鸡 玩家=(%.0f,%.0f) 电鸡=(%.0f,%.0f)" % [g.player_pos.x, g.player_pos.y, b.pos.x, b.pos.y]
				if why != "":
					ov += 1
					if printed < 3:
						printed += 1
						print("    t=%.1f %s" % [g.elapsed, why])
				if g.state != "play":
					break
			_key(KEY_W, false)
			_key(steer, false)
			if ov > 0:
				bad += 1
			print("%-5s %-15s 创飞=%2d 闯红灯=%d 穿模帧=%d %s" % [mode, LEVELS[li].id, g.launched, g.jaywalks, ov, "OK" if ov == 0 else "穿模!"])
			g.free()
	quit(1 if bad else 0)
