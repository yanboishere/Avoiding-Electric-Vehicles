🌐 [简体中文](README.md) · [English](README.en.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Français](README.fr.md) · [Español](README.es.md) · [Deutsch](README.de.md) · [العربية](README.ar.md) · [Tiếng Việt](README.vi.md) · [Português](README.pt.md) · **Italiano**

▶ **Gioca nel browser (telefono / PC)**: https://yanbowa.ng/Avoiding-Electric-Vehicles/

# Schiva le e-bike · Avoiding Electric Vehicles

> In molte strade di Guangzhou e Shenzhen non ci sono piste ciclabili. Esci a piedi, in bici o in auto, e le bici elettriche (in cinese, scherzosamente, "电鸡", "galline elettriche") spuntano da ogni parte: contromano, sorpassi, infilate tra le auto, scatti improvvisi, inchiodate… Sopravvivi per un minuto.

Godot 4 (GL Compatibility) · Windows / macOS · 1280×720 · 12 livelli · A piedi / In bici / In auto + Modalità Invincibile

![Menu principale](docs/screenshots/menu.jpg)

## Come si gioca

| Azione | A piedi / In bici | In auto |
|---|---|---|
| Movimento | WASD / frecce / levetta del gamepad | W accelera · S frena · A / D cambia corsia |
| Passare col rosso | Sul bordo del marciapiede tieni premuto ↑ per mezzo secondo, oppure premi Spazio / A del gamepad | Col rosso, tira dritto oltre la linea di arresto |
| Pausa / uscita | ESC per la pausa; in pausa, Q torna al menu | Come a sinistra |
| Schermo intero | F11 o Alt+Enter | Come a sinistra |

**Obiettivo**
- A piedi / in bici: 60 secondi per livello, avanzando lungo il marciapiede; se vieni colpito 3 volte hai perso.
- In auto: raggiungi la destinazione entro 60 secondi, altrimenti sei in ritardo; scontri con auto, e-bike o pedoni costano una vita.

**Cosa incontrerai**
- **E-bike**: contromano, sorpassi da dietro (avviso con triangolo rosso in fondo allo schermo + "bip bip"), zigzag, scatti da negozi e bordo strada, infilate nel traffico, inchiodate improvvise per una consegna (una volta ferme diventano ostacoli), carichi enormi, mantelline antipioggia…
- **Pedoni**: lenti nella tua stessa direzione, che vengono incontro, che camminano storto con gli occhi sul telefono, a coppie affiancate, fermi impalati; in auto ci sono anche quelli sulle strisce e quelli che attraversano dove capita.
- **Ostacoli**: ingressi della metro, bici condivise, e-bike parcheggiate, paletti, bancarelle; in auto anche auto in sosta vietata, cantieri e bus in fermata. Gli ostacoli sono solidi: se ti spingono contro il bordo inferiore dello schermo inciampi e perdi una vita.
- **Semafori**: a piedi, col rosso la scena si ferma, ma mentre aspetti le e-bike passano col rosso o ti si stringono addosso; in auto devi frenare tu. **Passare col rosso costa il 25% del punteggio attuale, e se nell'incrocio ti investe un'auto della traversa è subito GAME OVER.**
- **Meteo**: col nubifragio l'asfalto è viscido e lo spazio di frenata si allunga; di notte lo schermo è buio e ti orienti solo con fari e lampioni.

**Punteggio e valutazione**
- Più resisti / più strada fai, più punti; mancato incidente +50; a fine livello ogni vita rimasta vale +300 (in auto c'è anche un bonus per il tempo avanzato).
- In auto, stare nella corsia bus costa -15 al secondo (nessuna penalità se la usi per aggirare un cantiere o un'auto in sosta vietata).
- Valutazione: S livello senza errori · A colpito 1 volta · B superato · C fallito.
- **Per sbloccare un livello devi superare il precedente**; i risultati vengono salvati automaticamente.

| Schermata regole (appare da sola alla prima partita) | Riepilogo sconfitta |
|---|---|
| ![Regole](docs/screenshots/rules.jpg) | ![Riepilogo](docs/screenshots/result.jpg) |

## Modalità di gioco

### 🚶 A piedi
La più agile: ti fermi e riparti quando vuoi. Schiva e-bike e pedoni sui marciapiedi di vie porticate (qilou), strade commerciali con facciate a vetri e villaggi urbani; agli incroci aspetti il verde.

![A piedi, in attesa del verde](docs/screenshots/red_light.jpg)

### 🚲 In bici
Più veloce, ma con inerzia e ingombro maggiori; col nubifragio è più facile non riuscire a frenare.

![Modalità bici](docs/screenshots/bike_mode.jpg)

### 🚗 In auto
In ogni livello si passa a una **strada vera e percorribile in auto** lì vicino (se l'area è pedonale o un vicolo di villaggio urbano, si usa la strada adiacente): numero di corsie, spartitraffico, complanari / piste ciclabili, corsie bus, limiti di velocità e nomi degli incroci si basano su fonti pubbliche. In basso a sinistra trovi velocità, cartello del limite e distanza rimanente; in alto a destra il semaforo del prossimo incrocio.

![Modalità auto](docs/screenshots/drive_6.jpg)

### 💥 Modalità Invincibile
Si attiva con un clic dal menu: niente danni, semafori ignorati, e ogni e-bike urtata **vola via** (+100 l'una, con combo); tutti i 12 livelli sono aperti. Pedoni e veicoli restano solidi, niente compenetrazioni. I punteggi in Modalità Invincibile non vengono salvati.  
In auto volano via anche auto, taxi e autobus (auto +200, bus +300); pedoni e cantieri restano solidi.

| A piedi, invincibile | In auto, invincibile |
|---|---|
| ![A piedi invincibile](docs/screenshots/invincible_walk.jpg) | ![In auto invincibile](docs/screenshots/invincible_drive.jpg) |

## I livelli

Guangzhou e Shenzhen si alternano, con difficoltà crescente. La configurazione di ogni livello è in `scripts/levels.gd` (le strade per l'auto sono in `DRIVE`; nei commenti ci sono le fonti sulle condizioni stradali, e i dati non verificabili sono segnati come "估", stima).

### Livello 1 · Guangzhou · Tianhe · Via Tiyu Ovest
*Guangzhou · Tiyu West Road*

- **A piedi / in bici**: Livello per principianti: fuori dalla metro di Tiyu Ovest, piena di e-bike contromano. (Via porticata · 2 incroci (Via Tianhe Sud 1, Via Tianhe))
- **In auto · Via Tiyu Ovest**: 6 corsie, traffico enorme, taxi che caricano davanti al Tianhe City e rider in e-bike contromano lungo il bordo.
  - 6 corsie a doppio senso · guardrail centrale · limite 50 km/h · destinazione a 380 m · verde 8 s / rosso 6 s · incroci: Via Tianhe Sud 1, Via Tianhe
  - Fonte: Via Tiyu Ovest: direzione nord-sud, larga 44 m, 6 corsie a doppio senso, traffico intensissimo (Wikipedia)

| A piedi / In bici | In auto |
|---|---|
| ![Livello 1 a piedi](docs/screenshots/walk_0.jpg) | ![Livello 1 in auto](docs/screenshots/drive_0.jpg) |

### Livello 2 · Shenzhen · Futian · Huaqiang Nord
*Shenzhen · Huaqiang North*

- **A piedi / in bici**: Davanti al mercato dell'elettronica, le e-bike da carico hanno pile di scatoloni più alte di una persona. (Strada commerciale con facciate a vetri · 2 incroci (Via Zhenhua, Via Hongli))
- **In auto · Via Zhenhua (senso unico)**: Huaqiang Nord è pedonale, quindi si passa da Via Zhenhua: senso unico verso est, con corsia per e-bike a destra. Ma le e-bike vogliono stare tra le auto.
  - Senso unico, 3 corsie · a destra pista ciclabile separata da guardrail · limite 40 km/h · destinazione a 320 m · verde 7 s / rosso 5 s · incroci: Via Yannan, Via Huafa Nord
  - Fonte: il tratto di Via Huaqiang Nord tra Via Hongli e Viale Shennan è pedonale dal 2017, vietato ai veicoli; Via Zhenhua è a senso unico verso est e dal 2021 sperimenta la carreggiata condivisa, con una corsia per e-bike separata da guardrail sulla destra (avvisi della polizia stradale di Shenzhen / Nanfang+)

| A piedi / In bici | In auto |
|---|---|
| ![Livello 2 a piedi](docs/screenshots/walk_1.jpg) | ![Livello 2 in auto](docs/screenshots/drive_1.jpg) |

### Livello 3 · Guangzhou · Yuexiu · Via Beijing
*Guangzhou · Beijing Road*

- **A piedi / in bici**: Vecchia via porticata (qilou) dal marciapiede stretto: banchi di dolci e paletti ovunque, devi passare negli spiragli. (Via porticata · marciapiede stretto · 2 incroci (Via Wenming, Via Zhongshan 5))
- **In auto · Via Zhongshan 5**: Via Beijing è pedonale, quindi si passa da Via Zhongshan 5: 4 corsie (stima), all'ora di punta la corsia di destra è riservata ai bus, che si fermano uno dopo l'altro.
  - 4 corsie a doppio senso · doppia linea gialla · 1 corsia bus a destra · limite 40 km/h · destinazione a 240 m · verde 7 s / rosso 6 s · incroci: Inc. Beijing, Inc. Jixiang
  - Fonte: il tratto centrale di Via Beijing è pedonale, in auto si può solo percorrere Via Zhongshan che la incrocia (Wikipedia); Via Zhongshan 5, dall'incrocio con Via Beijing a Via Jiefang: oltre trenta linee di bus, corsia bus nelle ore di punta (Guangzhou Bendibao); corsie stimate: 4 a doppio senso

| A piedi / In bici | In auto |
|---|---|
| ![Livello 3 a piedi](docs/screenshots/walk_2.jpg) | ![Livello 3 in auto](docs/screenshots/drive_2.jpg) |

### Livello 4 · Shenzhen · Nanshan · Parco Scientifico
*Shenzhen · Science Park*

- **A piedi / in bici**: Ora di punta delle consegne a pranzo! Bip bip continui alle spalle e, col rosso, tutte le e-bike ti si stringono addosso. (Strada commerciale con facciate a vetri · 3 incroci (Via Keyuan, Gaoxin Sud 1, Gaoxin Sud 4))
- **In auto · Via Keyuan**: A pranzo Via Keyuan è una coda infinita e i rider in e-bike si infilano tra le auto; c'è l'onda verde: a circa 40km/h trovi tutti verdi.
  - 7 corsie a doppio senso · spartitraffico verde · limite 50 km/h · destinazione a 400 m · verde 10 s / rosso 5 s · **onda verde** · incroci: Gaoxin Centro 1, Gaoxin Sud 1, Gaoxin Sud 4
  - Fonte: Via Keyuan è congestionatissima nelle ore di punta, la direzione sud è passata da 3 a 4 corsie (polizia stradale di Shenzhen / Zhihu); direzione nord 3 corsie (stima); la polizia stradale di Shenzhen ottimizza i semafori con l'IA creando tratti a onda verde (polizia stradale di Shenzhen), qui i tre incroci sono coordinati in onda verde

| A piedi / In bici | In auto |
|---|---|
| ![Livello 4 a piedi](docs/screenshots/walk_3.jpg) | ![Livello 4 in auto](docs/screenshots/drive_3.jpg) |

### Livello 5 · Guangzhou · Haizhu · Kecun
*Guangzhou · Kecun*

- **A piedi / in bici**: Un ingresso della metro dopo l'altro, con montagne di bici condivise davanti. (Via porticata · 2 incroci (Via Xingang Centro, Via Yiyuan))
- **In auto · Via Xingang Centro**: Arteria di Haizhu con limite 60, corsia bus a destra; intorno a Kecun i bus si fermano a raffica.
  - 6 corsie a doppio senso · spartitraffico verde · 1 corsia bus a destra · limite 60 km/h · destinazione a 450 m · verde 9 s / rosso 6 s · incroci: Via Xinshitou, Via Yiyuan
  - Fonte: Via Xingang: arteria principale del distretto di Haizhu, da 2 a 6 corsie a doppio senso, limite 60; su Via Xingang Centro c'è la corsia bus (Wikipedia / Sina)

| A piedi / In bici | In auto |
|---|---|
| ![Livello 5 a piedi](docs/screenshots/walk_4.jpg) | ![Livello 5 in auto](docs/screenshots/drive_4.jpg) |

### Livello 6 · Shenzhen · Luohu · Dongmen
*Shenzhen · Dongmen*

- **A piedi / in bici**: Vecchio quartiere commerciale fitto di negozi: le e-bike sbucano dalle porte in ogni momento. (Strada commerciale con facciate a vetri · 2 incroci (Via Jiefang, Via Xinyuan))
- **In auto · Via Dongmen Centro**: 7 corsie, ma 2 per lato sono riservate ai bus e le auto si stringono al centro; dai negozi le e-bike sbucano senza preavviso.
  - 7 corsie a doppio senso · doppia linea gialla · 2 corsie bus a destra · limite 40 km/h · destinazione a 300 m · verde 7 s / rosso 6 s · incroci: Via Jiefang, Via Shaibu
  - Fonte: Via Dongmen Centro: in origine 7 corsie a doppio senso, le 2 più a destra in ciascuna direzione riservate ai bus, accesso dei veicoli privati a targhe alterne (Shenzhen Bendibao / Wikipedia)

| A piedi / In bici | In auto |
|---|---|
| ![Livello 6 a piedi](docs/screenshots/walk_5.jpg) | ![Livello 6 in auto](docs/screenshots/drive_5.jpg) |

### Livello 7 · Guangzhou · Zhujiang · Viale Huacheng
*Guangzhou · Huacheng Avenue*

- **A piedi / in bici**: Nubifragio! Si scivola e non si frena, e le e-bike con la mantella non vedono la strada. (Strada commerciale con facciate a vetri · nubifragio · 2 incroci (Via Xiancun, Viale Liede))
- **In auto · Viale Huacheng**: 10 corsie larghe e veloci; col nubifragio si vede poco, l'asfalto è viscido e lo spazio di frenata si allunga parecchio.
  - 10 corsie a doppio senso · spartitraffico verde · limite 60 km/h · destinazione a 520 m · verde 10 s / rosso 6 s · incroci: Via Xiancun, Viale Liede
  - Fonte: Viale Huacheng: largo 71 m, 10 corsie a doppio senso, tunnel del CBD nel tratto di Piazza Huacheng (Wikipedia)

| A piedi / In bici | In auto |
|---|---|
| ![Livello 7 a piedi](docs/screenshots/walk_6.jpg) | ![Livello 7 in auto](docs/screenshots/drive_6.jpg) |

### Livello 8 · Shenzhen · Futian · Chegongmiao
*Shenzhen · Chegongmiao*

- **A piedi / in bici**: Ritorno a casa a notte fonda dopo gli straordinari: lampioni fiochi, le e-bike le vedi solo dai fari. (Strada commerciale con facciate a vetri · notte · 2 incroci (Via Tairan 9, Via Tian'an))
- **In auto · Viale Shennan**: Viale Shennan: 8 corsie più complanari ai lati; di notte si corre e le e-bike sbucano dalle complanari attraverso i varchi nelle aiuole.
  - 8 corsie a doppio senso · spartitraffico verde · complanari su entrambi i lati · limite 60 km/h · destinazione a 480 m · verde 10 s / rosso 6 s · **onda verde** · incroci: Via Tairan 9, Via Xiangmei
  - Fonte: Viale Shennan: carreggiata principale da 6 a 8 corsie a doppio senso, complanari con 4 corsie a doppio senso, limite 60 (Shenzhen Transport Wiki)

| A piedi / In bici | In auto |
|---|---|
| ![Livello 8 a piedi](docs/screenshots/walk_7.jpg) | ![Livello 8 in auto](docs/screenshots/drive_7.jpg) |

### Livello 9 · Guangzhou · Tianhe · Villaggio Shipai
*Guangzhou · Shipai Village*

- **A piedi / in bici**: Villaggio urbano di palazzi attaccati: vicoli stretti, pieni di e-bike parcheggiate e di altre che zigzagano. (Villaggio urbano di palazzi attaccati · marciapiede stretto · 1 incrocio (Via Shipai Est))
- **In auto · Via Shipai Est**: Costeggia il villaggio di Shipai: dai vicoli sbucano e-bike in ogni momento e le auto in sosta vietata sono in fila.
  - 4 corsie a doppio senso · doppia linea gialla · limite 40 km/h · destinazione a 230 m · verde 6 s / rosso 6 s · incroci: Via Xintao Nord, Via Xintao Sud
  - Fonte: Via Shipai Est: da senso unico nord-sud è tornata a doppio senso; nel villaggio di Shipai ci sono quasi 300 vicoli (Sina / Xinhuanet); corsie stimate: 4 a doppio senso

| A piedi / In bici | In auto |
|---|---|
| ![Livello 9 a piedi](docs/screenshots/walk_8.jpg) | ![Livello 9 in auto](docs/screenshots/drive_8.jpg) |

### Livello 10 · Shenzhen · Nanshan · Baishizhou
*Shenzhen · Baishizhou*

- **A piedi / in bici**: Apre il mercato notturno del villaggio urbano: bancarelle sul marciapiede ed e-bike che sfrecciano tra luci e ombre. (Villaggio urbano di palazzi attaccati · notte · marciapiede stretto · 1 incrocio (Via Shahe))
- **In auto · Complanare Shennan**: Complanare di Shennan a Baishizhou, con la strada principale oltre l'aiuola a sinistra; fermate bus a raffica e sciami di e-bike dal villaggio urbano che escono da Via Shahe.
  - Senso unico, 2 corsie · aiuola (oltre c'è la carreggiata principale) · 1 corsia bus a destra · limite 40 km/h · destinazione a 250 m · verde 8 s / rosso 6 s · incroci: Via Shahe, Via Shizhou Centro
  - Fonte: Viale Shennan, tratto di Baishizhou: complanari su entrambi i lati, con diverse fermate bus vicino all'incrocio con Via Shahe (Wikipedia)

| A piedi / In bici | In auto |
|---|---|
| ![Livello 10 a piedi](docs/screenshots/walk_9.jpg) | ![Livello 10 in auto](docs/screenshots/drive_9.jpg) |

### Livello 11 · Guangzhou · Baiyun · Xinshixu
*Guangzhou · Xinshixu*

- **A piedi / in bici**: Notte di nubifragio, buio e scivoloso, con file di bici condivise fuori dalla metro. (Via porticata · nubifragio · notte · 2 incroci (Via Jichang, Via Xinshi Ovest))
- **In auto · Via Jichang**: Sopra c'è la sopraelevata per l'aeroporto, i piloni coprono la visuale e nella notte di pioggia l'asfalto riflette: le e-bike contromano lungo il bordo non si vedono.
  - 6 corsie a doppio senso · sopraelevata sopra la testa, piloni come spartitraffico · limite 50 km/h · destinazione a 360 m · verde 8 s / rosso 6 s · incroci: Via Qifu, Via Huiqiao Sud
  - Fonte: intorno alla stazione di Xinshixu passano Via Jichang e il viadotto della superstrada per l'aeroporto (Wikipedia); corsie della strada a raso stimate: 6 a doppio senso

| A piedi / In bici | In auto |
|---|---|
| ![Livello 11 a piedi](docs/screenshots/walk_10.jpg) | ![Livello 11 in auto](docs/screenshots/drive_10.jpg) |

### Livello 12 · Shenzhen · Longhua · Minzhi
*Shenzhen · Minzhi*

- **A piedi / in bici**: L'ora di punta definitiva: tre semafori, frenate, carichi, rider e file di e-bike, tutti insieme. (Strada commerciale con facciate a vetri · 3 incroci (Viale Minzhi, Via Renmin, Viale Meilong))
- **In auto · Viale Minzhi**: 6 corsie stipate in 24 metri, limite 40, tre semafori all'ora di punta serale: e-bike che inchiodano, trasportano merci o si infilano ovunque.
  - 6 corsie a doppio senso · guardrail centrale · limite 40 km/h · destinazione a 270 m · verde 7 s / rosso 6 s · incroci: Via Renmin, Via Meilong, Via Gongye
  - Fonte: Viale Minzhi: arteria principale del distretto di Longhua, larga 24 m, limite 40, 6 corsie a doppio senso (Wikipedia)

| A piedi / In bici | In auto |
|---|---|
| ![Livello 12 a piedi](docs/screenshots/walk_11.jpg) | ![Livello 12 in auto](docs/screenshots/drive_11.jpg) |

## Avvio

Serve [Godot 4.7](https://godotengine.org/download).

```
Godot --path .                                         # 直接玩
Godot -e --path .                                      # 打开编辑器
Godot --path . -- --autostart=drive --level=7 --god    # 跳过菜单直接进关卡（walk/bike/drive，level 0–11），不掉血
Godot --path . -- --unlock-all | --reset-save | --rules | --support | --invincible
```

(In ordine: gioca subito; apri l'editor; salta il menu ed entra direttamente in un livello — walk/bike/drive, level 0–11 — senza perdere vite; altre opzioni: sblocca tutto, azzera il salvataggio, mostra le regole, pagina di supporto, Modalità Invincibile.)

## Test
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

Cosa verificano, in ordine: a piedi/in bici le auto non si sovrappongono, non schiacciano le e-bike e tutti gli incroci compaiono; in auto, la guida automatica completa i 12 livelli senza sovrapposizioni tra partecipanti; passare col rosso toglie il 25%, poi si riparte, e l'investimento dà GAME OVER; tasti reali: si passa col rosso sia tenendo W sia con Spazio; tutti i caratteri cinesi vengono visualizzati (elenca quelli mancanti nel font Smiley Sans che ricadono sul font di sistema); in Modalità Invincibile il giocatore non compenetra nulla; i semafori non restano bloccati sul rosso; controllo dei livelli in auto: tasso di arrivo, ingorghi, rosso più lungo, uso della corsia bus, sovrapposizioni.

Gli screenshot si generano con `tools/screenshot.gd` (durante la registrazione la finestra non deve essere coperta, oppure aggiungi `--always-on-top`):
```
Godot --always-on-top --path . --script tools/screenshot.gd --write-movie /tmp/shot/f.png --fixed-fps 10 --quit-after 200 -- --only=0 --mode=drive
```

## Web / Mobile

Si gioca nel browser di telefono e tablet senza tastiera né controller (i comandi touch compaiono da soli).
- Touch: premi e trascina nella metà sinistra = joystick (in auto cambia corsia); in auto gas / freno in basso a destra; a piedi compare un pulsante per passare col rosso sul bordo del marciapiede; II in alto per la pausa. Gioca in orizzontale.
- Esporta: `Godot --headless --path . --export-release "Web" build/web/index.html` (single-thread, funziona su qualsiasi hosting statico)
- Prova in locale / in rete: `python3 tools/serve_web.py`, poi apri l'indirizzo mostrato su un telefono nella stessa Wi-Fi
- Test end-to-end (Chrome che emula un telefono touch in orizzontale): `python3 tools/mobile_web_test.py`; test unitario touch: `tests/touch_test.gd`
- I browser non hanno font di sistema: giapponese, coreano, arabo e vietnamita usano i sottoinsiemi Noto in `fonts/noto/` (generati con `tools/build_fonts.py`)

## Altro
- Grafica ed effetti sonori sono interamente generati via codice, senza asset grafici esterni.
- Font: [得意黑 Smiley Sans](https://github.com/atelier-anchor/smiley-sans) (SIL OFL 1.1, licenza in `fonts/SmileySans-OFL.txt`); per i caratteri mancanti si ricade sul font cinese di sistema.
- Salvataggio: `user://save.cfg` (progressi sbloccati, miglior risultato per livello, mezzo di trasporto, se le regole sono già state viste, stato della Modalità Invincibile).
- Nel menu c'è la pagina "Sostieni l'autore" (clicca su un indirizzo per copiarlo); per nasconderla imposta `SUPPORT_ENABLED` a `false` in `scripts/main.gd`.
