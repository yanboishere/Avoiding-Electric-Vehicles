extends SceneTree
## 字体测试：界面字体为得意黑（Smiley Sans），缺字时回退到系统中文字体。
## 脚本里出现的每个中文字符，得意黑或后备字体至少一个能显示（避免方框），并列出回退的字。
## 注意：后备字体只能检查本机；Windows 上是微软雅黑。

func _initialize() -> void:
	var main_font: Font = load("res://fonts/SmileySans-Oblique.ttf")
	var ui: Font = load("res://fonts/ui_font.tres")
	var fallbacks: Array = ui.fallbacks
	var seen := {}
	var missing := ""
	var fell_back := ""
	for path in ["res://scripts/main.gd", "res://scripts/game.gd", "res://scripts/drive.gd", "res://scripts/levels.gd"]:
		var text := FileAccess.get_file_as_string(path)
		for i in text.length():
			var c := text.unicode_at(i)
			if c >= 0x80 and not seen.has(c):  # 所有非 ASCII 字符（中文、语言名里的韩文 / 阿拉伯文等）
				seen[c] = true
				if not main_font.has_char(c):
					var ok := false
					for f in fallbacks:
						if f.has_char(c):
							ok = true
					if ok:
						fell_back += char(c)
					else:
						missing += char(c)
	print("检查了 %d 个非 ASCII 字符；得意黑缺、改用系统字体显示的：%s；完全缺字：%s" % [seen.size(),
		fell_back if fell_back != "" else "无", missing if missing != "" else "无"])
	quit(1 if missing != "" else 0)
