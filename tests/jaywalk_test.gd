extends SceneTree
## 无头测试：闯红灯扣 25% 分数，路口里被车撞直接 GAME OVER。

const GameScript := preload("res://scripts/game.gd")
const LEVELS: Array = preload("res://scripts/levels.gd").LIST


func _initialize() -> void:
	for a in ["move_left", "move_right", "move_up", "move_down", "jaywalk"]:
		InputMap.add_action(a)
	var g: Node2D = GameScript.new()
	g.setup(LEVELS[0], "walk", false, Callable())
	root.add_child(g)
	g.countdown = 0.0
	g.lives = 99  # 只测闯红灯，避免中途被电鸡撞死
	var f := 0
	while not g.waiting and f < 60 * 40:
		g._process(1.0 / 60.0)
		f += 1
	print("等红灯开始 t=%.1f waiting=%s" % [g.elapsed, g.waiting])
	g.player_pos.x = (g.PLAY_L + g.PLAY_R) / 2.0
	for i in 300:  # 先走到路缘（路缘前可能有等灯的行人，挤过去要多一点时间）
		Input.action_press("move_up")
		g._process(1.0 / 60.0)
		if g.jaywalks > 0 or g.push_t > 0.3:
			break
	print("走到路缘：y=%.0f 路缘=%.0f 附近行人=%d push_t=%.2f near_curb=%s" % [g.player_pos.y, g.ix.wy + g.scroll + g.IX_H, g.peds.size(), g.push_t, g.near_curb])
	var before: float = g.score
	var penalty_ok := false
	for i in 60:
		var s0: float = g.score
		g._process(1.0 / 60.0)
		if g.jaywalks > 0:
			penalty_ok = absf(g.score - (s0 + 10.0 / 60.0) * 0.75) < 1.0 or absf(g.score - s0 * 0.75) < 1.0
			break
	Input.action_release("move_up")
	g._process(1.0 / 60.0)  # 下一帧滚动才恢复
	var resumed: bool = not g.waiting and g.scroll_rate > 0.0
	print("闯红灯次数=%d  扣分前=%.0f 扣分后=%.0f  扣25%%=%s  画面恢复前进=%s" % [g.jaywalks, before, g.score, penalty_ok, resumed])
	# 把玩家放到一辆横街车上，应直接 GAME OVER
	var tries := 0
	while g.cross_cars.is_empty() and tries < 600:
		g._process(1.0 / 60.0)
		tries += 1
	var killed := false
	if not g.cross_cars.is_empty():
		g.player_pos = g._cross_rect(g.cross_cars[0]).get_center()
		g.invuln = 1.0  # 有受击无敌也照样结束
		g._check_traffic()
		killed = g.run_over and g.state == "over" and g.lives == 0
	print("被车撞 GAME OVER=%s" % killed)
	quit(0 if g.jaywalks == 1 and penalty_ok and killed and resumed else 1)
