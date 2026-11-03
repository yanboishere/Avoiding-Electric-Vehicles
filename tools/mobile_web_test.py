#!/usr/bin/env python3
"""用 Chrome 模拟横屏触屏手机，端到端测试网页版：加载 → 菜单 → 点关卡 → 拖摇杆，并截图。
用法：先运行 python3 tools/serve_web.py，再运行 python3 tools/mobile_web_test.py [输出目录]
需要：Google Chrome、pip install websocket-client"""
import base64, json, os, subprocess, sys, time, urllib.request
import websocket

CHROME = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
URL = os.environ.get("GAME_URL", "http://localhost:8060/")  # 测线上版：GAME_URL=https://... python3 tools/mobile_web_test.py
OUT = sys.argv[1] if len(sys.argv) > 1 else "/tmp/mobile_test"
VW, VH = 844, 390  # 横屏手机
os.makedirs(OUT, exist_ok=True)

proc = subprocess.Popen([CHROME, "--headless=new", "--remote-debugging-port=9333", "--use-angle=swiftshader",
                         "--enable-unsafe-swiftshader", "--user-data-dir=/tmp/chrome_mobile_prof", "about:blank"],
                        stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
try:
    for _ in range(50):
        try:
            tabs = json.load(urllib.request.urlopen("http://localhost:9333/json"))
            page = [t for t in tabs if t["type"] == "page"][0]
            break
        except Exception:
            time.sleep(0.2)
    ws = websocket.create_connection(page["webSocketDebuggerUrl"], timeout=60, suppress_origin=True)
    mid = [0]

    def cdp(method, **params):
        mid[0] += 1
        ws.send(json.dumps({"id": mid[0], "method": method, "params": params}))
        while True:
            r = json.loads(ws.recv())
            if r.get("id") == mid[0]:
                return r.get("result", {})

    def shot(name):
        data = cdp("Page.captureScreenshot", format="png")["data"]
        open(os.path.join(OUT, name), "wb").write(base64.b64decode(data))
        print("截图", name)

    # 游戏坐标(1280x720) -> 页面坐标（画面按比例居中）
    scale = min(VW / 1280, VH / 720)
    ox, oy = (VW - 1280 * scale) / 2, (VH - 720 * scale) / 2

    def g2p(x, y):
        return {"x": ox + x * scale, "y": oy + y * scale}

    def touch(kind, pts):
        cdp("Input.dispatchTouchEvent", type=kind, touchPoints=[dict(g2p(*p[1:]), id=p[0]) for p in pts])

    def tap(x, y):
        touch("touchStart", [(0, x, y)])
        time.sleep(0.1)
        touch("touchEnd", [])
        time.sleep(0.8)

    cdp("Emulation.setDeviceMetricsOverride", width=VW, height=VH, deviceScaleFactor=2, mobile=True,
        screenOrientation={"type": "landscapePrimary", "angle": 90})
    cdp("Emulation.setTouchEmulationEnabled", enabled=True, maxTouchPoints=5)
    cdp("Page.enable")
    cdp("Page.navigate", url=URL)
    time.sleep(25)                       # 下载 + 编译 wasm
    shot("1_menu.png")
    tap(232, 286)                        # 第 1 关
    time.sleep(1.5)
    shot("2_after_tap_level.png")        # 第一次玩会先出规则页
    tap(640, 655)                        # “明白了，开始！”
    time.sleep(5)                        # 倒计时
    shot("3_game.png")
    touch("touchStart", [(1, 300, 520)])
    for k in range(1, 13):
        touch("touchMove", [(1, 300 + k * 8, 520)])
        time.sleep(0.12)
    shot("4_joystick_right.png")
    time.sleep(1.0)
    shot("5_joystick_hold.png")
    touch("touchEnd", [])
    tap(640 + 175 + 32, 32)              # 暂停键 II
    time.sleep(0.6)
    shot("6_paused.png")
finally:
    proc.terminate()
