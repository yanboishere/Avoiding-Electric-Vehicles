🌐 [简体中文](README.md) · [English](README.en.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Français](README.fr.md) · [Español](README.es.md) · **Deutsch** · [العربية](README.ar.md) · [Tiếng Việt](README.vi.md) · [Português](README.pt.md) · [Italiano](README.it.md)

# E-Bikes ausweichen! – Avoiding Electric Vehicles

> In Guangzhou und Shenzhen haben viele Straßen keinen Radweg. Ob du zu Fuß, mit dem Fahrrad oder mit dem Auto unterwegs bist – E-Bikes (auf Chinesisch scherzhaft „Elektro-Hühner“ genannt) tauchen von überall auf: als Geisterfahrer, Überholer, Lückenspringer, Querschießer, Vollbremser … Überlebe eine Minute!

Godot 4 (GL Compatibility) · Windows / macOS · 1280×720 · 12 Level · Zu Fuß / Fahrrad / Auto + Unbesiegbar-Modus

![Hauptmenü](docs/screenshots/menu.jpg)

## So wird gespielt

| Aktion | Zu Fuß / Fahrrad | Auto |
|---|---|---|
| Bewegen | WASD / Pfeiltasten / Gamepad-Stick | W Gas · S Bremse · A / D Spurwechsel |
| Bei Rot gehen/fahren | An der Bordsteinkante ↑ eine halbe Sekunde halten oder Leertaste / Gamepad A | Bei Rot einfach über die Haltelinie fahren |
| Pause / Beenden | ESC Pause, in der Pause Q zurück zum Menü | wie links |
| Vollbild | F11 oder Alt+Enter | wie links |

**Ziel**
- Zu Fuß / Fahrrad: 60 Sekunden pro Level den Gehweg entlang; nach 3 Treffern ist Schluss.
- Auto: in 60 Sekunden ans Ziel, sonst kommst du zu spät; Unfälle mit Autos, E-Bikes oder Fußgängern kosten jeweils ein Leben.

**Was dich erwartet**
- **E-Bikes**: Geisterfahrer von vorn, Überholer von hinten (Warnung durch rotes Dreieck am unteren Bildrand + „Tüt tüt“), Schlangenlinien, Raketen aus Ladentüren / vom Straßenrand, Lückenspringer im Verkehr, plötzliche Vollbremsung zum Ausliefern (danach stehen sie als Hindernis herum), Lastenfahrer, Fahrer im Regencape …
- **Fußgänger**: langsame Vorausgeher, Entgegenkommende, Handystarrer mit Schlingerkurs, Nebeneinandergeher, Stehenbleiber; im Auto zusätzlich Leute auf dem Zebrastreifen und solche, die einfach quer über die Straße laufen.
- **Hindernisse**: U-Bahn-Eingänge, Leihräder, abgestellte E-Bikes, Poller, Stände; im Auto Falschparker, Baustellenzäune und haltende Busse. Hindernisse sind massiv – wirst du an den unteren Bildrand gedrückt, stolperst du und verlierst ein Leben.
- **Ampeln**: Zu Fuß stoppt das Bild bei Rot – auch während du wartest, fahren E-Bikes bei Rot oder drängen sich neben dich; im Auto musst du selbst bremsen. **Bei Rot zu gehen/fahren kostet 25 % der aktuellen Punkte, und wer auf der Kreuzung vom Querverkehr erfasst wird: sofort GAME OVER.**
- **Wetter**: Bei Starkregen ist der Boden glatt und der Bremsweg länger; nachts wird das Bild dunkel, nur Scheinwerfer und Laternen helfen.

**Punkte und Rang**
- Je länger du durchhältst / je weiter du fährst, desto mehr Punkte; knapp vorbei +50; beim Sieg +300 für jedes übrige Leben (im Auto zusätzlich Punkte für die Restzeit).
- Im Auto auf der Busspur: -15 pro Sekunde (Ausweichen um Baustellen oder Falschparker kostet nichts).
- Rang: S fehlerfrei geschafft · A 1 Treffer · B geschafft · C verloren.
- **Jedes Level schaltet das nächste frei**, Ergebnisse werden automatisch gespeichert.

| Regelseite (erscheint beim ersten Spielstart automatisch) | Ergebnis nach Niederlage |
|---|---|
| ![Regeln](docs/screenshots/rules.jpg) | ![Ergebnis](docs/screenshots/result.jpg) |

## Spielmodi

### 🚶 Zu Fuß
Am flexibelsten: jederzeit stehen bleiben und weitergehen. Auf den Gehwegen unter Arkaden (Qilou), in Einkaufsstraßen mit Glasfassaden und in Urban Villages weichst du E-Bikes und Fußgängern aus; an Kreuzungen wartest du auf Grün.

![Zu Fuß an der roten Ampel](docs/screenshots/red_light.jpg)

### 🚲 Fahrrad
Schneller, aber mit Trägheit und größerer Trefferfläche; bei Starkregen kommst du noch schwerer zum Stehen.

![Fahrradmodus](docs/screenshots/bike_mode.jpg)

### 🚗 Auto
Jedes Level wechselt auf einen **echten, befahrbaren Straßenabschnitt** in der Nähe (wo Fußgängerzonen oder Gassen im Urban Village nicht befahrbar sind, geht es über eine Nachbarstraße): Spurenzahl, Mitteltrennung, Nebenfahrbahn / Radweg, Busspuren, Tempolimit und Kreuzungsnamen basieren auf öffentlich zugänglichen Angaben. Unten links siehst du Geschwindigkeit, Tempolimit-Schild und Restdistanz, oben rechts die Ampel der nächsten Kreuzung.

![Automodus](docs/screenshots/drive_6.jpg)

### 💥 Unbesiegbar-Modus
Mit einem Klick im Hauptmenü aktivierbar: kein Schaden, Ampeln egal, jedes E-Bike, das du triffst, wird **wegkatapultiert** (je +100, mit Combos), und alle 12 Level sind offen. Fußgänger und Autos bleiben massiv – kein Durchclippen. Ergebnisse im Unbesiegbar-Modus werden nicht gespeichert.

| Zu Fuß unbesiegbar | Auto unbesiegbar |
|---|---|
| ![Zu Fuß unbesiegbar](docs/screenshots/invincible_walk.jpg) | ![Auto unbesiegbar](docs/screenshots/invincible_drive.jpg) |

## Die Level

Guangzhou und Shenzhen wechseln sich ab, der Schwierigkeitsgrad steigt. Die Konfiguration jedes Levels steht in `scripts/levels.gd` (die Autostrecken im Abschnitt `DRIVE`; in den Kommentaren sind die Quellen zur Straßenlage angegeben, nicht belegbare Werte sind als „geschätzt“ markiert).

### Level 1 · Guangzhou · Tianhe · Tiyu-West-Str.
*Guangzhou · Tiyu West Road*

- **Zu Fuß / Fahrrad**: Einsteigerlevel: vor der U-Bahn Tiyu-West – hier kommen dir die meisten E-Bikes entgegen. (Arkaden-Altstadt · 2 Kreuzungen (Tianhe-Süd-1-Str., Tianhe-Str.))
- **Auto · Tiyu-West-Str.**: 6 Spuren, extrem viel Verkehr, Taxis halten vor der Tianhe City Mall, Liefer-E-Bikes fahren am Rand falsch herum.
  - 6 Spuren (beide Richtungen) · Mittelleitplanke · Tempo 50 km/h · Ziel in 380 m · Grün 8 s / Rot 6 s · Kreuzungen: Tianhe-Süd-1-Str., Tianhe-Str.
  - Quelle: Tiyu-West-Str.: Nord-Süd-Verlauf, 44 m breit, 6 Spuren, extrem hohes Verkehrsaufkommen (Wikipedia)

| Zu Fuß / Fahrrad | Auto |
|---|---|
| ![Level 1 zu Fuß](docs/screenshots/walk_0.jpg) | ![Level 1 Auto](docs/screenshots/drive_0.jpg) |

### Level 2 · Shenzhen · Futian · Huaqiangbei
*Shenzhen · Huaqiang North*

- **Zu Fuß / Fahrrad**: Vor den Elektronikmärkten: Lasten-E-Bikes mit Kartons, höher gestapelt als ein Mensch. (Einkaufsstraße mit Glasfassaden · 2 Kreuzungen (Zhenhua-Str., Hongli-Str.))
- **Auto · Zhenhua-Str. (Einbahn)**: Huaqiangbei ist Fußgängerzone, also Zhenhua-Str.: Einbahnstraße nach Osten, rechts ein E-Bike-Streifen – trotzdem fahren die E-Bikes lieber auf der Fahrbahn.
  - Einbahnstraße, 3 Spuren · rechts ein durch Geländer abgetrennter Radweg · Tempo 40 km/h · Ziel in 320 m · Grün 7 s / Rot 5 s · Kreuzungen: Yannan-Str., Huafa-Nord-Str.
  - Quelle: Die Huaqiangbei-Straße zwischen Hongli-Str. und Shennan-Allee ist seit 2017 Fußgängerzone, Autos sind ausgesperrt; die Zhenhua-Str. ist eine Einbahnstraße von West nach Ost, seit einem Pilotprojekt 2021 trennt rechts ein Geländer einen E-Bike-Streifen ab (Verkehrspolizei Shenzhen / Nanfang+)

| Zu Fuß / Fahrrad | Auto |
|---|---|
| ![Level 2 zu Fuß](docs/screenshots/walk_1.jpg) | ![Level 2 Auto](docs/screenshots/drive_1.jpg) |

### Level 3 · Guangzhou · Yuexiu · Beijing-Str.
*Guangzhou · Beijing Road*

- **Zu Fuß / Fahrrad**: Arkaden-Altstadt (Qilou) mit engem Gehweg: Dessertstände und Poller im Weg, da musst du durch die Lücken. (Arkaden-Altstadt · enger Gehweg · 2 Kreuzungen (Wenming-Str., Zhongshan-5-Str.))
- **Auto · Zhongshan-5-Str.**: Die Beijing-Str. ist Fußgängerzone, also Zhongshan-5-Str.: 4 Spuren (geschätzt), im Feierabendverkehr ganz rechts Busspur, ein Bus nach dem anderen hält.
  - 4 Spuren (beide Richtungen) · doppelte gelbe Linie · ganz rechts 1 Busspur · Tempo 40 km/h · Ziel in 240 m · Grün 7 s / Rot 6 s · Kreuzungen: Ecke Beijing-Str., Ecke Jixiang-Str.
  - Quelle: Der mittlere Teil der Beijing-Str. ist Fußgängerzone, mit dem Auto geht es nur über die kreuzende Zhongshan-Str. (Wikipedia); Zhongshan-5-Str. zwischen Beijing-Str. und Jiefang-Str.; über 30 Buslinien, Busspur zu Stoßzeiten (Guangzhou Bendibao); Spurenzahl geschätzt: 4 Spuren

| Zu Fuß / Fahrrad | Auto |
|---|---|
| ![Level 3 zu Fuß](docs/screenshots/walk_2.jpg) | ![Level 3 Auto](docs/screenshots/drive_2.jpg) |

### Level 4 · Shenzhen · Nanshan · Techpark
*Shenzhen · Science Park*

- **Zu Fuß / Fahrrad**: Mittags-Lieferrausch! Hinter dir hupt es ständig, und bei Rot drängen sich alle E-Bikes um dich. (Einkaufsstraße mit Glasfassaden · 3 Kreuzungen (Keyuan-Str., Gaoxin Süd 1, Gaoxin Süd 4))
- **Auto · Keyuan-Str.**: Mittags staut sich die Keyuan-Str., Liefer-E-Bikes schlängeln sich durch die Lücken; mit Grüner Welle kommst du bei ca. 40km/h ohne Halt durch.
  - 7 Spuren (beide Richtungen) · Grünstreifen in der Mitte · Tempo 50 km/h · Ziel in 400 m · Grün 10 s / Rot 5 s · **Grüne Welle** · Kreuzungen: Gaoxin Mitte 1, Gaoxin Süd 1, Gaoxin Süd 4
  - Quelle: Die Keyuan-Str. ist zu den Stoßzeiten extrem verstopft, Richtung Süden wurde von 3 auf 4 Spuren erweitert (Verkehrspolizei Shenzhen / Zhihu); Richtung Norden 3 Spuren (geschätzt); die Verkehrspolizei Shenzhen optimiert Ampelphasen per KI und schafft Grüne-Welle-Abschnitte (Verkehrspolizei Shenzhen) – hier sind die drei Kreuzungen als Grüne Welle koordiniert

| Zu Fuß / Fahrrad | Auto |
|---|---|
| ![Level 4 zu Fuß](docs/screenshots/walk_3.jpg) | ![Level 4 Auto](docs/screenshots/drive_3.jpg) |

### Level 5 · Guangzhou · Haizhu · Kecun
*Guangzhou · Kecun*

- **Zu Fuß / Fahrrad**: Ein U-Bahn-Ausgang nach dem anderen, davor türmen sich Berge von Leihrädern. (Arkaden-Altstadt · 2 Kreuzungen (Xingang-Mitte-Str., Yiyuan-Str.))
- **Auto · Xingang-Mitte-Str.**: Hauptstraße in Haizhu, Tempo 60, ganz rechts Busspur – rund um Kecun halten ständig Busse.
  - 6 Spuren (beide Richtungen) · Grünstreifen in der Mitte · ganz rechts 1 Busspur · Tempo 60 km/h · Ziel in 450 m · Grün 9 s / Rot 6 s · Kreuzungen: Xinshitou-Str., Yiyuan-Str.
  - Quelle: Xingang-Str.: Hauptverkehrsstraße im Bezirk Haizhu, 2–6 Spuren, Tempo 60; auf der Xingang-Mitte-Str. gibt es eine Busspur (Wikipedia / Sina)

| Zu Fuß / Fahrrad | Auto |
|---|---|
| ![Level 5 zu Fuß](docs/screenshots/walk_4.jpg) | ![Level 5 Auto](docs/screenshots/drive_4.jpg) |

### Level 6 · Shenzhen · Luohu · Dongmen
*Shenzhen · Dongmen*

- **Zu Fuß / Fahrrad**: Altes Einkaufsviertel, Laden an Laden – jederzeit kann ein E-Bike aus einer Tür schießen. (Einkaufsstraße mit Glasfassaden · 2 Kreuzungen (Jiefang-Str., Xinyuan-Str.))
- **Auto · Dongmen-Mitte-Str.**: 7 Spuren, aber je 2 pro Seite sind Busspuren – Autos quetschen sich in die Mitte; vor den Läden schießen jederzeit E-Bikes raus.
  - 7 Spuren (beide Richtungen) · doppelte gelbe Linie · ganz rechts 2 Busspuren · Tempo 40 km/h · Ziel in 300 m · Grün 7 s / Rot 6 s · Kreuzungen: Jiefang-Str., Shaibu-Str.
  - Quelle: Dongmen-Mitte-Str.: ursprünglich 7 Spuren, in beiden Richtungen sind die rechten 2 Spuren Busspuren, Privatautos fahren nach gerader/ungerader Kennzeichen-Regel (Shenzhen Bendibao / Wikipedia)

| Zu Fuß / Fahrrad | Auto |
|---|---|
| ![Level 6 zu Fuß](docs/screenshots/walk_5.jpg) | ![Level 6 Auto](docs/screenshots/drive_5.jpg) |

### Level 7 · Guangzhou · Zhujiang-Neustadt · Huacheng-Allee
*Guangzhou · Huacheng Avenue*

- **Zu Fuß / Fahrrad**: Starkregen! Rutschiger Boden, kaum zu bremsen, und E-Biker im Regencape sehen nichts. (Einkaufsstraße mit Glasfassaden · Starkregen · 2 Kreuzungen (Xiancun-Str., Liede-Allee))
- **Auto · Huacheng-Allee**: 10 Spuren, breit und schnell; bei Starkregen schlechte Sicht, glatte Fahrbahn und deutlich längerer Bremsweg.
  - 10 Spuren (beide Richtungen) · Grünstreifen in der Mitte · Tempo 60 km/h · Ziel in 520 m · Grün 10 s / Rot 6 s · Kreuzungen: Xiancun-Str., Liede-Allee
  - Quelle: Huacheng-Allee: 71 m breit, 10 Spuren, am Huacheng-Platz mit CBD-Tunnel (Wikipedia)

| Zu Fuß / Fahrrad | Auto |
|---|---|
| ![Level 7 zu Fuß](docs/screenshots/walk_6.jpg) | ![Level 7 Auto](docs/screenshots/drive_6.jpg) |

### Level 8 · Shenzhen · Futian · Chegongmiao
*Shenzhen · Chegongmiao*

- **Zu Fuß / Fahrrad**: Spät nach Überstunden heim, schummrige Laternen – nur Scheinwerfer verraten, wo die E-Bikes sind. (Einkaufsstraße mit Glasfassaden · Nacht · 2 Kreuzungen (Tairan-9-Str., Tian'an-Str.))
- **Auto · Shennan-Allee**: Shennan-Allee: 8 Spuren plus Nebenfahrbahnen, nachts wird gerast, E-Bikes schießen durch Lücken im Grünstreifen auf die Hauptfahrbahn.
  - 8 Spuren (beide Richtungen) · Grünstreifen in der Mitte · Nebenfahrbahnen auf beiden Seiten · Tempo 60 km/h · Ziel in 480 m · Grün 10 s / Rot 6 s · **Grüne Welle** · Kreuzungen: Tairan-9-Str., Xiangmei-Str.
  - Quelle: Shennan-Allee: Hauptfahrbahn 6–8 Spuren, Nebenfahrbahnen 4 Spuren, Tempo 60 (Shenzhen Transport Wiki)

| Zu Fuß / Fahrrad | Auto |
|---|---|
| ![Level 8 zu Fuß](docs/screenshots/walk_7.jpg) | ![Level 8 Auto](docs/screenshots/drive_7.jpg) |

### Level 9 · Guangzhou · Tianhe · Dorf Shipai
*Guangzhou · Shipai Village*

- **Zu Fuß / Fahrrad**: Urban Village mit „Handschlaghäusern“: enge Gassen voller geparkter E-Bikes, viele fahren Schlangenlinien. (Urban Village mit Handschlaghäusern · enger Gehweg · 1 Kreuzung (Shipai-Ost-Str.))
- **Auto · Shipai-Ost-Str.**: Direkt am Dorf Shipai: aus jeder Gasse kann ein E-Bike schießen, am Rand ein Falschparker nach dem anderen.
  - 4 Spuren (beide Richtungen) · doppelte gelbe Linie · Tempo 40 km/h · Ziel in 230 m · Grün 6 s / Rot 6 s · Kreuzungen: Xintao-Nordgasse, Xintao-Südgasse
  - Quelle: Shipai-Ost-Str.: von Einbahnstraße (Nord→Süd) wieder auf Gegenverkehr umgestellt; im Dorf Shipai gibt es fast 300 Gassen (Sina / Xinhua); Spurenzahl geschätzt: 4 Spuren

| Zu Fuß / Fahrrad | Auto |
|---|---|
| ![Level 9 zu Fuß](docs/screenshots/walk_8.jpg) | ![Level 9 Auto](docs/screenshots/drive_8.jpg) |

### Level 10 · Shenzhen · Nanshan · Baishizhou
*Shenzhen · Baishizhou*

- **Zu Fuß / Fahrrad**: Nachtmarkt im Urban Village: Stände auf dem Gehweg, E-Bikes flitzen durchs Halbdunkel. (Urban Village mit Handschlaghäusern · Nacht · enger Gehweg · 1 Kreuzung (Shahe-Gasse))
- **Auto · Shennan-Nebenfahrbahn**: Nebenfahrbahn der Shennan-Allee bei Baishizhou, links hinter dem Grünstreifen die Hauptfahrbahn; Bushalt an Bushalt, und aus der Shahe-Gasse strömen E-Bikes aus dem Urban Village.
  - Einbahn, 2 Spuren · Grünstreifen (dahinter die Hauptfahrbahn) · ganz rechts 1 Busspur · Tempo 40 km/h · Ziel in 250 m · Grün 8 s / Rot 6 s · Kreuzungen: Shahe-Gasse, Shizhou-Mitte-Str.
  - Quelle: Shennan-Allee bei Baishizhou: Nebenfahrbahnen auf beiden Seiten der Hauptfahrbahn, nahe der Shahe-Gasse mehrere Bushaltestellen auf der Nebenfahrbahn (Wikipedia)

| Zu Fuß / Fahrrad | Auto |
|---|---|
| ![Level 10 zu Fuß](docs/screenshots/walk_9.jpg) | ![Level 10 Auto](docs/screenshots/drive_9.jpg) |

### Level 11 · Guangzhou · Baiyun · Xinshixu
*Guangzhou · Xinshixu*

- **Zu Fuß / Fahrrad**: Regennacht, glatt und dunkel, vor dem U-Bahn-Eingang reihen sich die Leihräder. (Arkaden-Altstadt · Starkregen · Nacht · 2 Kreuzungen (Flughafenstr., Xinshi-Westgasse))
- **Auto · Flughafenstr.**: Über dir die Flughafen-Hochstraße, Pfeiler versperren die Sicht, nachts im Starkregen spiegelt die Fahrbahn – Geister-E-Bikes am Rand sieht man kaum.
  - 6 Spuren (beide Richtungen) · Hochstraße darüber, Trennung durch Brückenpfeiler · Tempo 50 km/h · Ziel in 360 m · Grün 8 s / Rot 6 s · Kreuzungen: Qifu-Str., Huiqiao-Süd-Str.
  - Quelle: Rund um die U-Bahn-Station Xinshixu verlaufen die Flughafenstr. und die Hochstraße der Flughafen-Schnellstraße (Wikipedia); Spurenzahl der Straße darunter geschätzt: 6 Spuren

| Zu Fuß / Fahrrad | Auto |
|---|---|
| ![Level 11 zu Fuß](docs/screenshots/walk_10.jpg) | ![Level 11 Auto](docs/screenshots/drive_10.jpg) |

### Level 12 · Shenzhen · Longhua · Minzhi
*Shenzhen · Minzhi*

- **Zu Fuß / Fahrrad**: Ultimativer Feierabendverkehr: drei Ampeln, Vollbremser, Lastenfahrer, Lieferanten und E-Bikes in Reihe – alle sind da. (Einkaufsstraße mit Glasfassaden · 3 Kreuzungen (Minzhi-Allee, Renmin-Str., Meilong-Allee))
- **Auto · Minzhi-Allee**: 6 Spuren auf 24 m Breite, Tempo 40, drei Ampeln im Feierabendverkehr – Vollbremser, Lastenfahrer und Lückenspringer, alle sind da.
  - 6 Spuren (beide Richtungen) · Mittelleitplanke · Tempo 40 km/h · Ziel in 270 m · Grün 7 s / Rot 6 s · Kreuzungen: Renmin-Str., Meilong-Str., Gongye-Str.
  - Quelle: Minzhi-Allee: städtische Hauptverkehrsstraße im Bezirk Longhua, 24 m breit, Tempo 40, 6 Spuren (Wikipedia)

| Zu Fuß / Fahrrad | Auto |
|---|---|
| ![Level 12 zu Fuß](docs/screenshots/walk_11.jpg) | ![Level 12 Auto](docs/screenshots/drive_11.jpg) |

## Starten

Benötigt [Godot 4.7](https://godotengine.org/download).

```
Godot --path .                                         # direkt spielen
Godot -e --path .                                      # Editor öffnen
Godot --path . -- --autostart=drive --level=7 --god    # Menü überspringen, direkt ins Level (walk/bike/drive, level 0–11), kein Schaden
Godot --path . -- --unlock-all | --reset-save | --rules | --support | --invincible
```

## Tests
```
Godot --headless --path . --script tests/car_overlap_test.gd   # Zu Fuß/Fahrrad: Autos überlappen nicht, fahren nicht über E-Bikes, alle Kreuzungen erscheinen
Godot --headless --path . --script tests/drive_test.gd         # Auto: Autopilot fährt alle 12 Level, kein Verkehrsteilnehmer überlappt mit einem anderen
Godot --headless --path . --script tests/jaywalk_test.gd       # Bei Rot: 25 % Abzug, Weiterlaufen funktioniert, angefahren = GAME OVER
Godot --headless --path . --script tests/jaywalk_keys_test.gd  # Echte Tasten: W / Leertaste halten funktioniert beides
Godot --headless --path . --script tests/font_test.gd          # Alle chinesischen Zeichen werden angezeigt (listet Zeichen, die Smiley Sans fehlen und auf Systemschrift zurückfallen)
Godot --headless --path . --script tests/invincible_test.gd    # Wild herumrasen im Unbesiegbar-Modus: Spieler clippt durch nichts
Godot --headless --path . --script tests/light_test.gd         # Ampeln bleiben nicht auf Rot hängen
Godot --headless --path . --script tests/audit_test.gd         # Check der Autolevel: Ankunftsquote / Stau / längste Rotphase / Ausweichen / Überlappung
```

Screenshots werden mit `tools/screenshot.gd` erzeugt (bei der Aufnahme das Fenster nicht verdecken oder `--always-on-top` verwenden):
```
Godot --always-on-top --path . --script tools/screenshot.gd --write-movie /tmp/shot/f.png --fixed-fps 10 --quit-after 200 -- --only=0 --mode=drive
```

## Web / Mobil

Im Browser auf Handy und Tablet ohne Tastatur oder Gamepad spielbar (Touch-Steuerung erscheint automatisch).
- Touch: links drücken und ziehen = Joystick (im Auto Spurwechsel); im Auto Gas / Bremse unten rechts; zu Fuß erscheint an der Bordsteinkante ein „Bei Rot gehen“-Knopf; II oben pausiert. Bitte im Querformat spielen.
- Export: `Godot --headless --path . --export-release "Web" build/web/index.html` (Single-Thread, läuft auf jedem statischen Hosting)
- Lokal / im WLAN testen: `python3 tools/serve_web.py`, dann die angezeigte Adresse auf einem Handy im selben WLAN öffnen
- End-to-End-Test (Chrome emuliert ein Touch-Handy im Querformat): `python3 tools/mobile_web_test.py`; Touch-Unittest: `tests/touch_test.gd`
- Browser haben keine Systemschriften, daher nutzen Japanisch, Koreanisch, Arabisch und Vietnamesisch die Noto-Teilschriften in `fonts/noto/` (erzeugt mit `tools/build_fonts.py`)

## Sonstiges
- Grafik und Sound werden komplett prozedural erzeugt, es gibt keine externen Grafik-Assets.
- Schrift: [得意黑 Smiley Sans](https://github.com/atelier-anchor/smiley-sans) (SIL OFL 1.1, Lizenz in `fonts/SmileySans-OFL.txt`); fehlende Zeichen fallen auf die chinesische Systemschrift zurück.
- Speicherort: `user://save.cfg` (Freischaltfortschritt, Bestwerte pro Level, Fortbewegungsart, ob die Regeln schon angezeigt wurden, Unbesiegbar-Schalter).
- Im Hauptmenü gibt es die Seite „Entwickler unterstützen“ (Adresse anklicken zum Kopieren); in `scripts/main.gd` lässt sie sich ausblenden, indem man `SUPPORT_ENABLED` auf `false` setzt.
