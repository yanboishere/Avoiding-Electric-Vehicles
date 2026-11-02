# 躲避电鸡 Avoiding Electric Vehicles

Godot 4 (GL Compatibility) · Windows / macOS · 1280×720

在广州、深圳没有非机动车道的路段，步行或骑车，用 WASD / 方向键 / 手柄躲开随机出现的电动车，坚持 60 秒通关。

## 运行
```
/Applications/Godot.app/Contents/MacOS/Godot --path ~/AvoidingEV          # 直接玩
/Applications/Godot.app/Contents/MacOS/Godot -e --path ~/AvoidingEV       # 打开编辑器
... --path ~/AvoidingEV -- --autostart=walk --level=1   # 跳过菜单直接进关卡（walk/bike，level 0/1）
```

## 当前内容（v0.4）
- **三种出行方式**：步行（灵活）/ 骑车（有惯性）/ **开车**（`scripts/drive.gd`）
- **12 关**（广州 6 / 深圳 6），通关前一关才解锁下一关；关卡配置在 `scripts/levels.gd`
  - 步行 / 骑车：人行道场景，每关 60 秒，含路口红绿灯、地铁口、共享单车、摊位、暴雨、夜间等
  - 开车：每关对应一条真实路段（`levels.gd` 的 `DRIVE`，注释里写了资料来源，查不到的标“估”），
    60 秒内开到目的地；车道数、中央隔离、辅道 / 非机动车道、公交专用道、限速、路口名都按真实路况
- **行人**：三种模式都有，按正常速度和路线走（人行道靠右走、红灯在路缘等、开车模式走斑马线 / 安全岛 / 偶尔横穿马路），撞到扣命
- **无敌模式**（主页开关）：不掉血、无视红灯，撞到的电鸡全部创飞（每只 +100），12 关全开，成绩不计入存档
- 闯红灯：扣当前分数 25%，在路口里被横街车撞直接 GAME OVER（步行按住 ↑ / 空格；开车直接冲线）
- 信号灯：主路绿灯不短于红灯；科苑路、深南大道按绿波协调；清场最多 2.5 秒，不会卡在红灯
- **支持作者**页面（主页按钮，点击地址复制；`main.gd` 里 `SUPPORT_ENABLED` 可关闭）
- 车辆、电鸡全部用“沿行驶方向不超过前方间距”的规则移动，测试保证互不重叠、路口不会卡死
- 字体：系统中文字体（Mac 冬青黑体 / 黑体-简，Windows 微软雅黑），不打包字体文件
- 存档 `user://save.cfg`；首次开始游戏先展示规则页

## 测试
```
Godot --headless --path . --script tests/car_overlap_test.gd   # 步行/骑车：车不重叠、车不压电鸡、路口都出现
Godot --headless --path . --script tests/drive_test.gd         # 开车：自动驾驶跑 12 关，任何参与者互不重叠
Godot --headless --path . --script tests/jaywalk_test.gd       # 闯红灯扣 25%、恢复前进、被车撞 GAME OVER
Godot --headless --path . --script tests/jaywalk_keys_test.gd  # 真实按键：按住 W / 空格 都能闯
Godot --headless --path . --script tests/font_test.gd          # 所有中文字符字体都能显示
Godot --headless --path . --script tests/invincible_test.gd    # 无敌模式乱冲：玩家不和任何东西穿模
Godot --headless --path . --script tests/light_test.gd         # 信号灯不会卡在红灯
Godot --headless --path . --script tests/audit_test.gd         # 开车关卡体检：到达率 / 堵车 / 最长红灯 / 借道 / 重叠
Godot --path . -- --autostart=drive --level=7 --god             # 直接开第 8 关，不掉血
Godot --path . -- --unlock-all / --reset-save / --rules / --invincible
```

## 导出 Steam 版本
1. Godot 编辑器 → Editor → Manage Export Templates → 下载 4.7.2 模板
2. `Godot --headless --path . --export-release "Windows Desktop" build/windows/AvoidingEV.exe`
3. `Godot --headless --path . --export-release "macOS" build/macos/AvoidingEV.zip`
4. 正式上架 mac 需要 Apple Developer 签名 + 公证（export_presets.cfg 当前为 ad-hoc 签名）
5. 接入 Steamworks（成就/云存档）可用 GodotSteam 插件
