extends SceneTree
## 字体测试：所有界面文字（locale/messages.pot 的中文原文 + 语言下拉框里的各语言原名）
## 在得意黑子集或内置后备字体里都能显示（避免方框）。新增文字后需重跑 tools/build_fonts.py。

const MainScript := preload("res://scripts/main.gd")


func _initialize() -> void:
	var main_font: Font = load("res://fonts/SmileySans-Oblique.ttf")
	var ui: Font = load("res://fonts/ui_font.tres")
	var fallbacks: Array = ui.fallbacks
	var text := ""
	for line in FileAccess.get_file_as_string("res://locale/messages.pot").split("\n"):
		if line.begins_with("msgid \""):
			text += line.substr(7)
	for l in MainScript.LANGUAGES:
		text += l[1]
	var seen := {}
	var missing := ""
	var fell_back := ""
	for i in text.length():
		var c := text.unicode_at(i)
		if c < 0x80 or seen.has(c):
			continue
		seen[c] = true
		if main_font.has_char(c):
			continue
		var ok := false
		for f in fallbacks:
			if f.has_char(c):
				ok = true
		if ok:
			fell_back += char(c)
		else:
			missing += char(c)
	print("检查了 %d 个非 ASCII 字符；得意黑没有、由后备字体显示的：%s；完全缺字：%s" % [seen.size(),
		fell_back if fell_back != "" else "无", missing if missing != "" else "无"])
	quit(1 if missing != "" else 0)
