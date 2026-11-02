extends SceneTree
## 开车模式无头测试：自动驾驶跑完 12 关，逐帧检查任意两个交通参与者（含玩家）矩形不重叠，
## 并记录能否 60 秒内到达、路口与红灯情况。

const DriveScript := preload("res://scripts/drive.gd")
const LEVELS: Array = preload("res://scripts/levels.gd").LIST


func _initialize() -> void:
	for a in ["move_left", "move_right", "move_up", "move_down", "jaywalk"]:
		InputMap.add_action(a)
	var bad := 0
	var only := -1
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--only="):
			only = a.get_slice("=", 1).to_int()
	for li in LEVELS.size():
		if only >= 0 and li != only:
			continue
		var lv: Dictionary = LEVELS[li]
		var g: Node2D = DriveScript.new()
		g.setup(lv, "drive", false, Callable())
		g.god = true
		g.autopilot = true
		root.add_child(g)
		g.countdown = 0.0
		var overlaps := 0
		var seen := {}
		var max_ents := 0
		var printed := 0
		for f in 3700:
			g._process(1.0 / 60.0)
			max_ents = maxi(max_ents, g.ents.size())
			var all: Array = g.ents.duplicate()
			all.append(g.me)
			for i in all.size():
				for j in range(i + 1, all.size()):
					var a: Dictionary = all[i]
					var b: Dictionary = all[j]
					# 闯红灯后被横街车撞是规则内的（正式游戏直接 GAME OVER），不算重叠 bug
					var red_hit: bool = is_same(b, g.me) and a.type == "xcar" and g.ixs[a.ix].ran_red
					if not red_hit and g._rect(a).grow(-0.75).intersects(g._rect(b).grow(-0.75)):
						var key := str(a.get_or_add("_id", randi())) + "_" + str(b.get_or_add("_id", randi()))
						if not seen.has(key):
							seen[key] = true
							overlaps += 1
							if printed < 6:
								printed += 1
								print("    t=%.2f %s(%s) @(%.0f,%.0f) v=%.0f  ×  %s(%s) @(%.0f,%.0f) v=%.0f" % [g.elapsed,
									a.type, a.get("kind", ""), a.pos.x, a.pos.y, a.v, b.type, b.get("kind", ""), b.pos.x, b.pos.y, b.v])
			if g.state != "play":
				break
		var ok: bool = overlaps == 0
		if not ok:
			bad += 1
		print("%-15s %-12s 到达=%s 用时=%4.1f 距离=%3d/%3d 撞=%d 红灯等=%.1fs 闯红灯=%d 公交道扣=%d 最多参与者=%d 重叠=%d %s" % [
			lv.id, g.cfg.road, g.won, g.elapsed, int(g.scroll / g.PX_PER_M), int(g.cfg.target_m), g.hits, g.wait_total,
			g.jaywalks, g.bus_pen, max_ents, overlaps, "OK" if ok else "重叠!"])
		g.free()
	quit(1 if bad else 0)
