extends SceneTree
## 信号灯测试：红灯（含清场）不能卡住。记录每个路口每次红灯的实际时长，超过 配置红灯+6 秒即判卡死。

const DriveScript := preload("res://scripts/drive.gd")
const LEVELS: Array = preload("res://scripts/levels.gd").LIST


func _initialize() -> void:
	for a in ["move_left", "move_right", "move_up", "move_down", "jaywalk"]:
		InputMap.add_action(a)
	var only := -1
	var rounds := 1
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--only="):
			only = a.get_slice("=", 1).to_int()
		elif a.begins_with("--rounds="):
			rounds = a.get_slice("=", 1).to_int()
	var bad := 0
	for li in LEVELS.size():
		if only >= 0 and li != only:
			continue
		for rd in rounds:
			var g: Node2D = DriveScript.new()
			g.setup(LEVELS[li], "drive", false, Callable())
			g.god = true
			g.autopilot = true
			root.add_child(g)
			g.countdown = 0.0
			var red_t := {}
			var worst := 0.0
			var reported := false
			var limit: float = float(g.cfg.light[1]) + 6.0
			for f in 3600:
				g._process(1.0 / 60.0)
				for i in g.ixs.size():
					var ix: Dictionary = g.ixs[i]
					if ix.state in ["red", "clear"]:
						red_t[i] = red_t.get(i, 0.0) + 1.0 / 60.0
						worst = maxf(worst, red_t[i])
						if red_t[i] > limit and not reported:
							reported = true
							print("    卡住：路口 %s 状态=%s 已 %.1fs，路口内的横街车：" % [ix.name, ix.state, red_t[i]])
							for e in g.ents:
								if e.type == "xcar" and e.ix == i:
									var gi: Array = g._gap_ahead(e, g.X_MARGIN)
									var who: Dictionary = gi[1]
									print("      xcar x=%.0f y=%.0f v=%.0f 间距=%.0f 挡住它的=%s(%s) @(%.0f,%.0f) v=%.0f" % [e.pos.x, e.pos.y, e.v, gi[0],
										who.get("type", "-"), who.get("kind", ""), who.get("pos", Vector2.ZERO).x, who.get("pos", Vector2.ZERO).y, who.get("v", 0.0)])
					else:
						red_t[i] = 0.0
				if g.state != "play":
					break
			var ok := worst <= limit
			if not ok:
				bad += 1
			print("%-15s %-10s 最长红灯 %.1fs（配置 %.0fs）%s" % [LEVELS[li].id, g.cfg.road, worst, float(g.cfg.light[1]), "OK" if ok else "卡住!"])
			g.free()
	quit(1 if bad else 0)
