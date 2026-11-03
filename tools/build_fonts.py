#!/usr/bin/env python3
"""生成游戏用的子集字体：得意黑（tools/fonts_src/ 原版）+ Noto 可变字体（半粗 600），网页版和桌面版都不再依赖系统字体。
只保留各语言译文实际用到的字符 + ASCII，体积很小。译文更新后重新运行。

用法：python3 tools/build_fonts.py <Noto 字体所在目录>
需要：pip install fonttools brotli
源字体（Google Fonts，SIL OFL 1.1）：NotoSansJP[wght].ttf、NotoSansKR[wght].ttf、
NotoSansArabic[wdth,wght].ttf、NotoSans[wdth,wght].ttf、OFL.txt
"""
import os, sys, shutil
from fontTools.ttLib import TTFont
from fontTools.varLib import instancer
from fontTools import subset

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(ROOT, "tools"))
from check_po import parse  # noqa: E402

ASCII = "".join(chr(c) for c in range(0x20, 0x7F))
PUNCT = "·・、。，！？…—–―〜～（）「」『』：；“”‘’«»¡¿°↑↓←→●○▲▼ 　 "


def po_chars(*langs):
    s = set()
    for l in langs:
        for v in parse(os.path.join(ROOT, f"locale/{l}.po")).values():
            s.update(v)
    return s


TARGETS = [
    # (源文件, 输出名, 字符)
    ("NotoSansJP[wght].ttf", "NotoSansJP-Game.ttf", lambda: po_chars("ja") | set("日本語")),
    ("NotoSansKR[wght].ttf", "NotoSansKR-Game.ttf", lambda: po_chars("ko") | set("한국어")),
    ("NotoSansArabic[wdth,wght].ttf", "NotoSansArabic-Game.ttf", lambda: po_chars("ar") | set("العربية")),
    # 拉丁：越南语声调 + 欧洲语言 + Latin-1 / Latin Extended / 越南语区段
    ("NotoSans[wdth,wght].ttf", "NotoSans-Game.ttf",
     lambda: po_chars("en", "fr", "es", "de", "vi", "pt", "it") | set("Tiếng ViệtFrançaisEspañolPortuguês")
     | {chr(c) for c in list(range(0xA0, 0x250)) + list(range(0x1EA0, 0x1F00)) + list(range(0x300, 0x370))}),
]


def smiley():
    """得意黑子集：中文原文 + 欧洲语言译文用到的字符（原版在 tools/fonts_src/）。"""
    from extract_strings import collect
    chars = set("".join(collect().keys()))
    chars |= po_chars("en", "fr", "es", "de", "pt", "it")
    chars |= {chr(c) for c in range(0xA0, 0x180)}
    chars |= set("简体中文Tiếng ViệtFrançaisEspañolPortuguêsDeutschItalianoEnglish")  # 语言下拉框里的原名
    text = "".join(sorted(chars | set(ASCII) | set(PUNCT)))
    font = TTFont(os.path.join(ROOT, "tools/fonts_src/SmileySans-Oblique.ttf"))
    opts = subset.Options()
    opts.layout_features = ["*"]
    opts.name_IDs = ["*"]
    opts.notdef_outline = True
    sub = subset.Subsetter(opts)
    sub.populate(text=text)
    sub.subset(font)
    path = os.path.join(ROOT, "fonts/SmileySans-Oblique.ttf")
    font.save(path)
    print(f"SmileySans-Oblique.ttf: {len(text)} 字符, {os.path.getsize(path) // 1024} KB")


def build(src_dir):
    smiley()
    out_dir = os.path.join(ROOT, "fonts/noto")
    os.makedirs(out_dir, exist_ok=True)
    for src, out, chars in TARGETS:
        font = TTFont(os.path.join(src_dir, src))
        axes = {a.axisTag: a for a in font["fvar"].axes}
        limits = {"wght": 600}
        if "wdth" in axes:
            limits["wdth"] = 100
        font = instancer.instantiateVariableFont(font, limits)
        text = "".join(sorted(chars() | set(ASCII) | set(PUNCT)))
        opts = subset.Options()
        opts.layout_features = ["*"]        # 保留连写 / 字形替换（阿拉伯文必需）
        opts.name_IDs = ["*"]
        opts.notdef_outline = True
        opts.glyph_names = False
        sub = subset.Subsetter(opts)
        sub.populate(text=text)
        sub.subset(font)
        path = os.path.join(out_dir, out)
        font.save(path)
        print(f"{out}: {len(text)} 字符, {os.path.getsize(path) // 1024} KB")
    shutil.copy(os.path.join(src_dir, "OFL.txt"), os.path.join(out_dir, "OFL.txt"))


if __name__ == "__main__":
    build(sys.argv[1] if len(sys.argv) > 1 else "/tmp/noto_dl")
