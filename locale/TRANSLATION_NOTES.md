# 翻译说明 / Translation notes

游戏：**躲避电鸡 Avoiding Electric Vehicles**。俯视角小游戏：在广州、深圳没有非机动车道的街头，步行、骑车或开车，躲避电动车（中国俗称“电鸡”）、行人和路障。风格轻松搞笑，带一点对现实交通的吐槽。

## 文件
- 源文：`locale/messages.pot`（msgid 是中文原文，即翻译键）。`#:` 注释是代码位置，可打开 `scripts/*.gd` 看上下文。
- 译文：`locale/<lang>.po`，格式同 .pot，填写 msgstr。文件头保留：
  ```
  msgid ""
  msgstr ""
  "Content-Type: text/plain; charset=UTF-8\n"
  "Language: <lang>\n"
  ```
- 校验：`python3 tools/check_po.py locale/<lang>.po` 必须输出 OK。

## 硬性规则
1. **每一条都要翻译**，不能留空，不能增删条目，msgid 一字不改。
2. **占位符 `%s` `%d` `%.1f` 的数量和顺序必须与原文完全相同**（Godot 按顺序填值，不能调换顺序；需要调换语序时改写句子结构）。
3. **BBCode 标签**（`[color=#xxxxxx]…[/color]`、`[center]`、`[font_size=36]`）原样保留、数量一致，只翻译标签之间的文字。
4. **换行 `\n` 数量与原文相同**（例如关卡按钮 `第 %d 关 · %s\n%s\n%s` 是三行）。PO 里换行写成 `\n`，双引号写成 `\"`。
5. 原样保留：`GAME OVER`、`ESC`、`WASD`、`W` `S` `A/D`、`Q`、`F11`、`Retry`/`Menu` 可以翻译、数字、`+50` `+100`、`km/h`、`m`、`↑`、`-15`。
6. `按住 ↑ 或 空格 闯红灯（扣 25% 分）` 里的 `25%` 是普通文字（不是占位符），保留 `25%`。
7. **长度**：界面空间有限。
   - 店铺招牌、摊位名、路名标注（如 `肠粉`、`凉茶铺`、`辅道`、`公交专用`、`前方施工`）尽量 ≤ 12 个拉丁字母或 ≤ 6 个全角字。
   - 角色喊话（`嘀嘀！`、`借过借过！`、`哎哟！`）要短、口语化、有趣。
   - 按钮文字简短。
8. 标点用目标语言习惯（英文不要用全角标点）。

## 术语表（以英文为基准，其他语言保持一致的意思）
| 中文 | English | 说明 |
|---|---|---|
| 躲避电鸡（游戏名） | Avoiding Electric Vehicles | 英文必须用这个官方名；其他语言自然地翻成“躲开电动车”的意思 |
| 电鸡 | e-bike(s) | 中国俗称电动自行车/电瓶车，带调侃意味；用当地对电动自行车/电动踏板车的口语说法 |
| 创飞 | send flying / launch | 无敌模式下把电鸡撞飞，夸张搞笑 |
| 无敌模式 | Invincible Mode | |
| 闯红灯 | run a red light | 行人闯红灯 = jaywalk / cross on red |
| 擦身而过 | near miss | |
| 公交专用道 | bus lane | |
| 辅道 | side road / service road | |
| 非机动车道 | bike lane / non-motorized lane | |
| 绿波 | green wave | 交通信号协调 |
| 外卖 | food delivery | 外卖骑手 = delivery rider |
| 共享单车 | shared bikes | |
| 城中村 | urban village | |
| 骑楼 | arcade buildings (qilou) | 岭南骑楼 |
| 评级 S/A/B/C | rank S/A/B/C | 字母保留 |

## 地名
- 广州 = Guangzhou，深圳 = Shenzhen。
- 欧洲语言 / 越南语：用拼音+意译，如 `天河·体育西路` → `Tianhe · Tiyu West Rd`（法语 `Rue Tiyu Ouest` 等按本地习惯，保持简短）。
- 日语：可直接用日文汉字写法（`天河・体育西路`，简体字转日文字形，如 `广州` → `広州`）。
- 韩语：用韩文音译或惯用名（广州 = 광저우，深圳 = 선전）。
- 阿拉伯语：用阿拉伯字母音译（广州 = قوانغتشو，深圳 = شنجن）。
- 同一个地名在所有条目里写法一致。
