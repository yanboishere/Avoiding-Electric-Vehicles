🌐 [简体中文](README.md) · **English** · [日本語](README.ja.md) · [한국어](README.ko.md) · [Français](README.fr.md) · [Español](README.es.md) · [Deutsch](README.de.md) · [العربية](README.ar.md) · [Tiếng Việt](README.vi.md) · [Português](README.pt.md) · [Italiano](README.it.md)

# Avoiding Electric Vehicles

> Many streets in Guangzhou and Shenzhen have no bike lane. You head out on foot, by bike or by car, and e-bikes come at you from every direction: riding the wrong way, overtaking, squeezing through gaps, cutting across, braking without warning... Survive for one minute.

Godot 4 (GL Compatibility) · Windows / macOS · 1280×720 · 12 levels · Walk / Bike / Drive + Invincible Mode

![Main menu](docs/screenshots/menu.jpg)

## How to Play

| Action | Walk / Bike | Drive |
|---|---|---|
| Move | WASD / arrow keys / gamepad stick | W gas · S brake · A / D change lanes |
| Run a red light | Hold ↑ for half a second at the curb, or press Space / gamepad A | Just drive over the stop line on red |
| Pause / Quit | ESC to pause; press Q while paused to return to the menu | Same |
| Fullscreen | F11 or Alt+Enter | Same |

**Goal**
- Walk / Bike: each level lasts 60 seconds. Keep moving forward along the sidewalk; get hit 3 times and you fail.
- Drive: reach the destination within 60 seconds or you're late. Hitting cars, e-bikes or pedestrians costs you a life.

**What you'll run into**
- **E-bikes**: wrong-way riders coming head-on, overtakers from behind (red triangle at the bottom of the screen + "beep beep" warning), weavers, riders bursting out of shops / from the curb, gap-squeezers in traffic, delivery riders who suddenly brake (and become obstacles once stopped), cargo haulers, riders in rain ponchos...
- **Pedestrians**: slow walkers going your way, people walking toward you, phone zombies drifting sideways, people walking side by side, people standing still; when driving there are also people on zebra crossings and jaywalkers.
- **Obstacles**: metro exits, shared bikes, parked e-bikes, stone bollards, stalls; when driving, illegally parked cars, construction barriers and buses pulling into stops. Obstacles are solid; get pushed against the bottom edge of the screen and you'll trip and lose health.
- **Traffic lights**: when walking, the screen stops at a red light, and while you wait e-bikes still run the red and crowd around you; when driving you have to stop yourself. **Running a red light costs 25% of your current score, and getting hit by cross traffic in the junction is instant GAME OVER.**
- **Weather**: in a rainstorm the ground is slick and braking distances get longer; at night the screen goes dark and you have to rely on headlights and streetlights.

**Scoring and ranks**
- The longer you survive / the farther you drive, the higher your score; near miss +50; each life left when you clear a level +300 (driving also adds a bonus for time left).
- Driving in the bus lane costs -15 per second (no penalty when you borrow it to get around road work or illegally parked cars).
- Ranks: S clear with no mistakes · A hit once · B cleared · C failed.
- **Clear a level to unlock the next one**; results are saved automatically.

| Rules page (pops up automatically the first time you play) | Game over screen |
|---|---|
| ![Rules](docs/screenshots/rules.jpg) | ![Results](docs/screenshots/result.jpg) |

## Game Modes

### 🚶 Walk
The most agile: stop and go whenever you like. Dodge e-bikes and pedestrians on the sidewalks of arcade buildings (qilou), glass-fronted shopping streets and urban villages, and wait at red lights at junctions.

![Waiting at a red light on foot](docs/screenshots/red_light.jpg)

### 🚲 Bike
Faster, but with inertia and a bigger hitbox, and much harder to stop in a rainstorm.

![Bike mode](docs/screenshots/bike_mode.jpg)

### 🚗 Drive
Each level switches to a nearby **real road you can actually drive on** (when the pedestrian street or urban-village lane is closed to cars, you take an adjacent road instead): lane count, median, side roads / bike lanes, bus lanes, speed limit and junction names are all based on public information. Bottom left shows your speed, the speed limit sign and the remaining distance; top right shows the signal for the junction ahead.

![Drive mode](docs/screenshots/drive_6.jpg)

### 💥 Invincible Mode
Switch it on with one click on the main menu: no damage, ignore red lights, and every e-bike you hit gets **sent flying** (+100 each, with combos). All 12 levels are open. Pedestrians and vehicles are still solid, so you never clip through them. Invincible Mode scores aren't saved.

| Invincible on foot | Invincible in a car |
|---|---|
| ![Invincible walk](docs/screenshots/invincible_walk.jpg) | ![Invincible drive](docs/screenshots/invincible_drive.jpg) |

## Levels

Guangzhou and Shenzhen alternate, with difficulty increasing. Each level's config lives in `scripts/levels.gd` (the driving roads are in its `DRIVE` section; the comments list the sources for the road info, and anything without exact data is marked "估" (estimated)).

### Level 1 · Guangzhou · Tianhe · Tiyu West Rd
*Guangzhou · Tiyu West Rd*

- **Walk / Bike**: Tutorial: outside Tiyu Xilu metro station, home of the most wrong-way e-bikes. (Old qilou street · 2 junctions (Tianhe South 1st Rd, Tianhe Rd))
- **Drive · Tiyu West Rd**: 6 lanes both ways and heavy traffic. Taxis drop off outside Teemall, delivery e-bikes ride the wrong way along the curb.
  - 6 lanes both ways · central guardrail · limit 50 km/h · destination 380 m · green 8 s / red 6 s · junctions: Tianhe South 1st Rd, Tianhe Rd
  - Road info: Tiyu West Rd runs north–south, 44 m wide, 6 lanes both ways, very heavy traffic (Wikipedia)

| Walk / Bike | Drive |
|---|---|
| ![Level 1 walk](docs/screenshots/walk_0.jpg) | ![Level 1 drive](docs/screenshots/drive_0.jpg) |

### Level 2 · Shenzhen · Futian · Huaqiangbei
*Shenzhen · Huaqiangbei*

- **Walk / Bike**: Outside the electronics market, cargo e-bikes stack boxes taller than people. (Glass-fronted shopping street · 2 junctions (Zhenhua Rd, Hongli Rd))
- **Drive · Zhenhua Rd (one-way)**: Huaqiangbei Rd is pedestrian-only, so take Zhenhua Rd: one-way west to east with an e-bike lane on the right, but the e-bikes insist on using the car lanes.
  - One-way, 3 lanes · bike lane on the right separated by a guardrail · limit 40 km/h · destination 320 m · green 7 s / red 5 s · junctions: Yannan Rd, Huafa North Rd
  - Road info: the Hongli Rd–Shennan section of Huaqiangbei Rd has been a pedestrian street since 2017 and is closed to motor vehicles; Zhenhua Rd is one-way west to east, and since a 2021 pilot of shared car/bike pavement a guardrail separates an e-bike lane on the right (Shenzhen traffic police notice / Nanfang+)

| Walk / Bike | Drive |
|---|---|
| ![Level 2 walk](docs/screenshots/walk_1.jpg) | ![Level 2 drive](docs/screenshots/drive_1.jpg) |

### Level 3 · Guangzhou · Yuexiu · Beijing Rd
*Guangzhou · Beijing Rd*

- **Walk / Bike**: Old arcade-lined (qilou) streets with narrow sidewalks; dessert stalls and bollards block the way, so thread the gaps. (Old qilou street · narrow sidewalk · 2 junctions (Wenming Rd, Zhongshan 5th Rd))
- **Drive · Zhongshan 5th Rd**: Beijing Rd is a pedestrian street, so take Zhongshan 5th Rd: 4 lanes both ways (est.). At evening rush the rightmost lane is a bus lane, with buses pulling in one after another.
  - 4 lanes both ways · double yellow line · rightmost lane is a bus lane · limit 40 km/h · destination 240 m · green 7 s / red 6 s · junctions: Beijing Rd Jct, Jixiang Rd Jct
  - Road info: the middle section of Beijing Rd is a pedestrian street, so cars can only use the crossing Zhongshan Rd (Wikipedia); Zhongshan 5th Rd from Beijing Rd Jct to Jiefang Rd has 30+ bus routes and a peak-hour bus lane (Guangzhou Bendibao); lane count estimated: 4 lanes both ways

| Walk / Bike | Drive |
|---|---|
| ![Level 3 walk](docs/screenshots/walk_2.jpg) | ![Level 3 drive](docs/screenshots/drive_2.jpg) |

### Level 4 · Shenzhen · Nanshan · Science Park
*Shenzhen · Science Park*

- **Walk / Bike**: Lunch delivery rush! Endless beeping behind you, and at red lights every e-bike crowds around you. (Glass-fronted shopping street · 3 junctions (Keyuan Rd, Gaoxin South 1st Rd, Gaoxin South 4th Rd))
- **Drive · Keyuan Rd**: Keyuan Rd is jammed at lunch rush, with delivery e-bikes threading between cars. The lights form a green wave: hold about 40 km/h and hit greens all the way.
  - 7 lanes both ways · central green belt · limit 50 km/h · destination 400 m · green 10 s / red 5 s · **green wave** · junctions: Gaoxin Mid 1st Rd, Gaoxin South 1st Rd, Gaoxin South 4th Rd
  - Road info: Keyuan Rd is badly congested at morning and evening rush; southbound was widened from 3 to 4 lanes (Shenzhen traffic police / Zhihu); northbound 3 lanes (est.); Shenzhen traffic police use AI to optimize signal timing and build green-wave corridors (Shenzhen traffic police), so the three junctions here are coordinated as a green wave

| Walk / Bike | Drive |
|---|---|
| ![Level 4 walk](docs/screenshots/walk_3.jpg) | ![Level 4 drive](docs/screenshots/drive_3.jpg) |

### Level 5 · Guangzhou · Haizhu · Kecun
*Guangzhou · Kecun*

- **Walk / Bike**: Metro exits one after another, and shared bikes piled up like mountains outside. (Old qilou street · 2 junctions (Xingang Middle Rd, Yiyuan Rd))
- **Drive · Xingang Middle Rd**: Haizhu's main artery, limit 60. The rightmost lane is a bus lane, and buses pull in nonstop around Kecun.
  - 6 lanes both ways · central green belt · rightmost lane is a bus lane · limit 60 km/h · destination 450 m · green 9 s / red 6 s · junctions: Xinshitou Rd, Yiyuan Rd
  - Road info: Xingang Rd is a main artery of Haizhu District, 2–6 lanes both ways, limit 60; Xingang Middle Rd has a bus lane (Wikipedia / Sina)

| Walk / Bike | Drive |
|---|---|
| ![Level 5 walk](docs/screenshots/walk_4.jpg) | ![Level 5 drive](docs/screenshots/drive_4.jpg) |

### Level 6 · Shenzhen · Luohu · Dongmen
*Shenzhen · Dongmen*

- **Walk / Bike**: An old shopping district packed with shops; e-bikes can burst out of any doorway. (Glass-fronted shopping street · 2 junctions (Jiefang Rd, Xinyuan Rd))
- **Drive · Dongmen Middle Rd**: 7 lanes both ways, but 2 on each side are bus lanes, so regular cars squeeze into the middle. E-bikes shoot out of shopfronts whenever they feel like it.
  - 7 lanes both ways · double yellow line · rightmost 2 lanes are bus lanes · limit 40 km/h · destination 300 m · green 7 s / red 6 s · junctions: Jiefang Rd, Shaibu Rd
  - Road info: Dongmen Middle Rd originally had 7 lanes both ways, with the 2 rightmost lanes in each direction reserved for buses; private cars entered under odd/even plate rules (Shenzhen Bendibao / Wikipedia)

| Walk / Bike | Drive |
|---|---|
| ![Level 6 walk](docs/screenshots/walk_5.jpg) | ![Level 6 drive](docs/screenshots/drive_5.jpg) |

### Level 7 · Guangzhou · Zhujiang New Town · Huacheng Ave
*Guangzhou · Huacheng Ave*

- **Walk / Bike**: Rainstorm! The ground is slick and hard to stop on, and e-bikers in rain ponchos can't see the road. (Glass-fronted shopping street · rainstorm · 2 junctions (Xiancun Rd, Liede Ave))
- **Drive · Huacheng Ave**: 10 lanes both ways, wide and fast. In a rainstorm visibility is poor and the road is slick, so braking distances get much longer.
  - 10 lanes both ways · central green belt · limit 60 km/h · destination 520 m · green 10 s / red 6 s · junctions: Xiancun Rd, Liede Ave
  - Road info: Huacheng Ave is 71 m wide with 10 lanes both ways, and has a CBD tunnel under Huacheng Square (Wikipedia)

| Walk / Bike | Drive |
|---|---|
| ![Level 7 walk](docs/screenshots/walk_6.jpg) | ![Level 7 drive](docs/screenshots/drive_6.jpg) |

### Level 8 · Shenzhen · Futian · Chegongmiao
*Shenzhen · Chegongmiao*

- **Walk / Bike**: Heading home after late overtime. The streetlights are dim, so only headlights tell you where the e-bikes are. (Glass-fronted shopping street · night · 2 junctions (Tairan 9th Rd, Tian'an Rd))
- **Drive · Shennan Blvd**: Shennan Blvd's main road has 8 lanes both ways plus side roads. Late at night traffic is fast, and e-bikes cut through gaps in the median from the side road.
  - 8 lanes both ways · central green belt · side roads on both sides · limit 60 km/h · destination 480 m · green 10 s / red 6 s · **green wave** · junctions: Tairan 9th Rd, Xiangmei Rd
  - Road info: Shennan Blvd has 6–8 lanes both ways on the main road and 4 lanes both ways on the side roads, limit 60 (Shenzhen Transport Wiki)

| Walk / Bike | Drive |
|---|---|
| ![Level 8 walk](docs/screenshots/walk_7.jpg) | ![Level 8 drive](docs/screenshots/drive_7.jpg) |

### Level 9 · Guangzhou · Tianhe · Shipai Village
*Guangzhou · Shipai Village*

- **Walk / Bike**: An urban village of "handshake buildings": narrow alleys packed with e-bikes, and lots of weaving riders. (Urban-village handshake buildings · narrow sidewalk · 1 junction (Shipai East Rd))
- **Drive · Shipai East Rd**: Right next to Shipai Village: e-bikes burst out of alleys at any moment, and illegally parked cars line the curb.
  - 4 lanes both ways · double yellow line · limit 40 km/h · destination 230 m · green 6 s / red 6 s · junctions: Xintao North St, Xintao South St
  - Road info: Shipai East Rd went from one-way north-to-south back to two-way traffic; Shipai Village has nearly 300 village lanes (Sina / Xinhua); lane count estimated: 4 lanes both ways

| Walk / Bike | Drive |
|---|---|
| ![Level 9 walk](docs/screenshots/walk_8.jpg) | ![Level 9 drive](docs/screenshots/drive_8.jpg) |

### Level 10 · Shenzhen · Nanshan · Baishizhou
*Shenzhen · Baishizhou*

- **Walk / Bike**: The urban-village night market is open, stalls take over the sidewalk, and e-bikes dart through the shadows. (Urban-village handshake buildings · night · narrow sidewalk · 1 junction (Shahe St))
- **Drive · Shennan Side Rd**: The Baishizhou stretch of the Shennan Blvd side road, with the main road beyond the median on the left. Bus stops come one after another, and urban-village e-bikes swarm out of Shahe St.
  - One-way, 2 lanes · green belt (main road beyond it) · rightmost lane is a bus lane · limit 40 km/h · destination 250 m · green 8 s / red 6 s · junctions: Shahe St, Shizhou Middle Rd
  - Road info: on the Baishizhou section of Shennan Blvd there are side roads on both sides of the main road, with several bus stops on the side road near Shahe St (Wikipedia)

| Walk / Bike | Drive |
|---|---|
| ![Level 10 walk](docs/screenshots/walk_9.jpg) | ![Level 10 drive](docs/screenshots/drive_9.jpg) |

### Level 11 · Guangzhou · Baiyun · Xinshixu
*Guangzhou · Xinshixu*

- **Walk / Bike**: A stormy night, slippery and dark, with shared bikes lined up outside the metro exit. (Old qilou street · rainstorm · night · 2 junctions (Airport Rd, Xinshi West St))
- **Drive · Airport Rd**: The airport expressway viaduct runs overhead and its pillars block your view. On a stormy night the road glares, and you can barely see wrong-way e-bikes hugging the curb.
  - 6 lanes both ways · viaduct overhead, pillars as median · limit 50 km/h · destination 360 m · green 8 s / red 6 s · junctions: Qifu Rd, Huiqiao South Rd
  - Road info: Xinshixu station is surrounded by Airport Rd and the Airport Expressway viaduct (Wikipedia); ground-level lane count estimated: 6 lanes both ways

| Walk / Bike | Drive |
|---|---|
| ![Level 11 walk](docs/screenshots/walk_10.jpg) | ![Level 11 drive](docs/screenshots/drive_10.jpg) |

### Level 12 · Shenzhen · Longhua · Minzhi
*Shenzhen · Minzhi*

- **Walk / Bike**: The ultimate evening rush: three red lights, sudden stoppers, cargo haulers, delivery riders and rows of e-bikes all at once. (Glass-fronted shopping street · 3 junctions (Minzhi Ave, Renmin Rd, Meilong Blvd))
- **Drive · Minzhi Ave**: 6 lanes squeezed into a 24 m road, limit 40. Three red lights at evening rush, with sudden stoppers, cargo haulers and gap-squeezing e-bikes all at once.
  - 6 lanes both ways · central guardrail · limit 40 km/h · destination 270 m · green 7 s / red 6 s · junctions: Renmin Rd, Meilong Rd, Gongye Rd
  - Road info: Minzhi Ave is an urban arterial in Longhua District, 24 m wide, limit 40, 6 lanes both ways (Wikipedia)

| Walk / Bike | Drive |
|---|---|
| ![Level 12 walk](docs/screenshots/walk_11.jpg) | ![Level 12 drive](docs/screenshots/drive_11.jpg) |

## Running

Requires [Godot 4.7](https://godotengine.org/download).

```
Godot --path .                                         # 直接玩
Godot -e --path .                                      # 打开编辑器
Godot --path . -- --autostart=drive --level=7 --god    # 跳过菜单直接进关卡（walk/bike/drive，level 0–11），不掉血
Godot --path . -- --unlock-all | --reset-save | --rules | --support | --invincible
```

- `Godot --path .`: play the game
- `Godot -e --path .`: open the editor
- `--autostart=drive --level=7 --god`: skip the menu and jump straight into a level (walk/bike/drive, level 0–11) without taking damage

## Tests
```
Godot --headless --path . --script tests/car_overlap_test.gd   # 步行/骑车：车不重叠、车不压电鸡、路口都出现
Godot --headless --path . --script tests/drive_test.gd         # 开车：自动驾驶跑 12 关，任何参与者互不重叠
Godot --headless --path . --script tests/jaywalk_test.gd       # 闯红灯扣 25%、恢复前进、被车撞 GAME OVER
Godot --headless --path . --script tests/jaywalk_keys_test.gd  # 真实按键：按住 W / 空格 都能闯
Godot --headless --path . --script tests/font_test.gd          # 所有中文字符都能显示（列出得意黑缺、回退系统字体的字）
Godot --headless --path . --script tests/invincible_test.gd    # 无敌模式乱冲：玩家不和任何东西穿模
Godot --headless --path . --script tests/light_test.gd         # 信号灯不会卡在红灯
Godot --headless --path . --script tests/audit_test.gd         # 开车关卡体检：到达率 / 堵车 / 最长红灯 / 借道 / 重叠
```

What each test checks:
- `car_overlap_test.gd`: walk/bike — cars never overlap, cars never run over e-bikes, all junctions appear
- `drive_test.gd`: drive — autopilot runs all 12 levels with no participants overlapping
- `jaywalk_test.gd`: running a red costs 25%, forward movement resumes, getting hit by a car is GAME OVER
- `jaywalk_keys_test.gd`: real key presses — holding W or Space both let you cross on red
- `font_test.gd`: every Chinese character renders (lists characters missing from Smiley Sans that fall back to a system font)
- `invincible_test.gd`: charging around in Invincible Mode — the player never clips through anything
- `light_test.gd`: traffic lights never get stuck on red
- `audit_test.gd`: driving level health check — arrival rate / traffic jams / longest red / lane borrowing / overlaps

Screenshots are generated with `tools/screenshot.gd` (keep the window unobstructed while recording, or add `--always-on-top`):
```
Godot --always-on-top --path . --script tools/screenshot.gd --write-movie /tmp/shot/f.png --fixed-fps 10 --quit-after 200 -- --only=0 --mode=drive
```

## Other
- All graphics and sound are generated procedurally; there are no external art assets.
- Font: [得意黑 Smiley Sans](https://github.com/atelier-anchor/smiley-sans) (SIL OFL 1.1, license in `fonts/SmileySans-OFL.txt`); missing characters fall back to the system Chinese font.
- Save file: `user://save.cfg` (unlock progress, best result per level, travel mode, whether the rules have been shown, Invincible Mode toggle).
- The main menu has a "Support the Dev" page (click an address to copy it); set `SUPPORT_ENABLED` to `false` in `scripts/main.gd` to hide it.
