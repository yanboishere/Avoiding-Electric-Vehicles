extends SceneTree
## 截图用：--only=N --mode=walk|bike|drive [--inv]，自动驾驶 / 原地不动
const GameScript := preload("res://scripts/game.gd")
const DriveScript := preload("res://scripts/drive.gd")
const MainScript := preload("res://scripts/main.gd")
const LEVELS: Array = preload("res://scripts/levels.gd").LIST

func _initialize() -> void:
	ThemeDB.fallback_font = load("res://fonts/ui_font.tres")
	var m = MainScript.new()
	m._setup_input()
	m.free()
	var li := 0
	var mode := "walk"
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--only="):
			li = a.get_slice("=", 1).to_int()
		elif a.begins_with("--mode="):
			mode = a.get_slice("=", 1)
	var g: Node2D = DriveScript.new() if mode == "drive" else GameScript.new()
	g.setup(LEVELS[li], mode, false, Callable())
	g.god = true
	g.invincible = "--inv" in OS.get_cmdline_user_args()
	if mode == "drive":
		g.autopilot = true
	root.add_child(g)
	_g = g


var _g: Node2D
var _last := 0
var _frame := 0


func _process(_d: float) -> bool:
	_frame += 1
	if _g and _g.launched != _last:
		_last = _g.launched
		print("LAUNCH %d" % _frame)
	return false
