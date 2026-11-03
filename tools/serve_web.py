#!/usr/bin/env python3
"""本地 / 局域网试玩网页版：python3 tools/serve_web.py [端口]（默认 8060），手机连同一个 Wi-Fi 打开 http://<电脑 IP>:端口/
网页版为单线程导出，不需要 COOP/COEP 响应头。"""
import http.server, os, socket, sys

PORT = int(sys.argv[1]) if len(sys.argv) > 1 else 8060
ROOT = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "build", "web")


class Handler(http.server.SimpleHTTPRequestHandler):
    extensions_map = {**http.server.SimpleHTTPRequestHandler.extensions_map,
                      ".wasm": "application/wasm", ".pck": "application/octet-stream", ".js": "text/javascript"}

    def __init__(self, *a, **k):
        super().__init__(*a, directory=ROOT, **k)

    def end_headers(self):
        self.send_header("Cache-Control", "no-cache")
        super().end_headers()


if __name__ == "__main__":
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    try:
        s.connect(("8.8.8.8", 80)); ip = s.getsockname()[0]
    except OSError:
        ip = "127.0.0.1"
    print(f"手机打开： http://{ip}:{PORT}/     电脑打开： http://localhost:{PORT}/")
    http.server.ThreadingHTTPServer(("0.0.0.0", PORT), Handler).serve_forever()
