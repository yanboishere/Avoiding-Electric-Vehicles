#!/usr/bin/env python3
"""校验 locale/<lang>.po：覆盖 messages.pot 全部条目、非空、占位符（顺序一致）、BBCode 标签、换行数一致。
用法：python3 tools/check_po.py locale/en.po [更多 .po]"""
import re, sys, os

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PH = re.compile(r"%(?:\.\d+)?[sdf]")
TAG = re.compile(r"\[/?[a-z_]+(?:=[^\]]*)?\]")


def unescape(s):
    out, i = [], 0
    while i < len(s):
        if s[i] == "\\" and i + 1 < len(s):
            out.append({"n": "\n", "t": "\t", '"': '"', "\\": "\\"}.get(s[i + 1], s[i + 1])); i += 2
        else:
            out.append(s[i]); i += 1
    return "".join(out)


def parse(path):
    entries, cur, key = {}, {}, None
    for raw in open(path, encoding="utf-8"):
        line = raw.rstrip("\n")
        if line.startswith("#") or not line.strip():
            if "msgid" in cur and "msgstr" in cur:
                entries[cur["msgid"]] = cur["msgstr"]
                cur = {}
            continue
        m = re.match(r'(msgid|msgstr)\s+"(.*)"$', line)
        if m:
            if m.group(1) == "msgid" and "msgstr" in cur:
                entries[cur["msgid"]] = cur["msgstr"]; cur = {}
            key = m.group(1); cur[key] = unescape(m.group(2)); continue
        m = re.match(r'"(.*)"$', line)
        if m and key:
            cur[key] += unescape(m.group(1)); continue
        raise SystemExit(f"{path}: 无法解析的行: {line!r}")
    if "msgid" in cur and "msgstr" in cur:
        entries[cur["msgid"]] = cur["msgstr"]
    entries.pop("", None)
    return entries


def check(path, pot):
    po = parse(path)
    errs = []
    for k in pot:
        if k not in po:
            errs.append(f"缺少条目: {k[:60]!r}"); continue
        v = po[k]
        if not v.strip():
            errs.append(f"译文为空: {k[:60]!r}"); continue
        if PH.findall(k) != PH.findall(v):
            errs.append(f"占位符不一致（数量和顺序必须相同）: {k[:50]!r} {PH.findall(k)} -> {PH.findall(v)}")
        if sorted(TAG.findall(k)) != sorted(TAG.findall(v)):
            errs.append(f"BBCode 标签不一致: {k[:50]!r}")
        if k.count("\n") != v.count("\n"):
            errs.append(f"换行数不一致（{k.count(chr(10))} vs {v.count(chr(10))}）: {k[:50]!r}")
    extra = [k for k in po if k not in pot]
    if extra:
        errs.append(f"多余条目 {len(extra)} 条（例如 {extra[0][:40]!r}）")
    return errs


if __name__ == "__main__":
    pot = parse(os.path.join(ROOT, "locale/messages.pot"))
    bad = 0
    for p in sys.argv[1:]:
        errs = check(p, pot)
        print(f"{p}: {'OK' if not errs else str(len(errs)) + ' 个问题'}（{len(pot)} 条）")
        for e in errs[:40]:
            print("  -", e)
        bad += bool(errs)
    sys.exit(1 if bad else 0)
