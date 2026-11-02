extends SceneTree
## 无头测试：同车道车辆不应重叠。用法：Godot --headless --path . --script tests/car_overlap_test.gd

const GameScript := preload("res://scripts/game.gd")
const LEVELS: Array = preload("res://scripts/levels.gd").LIST


func _initialize() -> void:
	for a in ["move_left", "move_right", "move_up", "move_down", "jaywalk"]:
		InputMap.add_action(a)
	var bad := 0
	for lv in LEVELS:
		for mode in ["walk", "bike"]:
			var g: Node2D = GameScript.new()
			g.setup(lv, mode, false, Callable())
			g.god = true
			root.add_child(g)
			g.countdown = 0.0
			var worst := 999.0
			var in_band := 0
			var car_bike := 0
			var ped_ov := 0
			var max_peds := 0
			for f in 3600:  # 60 秒 @ 60fps
				g._process(1.0 / 60.0)
				for a in g.cars:
					for b in g.cars:
						if not is_same(a, b) and a.up == b.up:
							worst = minf(worst, absf(a.pos.y - b.pos.y))
							if absf(a.pos.y - b.pos.y) < 88.0 and not a.has("_dbg"):
								a._dbg = true
								print("    主路 t=%.2f up=%s y1=%.1f y2=%.1f vel=%.0f/%.0f 灯=%s top=%.0f" % [g.elapsed, a.up, a.pos.y, b.pos.y, a.vel, b.vel, g.ix.get("state", "-"), g.ix.get("wy", 0.0) + g.scroll])
				for a in g.cross_cars:
					for b in g.cross_cars:
						if not is_same(a, b) and a.dir == b.dir and absf(a.lane_y - b.lane_y) < 40.0:
							worst = minf(worst, absf(a.x - b.x))
							if absf(a.x - b.x) < 88.0 and not a.has("_dbg"):
								a._dbg = true
								print("    横街 t=%.2f dir=%d x1=%.1f x2=%.1f lane=%.0f/%.0f hold=%s/%s bike=%s/%s 灯=%s" % [g.elapsed, a.dir, a.x, b.x, a.lane_y, b.lane_y, a.get("holding", false), b.get("holding", false), not a.bike.is_empty(), not b.bike.is_empty(), g.ix.state])
				if g._red_active():
					var top: float = g.ix.wy + g.scroll
					for c in g.cars:
						if c.pos.y - 44.0 < top + g.IX_H - 4.0 and c.pos.y + 44.0 > top + 4.0 and top > -200.0:
							if not c.has("_rep"):
								c._rep = true
								in_band += 1
								print("  红灯时主路车在路口内: t=%.1f up=%s y=%.0f top=%.0f state=%s vel=%.0f" % [g.elapsed, c.up, c.pos.y, top, g.ix.state, c.vel])
				# 车压到电鸡：只统计新产生的重叠
				for b in g.bikes:
					var br: Rect2 = g._bike_rect(b.pos)
					var hit_now := false
					var why := ""
					for c in g.cars:
						if Rect2(c.pos.x - 23.0, c.pos.y - 44.0, 46.0, 88.0).intersects(br):
							hit_now = true
							why = "主路车 x=%.0f y=%.0f" % [c.pos.x, c.pos.y]
					if not g.ix.is_empty():
						for c in g.cross_cars:
							if g._cross_rect(c).intersects(br):
								hit_now = true
								why = "横街车 x=%.0f dir=%d holding=%s inside=%s" % [c.x, c.dir, c.get("holding", false), g._car_inside(c)]
					if hit_now and not b.get("_ov", false):
						car_bike += 1
						print("    t=%.1f 电鸡 %s pos=(%.0f,%.0f) t=%.2f xwait=%s 灯=%s | %s" % [g.elapsed, b.kind, b.pos.x, b.pos.y, b.t, b.get("xwait", false), g.ix.get("state", "-"), why])
					b._ov = hit_now
				# 行人：和行人 / 路障 / 电鸡 / 玩家 / 横街车都不能重叠
				var rects: Array = g._solid_rects()
				for pi in g.peds.size():
					var p: Dictionary = g.peds[pi]
					var why := ""
					for pj in range(pi + 1, g.peds.size()):
						if p.pos.distance_to(g.peds[pj].pos) < p.r + g.peds[pj].r - 1.0:
							why = "行人×行人"
					for r in rects:
						if g._circle_hits_rect(p.pos, p.r - 1.0, r):
							why = "行人×路障"
					for b in g.bikes:
						if g._bike_seg_dist(p.pos, b.pos, b.rot) < p.r + 11.0 - 1.0:
							why = "行人×电鸡(%s)" % b.kind
					if p.pos.distance_to(g.player_pos) < p.r + g.player_r - 1.0:
						why = "行人×玩家"
					if not g.ix.is_empty():
						for c in g.cross_cars:
							if g._circle_hits_rect(p.pos, p.r - 1.0, g._cross_rect(c)):
								why = "行人×横街车"
					if why != "" and not p.get("_ov", false):
						ped_ov += 1
						print("    t=%.1f %s kind=%s pos=(%.0f,%.0f)" % [g.elapsed, why, p.kind, p.pos.x, p.pos.y])
					p._ov = why != ""
				for b in g.bikes:
					if g._bike_seg_dist(g.player_pos, b.pos, b.rot) < g.player_r + 11.0 - 1.5 and not b.get("_pov", false):
						ped_ov += 1
						print("    t=%.1f 电鸡×玩家 kind=%s" % [g.elapsed, b.kind])
						b._pov = true
				if g.state != "play":
					break
			var ok: bool = worst >= 88.0 and in_band == 0 and car_bike == 0 and ped_ov == 0 and g.ix_index == lv.crossings.size()  # 车长 88
			if not ok:
				bad += 1
			print("%-15s %s: 最小车距 %5.1f  路口 %d/%d  车压电鸡 %d  行人相关重叠 %d  %s" % [lv.id, mode, worst, g.ix_index, lv.crossings.size(), car_bike, ped_ov, "OK" if ok else "重叠!"])
			g.free()
	quit(1 if bad > 0 else 0)
