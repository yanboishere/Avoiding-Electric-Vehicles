extends SceneTree
## 开车关卡体检：每关多轮自动驾驶，统计到达率、平均距离、非红灯堵车时间、最长红灯、
## 被迫借公交道、堵死被移走的参与者、重叠。用法：--rounds=N

const DriveScript := preload("res://scripts/drive.gd")
const LEVELS: Array = preload("res://scripts/levels.gd").LIST


func _initialize() -> void:
	for a in ["move_left", "move_right", "move_up", "move_down", "jaywalk"]:
		InputMap.add_action(a)
	var rounds := 3
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--rounds="):
			rounds = a.get_slice("=", 1).to_int()
	print("%-15s %-12s %6s %9s %8s %8s %8s %6s %6s" % ["关卡", "路段", "到达", "平均距离", "堵车s", "最长红灯", "借道s", "被移走", "重叠"])
	var only := []
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--only="):
			for x in a.get_slice("=", 1).split(","):
				only.append(x.to_int())
	for li in LEVELS.size():
		if not only.is_empty() and li not in only:
			continue
		var arrive := 0
		var dist := 0.0
		var jam := 0.0
		var max_red := 0.0
		var bypass := 0.0
		var removed := 0
		var overlaps := 0
		var road := ""
		var target := 0
		for rd in rounds:
			var g: Node2D = DriveScript.new()
			g.setup(LEVELS[li], "drive", false, Callable())
			g.god = true
			g.autopilot = true
			root.add_child(g)
			g.countdown = 0.0
			road = g.cfg.road
			target = g.cfg.target_m
			var red_t := {}
			for f in 3600:
				g._process(1.0 / 60.0)
				for i in g.ixs.size():
					red_t[i] = red_t.get(i, 0.0) + 1.0 / 60.0 if g.ixs[i].state in ["red", "clear"] else 0.0
					max_red = maxf(max_red, red_t[i])
				if g.bus_lanes > 0 and g.me.pos.x > g.curb_x - g.bus_lanes * g.LANE_W and g.me.v > 10.0:
					bypass += 1.0 / 60.0
				var all: Array = g.ents.duplicate()
				all.append(g.me)
				for i in all.size():
					for j in range(i + 1, all.size()):
						var a: Dictionary = all[i]
						var b: Dictionary = all[j]
						var red_hit: bool = is_same(b, g.me) and a.type == "xcar" and g.ixs[a.ix].ran_red
						if not red_hit and g._rect(a).grow(-0.75).intersects(g._rect(b).grow(-0.75)):
							overlaps += 1
				if g.state != "play":
					break
			arrive += 1 if g.won else 0
			dist += g.scroll / g.PX_PER_M
			jam += g.jam_t
			removed += g.stuck_removed
			if "--why" in OS.get_cmdline_user_args():
				print("    ", LEVELS[li].id, " 移走:", g.stuck_why, "  堵车:", g.jam_why)
			g.free()
		print("%-15s %-12s %4d/%d %5d/%-4d %7.1f %8.1f %8.1f %6d %6d" % [LEVELS[li].id, road, arrive, rounds,
			int(dist / rounds), target, jam / rounds, max_red, bypass / rounds, removed, overlaps])
	quit()
