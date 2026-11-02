#!/usr/bin/env python3
"""提取 scripts/*.gd 里所有含中文的字符串字面量（跳过注释），生成 locale/messages.pot。
中文原文即翻译键（msgid）。用法：python3 tools/extract_strings.py [--list]"""
import re, sys, os, json

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
FILES = ["scripts/main.gd", "scripts/game.gd", "scripts/drive.gd", "scripts/levels.gd"]
# 不翻译的：语言下拉框里各语言的原生名称
EXCLUDE = {"简体中文", "日本語", "한국어", "العربية"}
CJK = re.compile(r"[\u2e80-\u9fff\uac00-\ud7af\uff00-\uffef]")


def literals(code):
    """GDScript 字符串字面量（"..." 与 \"\"\"...\"\"\"），跳过 # 注释。返回 (值, 行号)。"""
    out, i, n, line = [], 0, len(code), 1
    while i < n:
        c = code[i]
        if c == "\n":
            line += 1; i += 1; continue
        if c == "#":
            while i < n and code[i] != "\n":
                i += 1
            continue
        if code.startswith('"""', i):
            j = code.index('"""', i + 3)
            s = code[i + 3:j]
            out.append((s, line)); line += s.count("\n"); i = j + 3; continue
        if c == '"':
            j, buf = i + 1, []
            while code[j] != '"':
                if code[j] == "\\":
                    nxt = code[j + 1]
                    buf.append({"n": "\n", "t": "\t", '"': '"', "\\": "\\"}.get(nxt, "\\" + nxt)); j += 2
                else:
                    buf.append(code[j]); j += 1
            out.append(("".join(buf), line)); i = j + 1; continue
        i += 1
    return out


def collect():
    seen = {}
    for f in FILES:
        code = open(os.path.join(ROOT, f), encoding="utf-8").read()
        for s, ln in literals(code):
            if CJK.search(s) and s not in seen and s not in EXCLUDE:
                seen[s] = f"{f}:{ln}"
    return seen


def po_escape(s):
    return s.replace("\\", "\\\\").replace('"', '\\"').replace("\n", "\\n").replace("\t", "\\t")


if __name__ == "__main__":
    strings = collect()
    if "--list" in sys.argv:
        for s, ref in strings.items():
            print(ref, json.dumps(s, ensure_ascii=False))
        print(len(strings), "strings")
        sys.exit()
    os.makedirs(os.path.join(ROOT, "locale"), exist_ok=True)
    with open(os.path.join(ROOT, "locale/messages.pot"), "w", encoding="utf-8") as fp:
        fp.write('msgid ""\nmsgstr ""\n"Content-Type: text/plain; charset=UTF-8\\n"\n\n')
        for s, ref in strings.items():
            fp.write(f"#: {ref}\nmsgid \"{po_escape(s)}\"\nmsgstr \"\"\n\n")
    print(len(strings), "strings -> locale/messages.pot")
