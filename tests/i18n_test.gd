extends SceneTree
## 多语言测试：每种语言 —— 译文已加载生效、每个字符在该语言使用的字体里都能显示（不出方框）。
## 字体选择与 main.gd 一致：日韩阿越用系统字体，其他用得意黑 + 系统中文字体兜底。
## 字体都内置在 fonts/ 下，检查结果与平台无关（桌面 / 网页一致）。

const MainScript := preload("res://scripts/main.gd")


func _initialize() -> void:
	var main_font: Font = load("res://fonts/SmileySans-Oblique.ttf")
	var ui: Font = load("res://fonts/ui_font.tres")
	var all_fonts: Array = [main_font] + ui.fallbacks
	var fonts: Dictionary = MainScript.LOCALE_FONTS
	var bad := 0
	for l in MainScript.LANGUAGES:
		var loc: String = l[0]
		if loc == "zh_CN":
			continue
		var path := "res://locale/%s.po" % loc
		if not FileAccess.file_exists(path):
			print("%-5s 缺少译文文件 %s" % [loc, path])
			bad += 1
			continue
		var t: Translation = load(path)
		TranslationServer.set_locale(loc)
		var sample: String = TranslationServer.translate("出发！")
		var primary: Font = main_font
		if fonts.has(loc.substr(0, 2)):
			primary = load(fonts[loc.substr(0, 2)])
		var missing := {}
		var fell_back := {}
		for msg in t.get_message_list():
			var s: String = t.get_message(msg)
			for i in s.length():
				var c := s.unicode_at(i)
				if c < 0x20 or c == 0x200F or c == 0x200E:
					continue
				if primary.has_char(c):
					continue
				var found := false
				for f in all_fonts:
					if f.has_char(c):
						found = true
				if found:
					fell_back[char(c)] = true
				else:
					missing[char(c)] = true
		var ok := missing.is_empty() and sample != "出发！"
		if not ok:
			bad += 1
		print("%-5s 条目 %d  “出发！”→“%s”  由后备字体显示的字：%s  缺字：%s  %s" % [loc, t.get_message_count(), sample,
			"".join(fell_back.keys()) if not fell_back.is_empty() else "无", "".join(missing.keys()) if not missing.is_empty() else "无", "OK" if ok else "失败"])
	quit(1 if bad else 0)
