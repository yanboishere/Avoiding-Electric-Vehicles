🌐 [简体中文](README.md) · [English](README.en.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · **Français** · [Español](README.es.md) · [Deutsch](README.de.md) · [العربية](README.ar.md) · [Tiếng Việt](README.vi.md) · [Português](README.pt.md) · [Italiano](README.it.md)

# Esquive les scooters (Avoiding Electric Vehicles)

> À Guangzhou et Shenzhen, beaucoup de rues n'ont pas de piste cyclable. Que tu sortes à pied, à vélo ou en voiture, les scooters électriques surgissent de partout : à contresens, en dépassement, en se faufilant, en déboulant, en pilant net… Survis une minute.

Godot 4 (GL Compatibility) · Windows / macOS · 1280×720 · 12 niveaux · à pied / à vélo / en voiture + mode invincible

![Menu principal](docs/screenshots/menu.jpg)

## Comment jouer

| Action | À pied / à vélo | En voiture |
|---|---|---|
| Se déplacer | WASD / flèches / joystick de la manette | W accélérer · S freiner · A / D changer de voie |
| Griller le feu | Devant le trottoir, maintenir ↑ une demi-seconde, ou Espace / bouton A de la manette | Au rouge, franchir directement la ligne d'arrêt |
| Pause / quitter | ESC pour la pause, puis Q pour revenir au menu | Idem |
| Plein écran | F11 ou Alt+Entrée | Idem |

**Objectif**
- À pied / à vélo : 60 secondes par niveau, avance tout droit sur le trottoir ; 3 chocs et c'est perdu.
- En voiture : arrive à destination en moins de 60 secondes, sinon tu es en retard ; percuter une voiture, un scooter ou un piéton coûte une vie.

**Ce que tu vas croiser**
- **Scooters** : à contresens, dépassement par-derrière (alerte triangle rouge en bas de l'écran + « bip-bip »), zigzags, sorties de boutique / de trottoir, faufilage dans le trafic, coups de frein soudains pour livrer (le scooter arrêté devient un obstacle), chargements de colis, ponchos de pluie…
- **Piétons** : marcheurs lents dans ton sens, passants en face, nez sur le téléphone qui dévient, groupes côte à côte, immobiles ; en voiture, il y a aussi ceux qui prennent le passage piéton ou traversent n'importe où.
- **Obstacles** : bouches de métro, vélos partagés, scooters garés, bornes en pierre, étals ; en voiture, voitures mal garées, palissades de chantier, bus à l'arrêt. Les obstacles sont solides : coincé contre le bas de l'écran, tu trébuches et perds une vie.
- **Feux** : à pied, l'écran s'arrête au rouge, et pendant l'attente des scooters grillent le feu ou se collent à toi ; en voiture, c'est à toi de freiner. **Griller un feu coûte 25% de ton score actuel, et si une voiture de la rue transversale te touche au carrefour, c'est GAME OVER direct.**
- **Météo** : sous l'averse, la chaussée glisse et le freinage s'allonge ; la nuit, l'écran s'assombrit, seuls les phares et les lampadaires t'aident à y voir.

**Score et rang**
- Plus tu tiens / roules loin, plus tu marques ; frôlement +50 ; à la fin du niveau, chaque vie restante +300 (plus un bonus de temps restant en voiture).
- En voiture, rouler sur la voie de bus coûte -15 par seconde (pas de pénalité si c'est pour contourner un chantier ou une voiture mal garée).
- Rang : S sans faute · A touché 1 fois · B réussi · C échec.
- **Il faut finir un niveau pour débloquer le suivant** ; la progression est sauvegardée automatiquement.

| Page des règles (s'affiche au premier lancement) | Écran d'échec |
|---|---|
| ![Règles](docs/screenshots/rules.jpg) | ![Résultats](docs/screenshots/result.jpg) |

## Modes de jeu

### 🚶 À pied
Le plus souple : tu t'arrêtes et repars quand tu veux. Esquive scooters et piétons sur les trottoirs des rues à arcades (qilou), des rues commerçantes vitrées et des villages urbains ; aux carrefours, attends le vert.

![À pied, au feu rouge](docs/screenshots/red_light.jpg)

### 🚲 À vélo
Plus rapide, mais avec de l'inertie et une zone de collision plus grande ; sous l'averse, le vélo a encore plus de mal à s'arrêter.

![Mode vélo](docs/screenshots/bike_mode.jpg)

### 🚗 En voiture
Chaque niveau passe sur une **vraie rue praticable en voiture** à proximité (quand la rue piétonne ou les ruelles du village urbain sont interdites aux voitures, on prend une rue voisine) : nombre de voies, séparateur central, contre-allées / pistes cyclables, voies de bus, limitations et noms des carrefours s'appuient sur des données publiques. En bas à gauche : vitesse, panneau de limitation et distance restante ; en haut à droite : le feu du prochain carrefour.

![Mode voiture](docs/screenshots/drive_6.jpg)

### 💥 Mode invincible
S'active d'un clic sur l'accueil : aucun dégât, feux rouges ignorés, et tous les scooters touchés sont **envoyés valser** (+100 chacun, avec combos) ; les 12 niveaux sont ouverts. Piétons et véhicules restent solides, pas de traversée de modèles. Les scores du mode invincible ne sont pas sauvegardés.

| Invincible à pied | Invincible en voiture |
|---|---|
| ![Invincible à pied](docs/screenshots/invincible_walk.jpg) | ![Invincible en voiture](docs/screenshots/invincible_drive.jpg) |

## Les niveaux

Guangzhou et Shenzhen alternent, avec une difficulté croissante. La configuration de chaque niveau se trouve dans `scripts/levels.gd` (les rues en voiture sont dans `DRIVE` ; les commentaires citent les sources sur l'état des routes, et les données introuvables sont marquées « 估 » = estimé).

### Niveau 1 · Guangzhou · Tianhe · Rue Tiyu Ouest
*Guangzhou · Tiyu West Road*

- **À pied / à vélo** : Niveau débutant : devant le métro Tiyu Ouest, les scooters à contresens pullulent. (vieille rue à arcades · 2 carrefours (Rue Tianhe Sud 1, Rue Tianhe))
- **En voiture · Rue Tiyu Ouest** : 2×3 voies, trafic énorme, taxis qui déposent devant Teemall, scooters de livreurs à contresens le long du trottoir.
  - 2×3 voies · glissière centrale · limité à 50 km/h · destination à 380 m · vert 8 s / rouge 6 s · carrefours : Rue Tianhe Sud 1, Rue Tianhe
  - Sources : rue Tiyu Ouest : axe nord-sud, 44 m de large, 2×3 voies, trafic très dense (Wikipédia)

| À pied / à vélo | En voiture |
|---|---|
| ![Niveau 1 à pied](docs/screenshots/walk_0.jpg) | ![Niveau 1 en voiture](docs/screenshots/drive_0.jpg) |

### Niveau 2 · Shenzhen · Futian · Huaqiang Nord
*Shenzhen · Huaqiang North*

- **À pied / à vélo** : Devant le marché électronique, les scooters de livraison portent des cartons plus hauts qu'un homme. (rue commerçante vitrée · 2 carrefours (Rue Zhenhua, Rue Hongli))
- **En voiture · Rue Zhenhua (sens unique)** : Huaqiang Nord est piétonne, on passe par la rue Zhenhua : sens unique ouest-est, avec une voie à droite pour les scooters… qui préfèrent rouler avec les voitures.
  - Sens unique 3 voies · piste cyclable à droite séparée par une glissière · limité à 40 km/h · destination à 320 m · vert 7 s / rouge 5 s · carrefours : Rue Yannan, Rue Huafa Nord
  - Sources : la rue Huaqiang Nord, entre la rue Hongli et l'av. Shennan, est piétonne depuis 2017, interdite aux véhicules ; la rue Zhenhua est à sens unique ouest-est, avec depuis 2021 une chaussée partagée expérimentale et une voie pour scooters séparée par une glissière à droite (avis de la police routière de Shenzhen / Nanfang+)

| À pied / à vélo | En voiture |
|---|---|
| ![Niveau 2 à pied](docs/screenshots/walk_1.jpg) | ![Niveau 2 en voiture](docs/screenshots/drive_1.jpg) |

### Niveau 3 · Guangzhou · Yuexiu · Rue de Pékin
*Guangzhou · Beijing Road*

- **À pied / à vélo** : Vieille rue à arcades (qilou), trottoir étroit, étals de desserts et bornes en pierre : faufile-toi. (vieille rue à arcades · trottoir étroit · 2 carrefours (Rue Wenming, Rue Zhongshan 5))
- **En voiture · Rue Zhongshan 5** : La rue de Pékin est piétonne, on passe par la rue Zhongshan 5 : 2×2 voies (estimé), voie de bus à droite à l'heure de pointe, et les bus s'arrêtent à la chaîne.
  - 2×2 voies · double ligne jaune · 1 voie de bus à droite · limité à 40 km/h · destination à 240 m · vert 7 s / rouge 6 s · carrefours : Carref. Pékin, Carref. Jixiang
  - Sources : le centre de la rue de Pékin est piéton, en voiture on ne peut emprunter que la rue Zhongshan qui la croise (Wikipédia) ; rue Zhongshan 5, du carrefour de la rue de Pékin à la rue Jiefang : plus de trente lignes de bus, voie de bus aux heures de pointe (Guangzhou Bendibao) ; nombre de voies estimé : 2×2

| À pied / à vélo | En voiture |
|---|---|
| ![Niveau 3 à pied](docs/screenshots/walk_2.jpg) | ![Niveau 3 en voiture](docs/screenshots/drive_2.jpg) |

### Niveau 4 · Shenzhen · Nanshan · Parc techno
*Shenzhen · Science Park*

- **À pied / à vélo** : Rush des livraisons de midi ! Ça klaxonne derrière toi, et au feu rouge les scooters se collent à toi. (rue commerçante vitrée · 3 carrefours (Rue Keyuan, Gaoxin Sud 1, Gaoxin Sud 4))
- **En voiture · Rue Keyuan** : Bouchons sur la rue Keyuan à midi, les scooters de livreurs se faufilent ; onde verte aux carrefours : à ~40 km/h, tout est vert.
  - 7 voies · terre-plein central · limité à 50 km/h · destination à 400 m · vert 10 s / rouge 5 s · **onde verte** · carrefours : Gaoxin Centre 1, Gaoxin Sud 1, Gaoxin Sud 4
  - Sources : la rue Keyuan est extrêmement embouteillée aux heures de pointe, le sens sud est passé de 3 à 4 voies (police routière de Shenzhen / Zhihu) ; sens nord 3 voies (estimé) ; la police routière de Shenzhen optimise les feux par IA pour créer des ondes vertes (police routière de Shenzhen), les trois carrefours sont donc coordonnés en onde verte

| À pied / à vélo | En voiture |
|---|---|
| ![Niveau 4 à pied](docs/screenshots/walk_3.jpg) | ![Niveau 4 en voiture](docs/screenshots/drive_3.jpg) |

### Niveau 5 · Guangzhou · Haizhu · Kecun
*Guangzhou · Kecun*

- **À pied / à vélo** : Sorties de métro à la chaîne, et devant, des montagnes de vélos partagés. (vieille rue à arcades · 2 carrefours (Rue Xingang Centre, Rue Yiyuan))
- **En voiture · Rue Xingang Centre** : Grand axe de Haizhu limité à 60, voie de bus à droite, bus en rafale aux arrêts de Kecun.
  - 2×3 voies · terre-plein central · 1 voie de bus à droite · limité à 60 km/h · destination à 450 m · vert 9 s / rouge 6 s · carrefours : Rue Xinshitou, Rue Yiyuan
  - Sources : rue Xingang : grand axe du district de Haizhu, de 2 à 6 voies dans les deux sens, limité à 60 ; voie de bus sur la rue Xingang Centre (Wikipédia / Sina)

| À pied / à vélo | En voiture |
|---|---|
| ![Niveau 5 à pied](docs/screenshots/walk_4.jpg) | ![Niveau 5 en voiture](docs/screenshots/drive_4.jpg) |

### Niveau 6 · Shenzhen · Luohu · Dongmen
*Shenzhen · Dongmen*

- **À pied / à vélo** : Vieux quartier commerçant bourré de boutiques : un scooter peut en jaillir à tout moment. (rue commerçante vitrée · 2 carrefours (Rue Jiefang, Rue Xinyuan))
- **En voiture · Rue Dongmen Centre** : 7 voies, mais 2 voies de bus de chaque côté : les voitures s'entassent au milieu ; les scooters jaillissent des boutiques sans prévenir.
  - 7 voies · double ligne jaune · 2 voies de bus à droite · limité à 40 km/h · destination à 300 m · vert 7 s / rouge 6 s · carrefours : Rue Jiefang, Rue Shaibu
  - Sources : rue Dongmen Centre : à l'origine 7 voies, avec 2 voies de bus à droite dans chaque sens, accès des voitures particulières selon les plaques paires / impaires (Shenzhen Bendibao / Wikipédia)

| À pied / à vélo | En voiture |
|---|---|
| ![Niveau 6 à pied](docs/screenshots/walk_5.jpg) | ![Niveau 6 en voiture](docs/screenshots/drive_5.jpg) |

### Niveau 7 · Guangzhou · Zhujiang Xincheng · Av. Huacheng
*Guangzhou · Huacheng Avenue*

- **À pied / à vélo** : Averse ! Le sol glisse, impossible de freiner, et les scooters en poncho n'y voient rien. (rue commerçante vitrée · averse · 2 carrefours (Rue Xiancun, Av. Liede))
- **En voiture · Av. Huacheng** : 2×5 voies, large et rapide ; sous l'averse, visibilité réduite, chaussée glissante, freinage bien plus long.
  - 2×5 voies · terre-plein central · limité à 60 km/h · destination à 520 m · vert 10 s / rouge 6 s · carrefours : Rue Xiancun, Av. Liede
  - Sources : avenue Huacheng : 71 m de large, 2×5 voies, tunnel du CBD au niveau de la place Huacheng (Wikipédia)

| À pied / à vélo | En voiture |
|---|---|
| ![Niveau 7 à pied](docs/screenshots/walk_6.jpg) | ![Niveau 7 en voiture](docs/screenshots/drive_6.jpg) |

### Niveau 8 · Shenzhen · Futian · Chegongmiao
*Shenzhen · Chegongmiao*

- **À pied / à vélo** : Retour tardif après le boulot, éclairage faiblard : seuls les phares trahissent les scooters. (rue commerçante vitrée · nuit · 2 carrefours (Rue Tairan 9, Rue Tian'an))
- **En voiture · Av. Shennan** : Axe central de l'av. Shennan en 2×4 voies avec contre-allées ; la nuit ça roule vite, et les scooters coupent par les trouées du terre-plein.
  - 2×4 voies · terre-plein central · contre-allées des deux côtés · limité à 60 km/h · destination à 480 m · vert 10 s / rouge 6 s · **onde verte** · carrefours : Rue Tairan 9, Rue Xiangmei
  - Sources : avenue Shennan : axe central de 2×3 à 2×4 voies, contre-allées en 2×2 voies, limité à 60 (wiki des transports de Shenzhen)

| À pied / à vélo | En voiture |
|---|---|
| ![Niveau 8 à pied](docs/screenshots/walk_7.jpg) | ![Niveau 8 en voiture](docs/screenshots/drive_7.jpg) |

### Niveau 9 · Guangzhou · Tianhe · Village Shipai
*Guangzhou · Shipai Village*

- **À pied / à vélo** : Village urbain aux immeubles collés, ruelles étroites pleines de scooters garés, et ça zigzague dans tous les sens. (village urbain aux immeubles collés · trottoir étroit · 1 carrefour (Rue Shipai Est))
- **En voiture · Rue Shipai Est** : Collée au village Shipai : des scooters surgissent des ruelles, et les voitures mal garées s'enchaînent.
  - 2×2 voies · double ligne jaune · limité à 40 km/h · destination à 230 m · vert 6 s / rouge 6 s · carrefours : Rue Xintao Nord, Rue Xintao Sud
  - Sources : rue Shipai Est : ancien sens unique nord-sud repassé à double sens ; près de 300 ruelles dans le village Shipai (Sina / Xinhuanet) ; nombre de voies estimé : 2×2

| À pied / à vélo | En voiture |
|---|---|
| ![Niveau 9 à pied](docs/screenshots/walk_8.jpg) | ![Niveau 9 en voiture](docs/screenshots/drive_8.jpg) |

### Niveau 10 · Shenzhen · Nanshan · Baishizhou
*Shenzhen · Baishizhou*

- **À pied / à vélo** : Le marché de nuit du village urbain ouvre, les étals mangent le trottoir, les scooters filent dans la pénombre. (village urbain aux immeubles collés · nuit · trottoir étroit · 1 carrefour (Rue Shahe))
- **En voiture · Contre-allée Shennan** : Contre-allée Shennan à Baishizhou, l'axe central derrière le terre-plein à gauche ; arrêts de bus en série, et les scooters du village urbain déferlent de la rue Shahe.
  - Sens unique 2 voies · terre-plein (axe central au-delà) · 1 voie de bus à droite · limité à 40 km/h · destination à 250 m · vert 8 s / rouge 6 s · carrefours : Rue Shahe, Rue Shizhou Centre
  - Sources : avenue Shennan, tronçon de Baishizhou : contre-allées de chaque côté de l'axe central, plusieurs arrêts de bus sur la contre-allée près de la rue Shahe (Wikipédia)

| À pied / à vélo | En voiture |
|---|---|
| ![Niveau 10 à pied](docs/screenshots/walk_9.jpg) | ![Niveau 10 en voiture](docs/screenshots/drive_9.jpg) |

### Niveau 11 · Guangzhou · Baiyun · Xinshixu
*Guangzhou · Xinshixu*

- **À pied / à vélo** : Nuit d'averse, glissante et noire, et des vélos partagés alignés devant le métro. (vieille rue à arcades · averse · nuit · 2 carrefours (Rue de l'Aéroport, Rue Xinshi Ouest))
- **En voiture · Rue de l'Aéroport** : Sous le viaduc de l'autoroute de l'aéroport : piles qui cachent la vue, chaussée qui brille sous l'averse, impossible de voir les scooters à contresens.
  - 2×3 voies · viaduc au-dessus, piles en séparateur · limité à 50 km/h · destination à 360 m · vert 8 s / rouge 6 s · carrefours : Rue Qifu, Rue Huiqiao Sud
  - Sources : autour de la station Xinshixu passent la rue de l'Aéroport et le viaduc de l'autoroute de l'aéroport (Wikipédia) ; nombre de voies au sol estimé : 2×3

| À pied / à vélo | En voiture |
|---|---|
| ![Niveau 11 à pied](docs/screenshots/walk_10.jpg) | ![Niveau 11 en voiture](docs/screenshots/drive_10.jpg) |

### Niveau 12 · Shenzhen · Longhua · Minzhi
*Shenzhen · Minzhi*

- **À pied / à vélo** : Heure de pointe ultime : trois feux rouges, coups de frein, livraisons, colis et scooters en rangs serrés. (rue commerçante vitrée · 3 carrefours (Av. Minzhi, Rue Renmin, Av. Meilong))
- **En voiture · Av. Minzhi** : 6 voies serrées sur 24 m, limité à 40, trois feux rouges à l'heure de pointe : scooters qui pilent, livrent ou se faufilent, tout y est.
  - 2×3 voies · glissière centrale · limité à 40 km/h · destination à 270 m · vert 7 s / rouge 6 s · carrefours : Rue Renmin, Rue Meilong, Rue Gongye
  - Sources : avenue Minzhi : artère principale du district de Longhua, 24 m de large, limitée à 40, 2×3 voies (Wikipédia)

| À pied / à vélo | En voiture |
|---|---|
| ![Niveau 12 à pied](docs/screenshots/walk_11.jpg) | ![Niveau 12 en voiture](docs/screenshots/drive_11.jpg) |

## Lancer le jeu

Nécessite [Godot 4.7](https://godotengine.org/download).

```
Godot --path .                                         # 直接玩
Godot -e --path .                                      # 打开编辑器
Godot --path . -- --autostart=drive --level=7 --god    # 跳过菜单直接进关卡（walk/bike/drive，level 0–11），不掉血
Godot --path . -- --unlock-all | --reset-save | --rules | --support | --invincible
```

- `Godot --path .` : jouer directement
- `Godot -e --path .` : ouvrir l'éditeur
- `--autostart=drive --level=7 --god` : sauter le menu et lancer directement un niveau (walk/bike/drive, level 0–11), sans perdre de vie

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

- `car_overlap_test.gd` : à pied / à vélo, les voitures ne se chevauchent pas, n'écrasent pas les scooters, et tous les carrefours apparaissent
- `drive_test.gd` : en voiture, pilote automatique sur les 12 niveaux, aucun participant ne se chevauche
- `jaywalk_test.gd` : griller le feu retire 25%, la marche reprend, et une voiture provoque le GAME OVER
- `jaywalk_keys_test.gd` : vraies touches, maintenir W ou Espace permet de griller le feu
- `font_test.gd` : tous les caractères chinois s'affichent (liste ceux absents de Smiley Sans qui passent par la police système)
- `invincible_test.gd` : en mode invincible, le joueur ne traverse jamais rien
- `light_test.gd` : les feux ne restent jamais bloqués au rouge
- `audit_test.gd` : bilan de santé des niveaux en voiture (taux d'arrivée / bouchons / plus long rouge / contournements / chevauchements)

Les captures d'écran sont générées avec `tools/screenshot.gd` (pendant l'enregistrement, garde la fenêtre bien visible, ou ajoute `--always-on-top`) :
```
Godot --always-on-top --path . --script tools/screenshot.gd --write-movie /tmp/shot/f.png --fixed-fps 10 --quit-after 200 -- --only=0 --mode=drive
```

## Web / Mobile

Jouable dans le navigateur d'un téléphone ou d'une tablette, sans clavier ni manette (les commandes tactiles apparaissent automatiquement).
- Tactile : appuie et glisse sur la moitié gauche = joystick (changement de voie en voiture) ; gaz / frein en bas à droite en voiture ; un bouton « griller le feu » apparaît au bord du trottoir à pied ; II en haut pour la pause. Joue en mode paysage.
- Export : `Godot --headless --path . --export-release "Web" build/web/index.html` (mono-thread, n'importe quel hébergement statique)
- Test local / réseau : `python3 tools/serve_web.py`, puis ouvre l'adresse affichée sur un téléphone du même Wi-Fi
- Test de bout en bout (Chrome émulant un téléphone tactile en paysage) : `python3 tools/mobile_web_test.py` ; test unitaire tactile : `tests/touch_test.gd`
- Les navigateurs n'ont pas de polices système : japonais, coréen, arabe et vietnamien utilisent les sous-ensembles Noto de `fonts/noto/` (générés par `tools/build_fonts.py`)

## Divers
- Graphismes et sons sont entièrement générés par le code, sans aucune ressource graphique externe.
- Police : [得意黑 Smiley Sans](https://github.com/atelier-anchor/smiley-sans) (SIL OFL 1.1, licence dans `fonts/SmileySans-OFL.txt`) ; les caractères manquants passent par la police chinoise du système.
- Sauvegarde : `user://save.cfg` (progression, meilleur score par niveau, mode de déplacement, règles déjà vues, mode invincible activé ou non).
- L'accueil propose une page « Soutenir l'auteur » (clique sur une adresse pour la copier) ; mets `SUPPORT_ENABLED` à `false` dans `scripts/main.gd` pour la masquer.
