extends SceneTree
## 字体测试：脚本里出现的每个中文字符，界面字体都必须能显示（避免出现方框）。
## 注意：只能检查本机的系统字体；Windows 上用微软雅黑。

func _initialize() -> void:
	var font: Font = load("res://fonts/ui_font.tres")
	var seen := {}
	var missing := ""
	for path in ["res://scripts/main.gd", "res://scripts/game.gd", "res://scripts/drive.gd", "res://scripts/levels.gd"]:
		var text := FileAccess.get_file_as_string(path)
		for i in text.length():
			var c := text.unicode_at(i)
			if c >= 0x2E80 and not seen.has(c):
				seen[c] = true
				if not font.has_char(c):
					missing += char(c)
	print("检查了 %d 个中文字符，缺字：%s" % [seen.size(), missing if missing != "" else "无"])
	quit(1 if missing != "" else 0)
