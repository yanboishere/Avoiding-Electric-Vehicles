🌐 [简体中文](README.md) · [English](README.en.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Français](README.fr.md) · **Español** · [Deutsch](README.de.md) · [العربية](README.ar.md) · [Tiếng Việt](README.vi.md) · [Português](README.pt.md) · [Italiano](README.it.md)

# ¡Esquiva las Motos! Avoiding Electric Vehicles

> En Guangzhou y Shenzhen muchas calles no tienen carril bici. Sales a pie, en bici o en coche, y las motos eléctricas (las «e-bikes» que en China llaman con sorna 电鸡, «pollos eléctricos») aparecen por todas partes: en sentido contrario, adelantando, colándose entre coches, cruzando a lo loco, frenando en seco… Sobrevive un minuto.

Godot 4 (GL Compatibility) · Windows / macOS · 1280×720 · 12 niveles · A pie / En bici / En coche + Modo Invencible

![Menú principal](docs/screenshots/menu.jpg)

## Cómo se juega

| Acción | A pie / En bici | En coche |
|---|---|---|
| Moverse | WASD / flechas / stick del mando | W acelerar · S frenar · A / D cambiar de carril |
| Saltarse el rojo | En el bordillo, mantén ↑ medio segundo, o pulsa Espacio / A del mando | Cruza la línea de detención con el semáforo en rojo |
| Pausa / Salir | ESC pausa; en pausa, Q vuelve al menú | Igual |
| Pantalla completa | F11 o Alt+Enter | Igual |

**Objetivo**
- A pie / en bici: 60 segundos por nivel avanzando por la acera; si te atropellan 3 veces, pierdes.
- En coche: llega al destino en 60 segundos o llegarás tarde; chocar con coches, motos o peatones te quita una vida.

**Lo que te vas a encontrar**
- **Motos**: en sentido contrario, adelantándote por detrás (aviso con triángulo rojo abajo + «pi-pi»), en zigzag, saliendo de tiendas o del bordillo, colándose entre el tráfico, frenando en seco para entregar un pedido (y quedándose como obstáculo), cargadas de mercancía, con chubasquero…
- **Peatones**: lentos en tu mismo sentido, de frente, mirando el móvil y torciéndose, en paralelo, plantados sin moverse; en coche, además, los que cruzan por el paso de cebra y los que cruzan por medio.
- **Obstáculos**: bocas de metro, bicis compartidas, motos aparcadas, bolardos, puestos; en coche, coches mal aparcados, vallas de obra y autobuses en la parada. Los obstáculos son sólidos: si te empujan contra el borde inferior de la pantalla, tropiezas y pierdes vida.
- **Semáforos**: a pie, con rojo la pantalla se detiene, y mientras esperas también hay motos que se saltan el rojo o se apiñan a tu lado; en coche tienes que frenar tú. **Saltarte el rojo te quita el 25% de tus puntos, y si te pilla el tráfico cruzado dentro del cruce, GAME OVER.**
- **Tiempo**: con tormenta el suelo resbala y la frenada se alarga; de noche todo se oscurece y solo te guías por faros y farolas.

**Puntos y rango**
- Cuanto más aguantes / más lejos llegues, más puntos; roce +50; al superar el nivel, cada vida restante +300 (en coche, además, puntos por el tiempo sobrante).
- En coche, ir por el carril bus resta 15 por segundo (desviarte para esquivar obras o coches mal aparcados no penaliza).
- Rango: S sin fallos · A 1 golpe · B superado · C derrota.
- **Supera un nivel para desbloquear el siguiente**; el progreso se guarda automáticamente.

| Pantalla de reglas (aparece la primera vez que juegas) | Resultado de una derrota |
|---|---|
| ![Reglas](docs/screenshots/rules.jpg) | ![Resultado](docs/screenshots/result.jpg) |

## Modos de juego

### 🚶 A pie
El más ágil: paras y arrancas cuando quieras. Esquiva motos y peatones por las aceras de soportales antiguos, calles comerciales de cristal y pueblos urbanos, y espera al verde en los cruces.

![A pie esperando el verde](docs/screenshots/red_light.jpg)

### 🚲 En bici
Más rápido, pero con inercia y más grande al chocar; con tormenta cuesta más frenar.

![Modo bici](docs/screenshots/bike_mode.jpg)

### 🚗 En coche
Cada nivel pasa a un **tramo real cercano por el que se puede conducir** (si la calle es peatonal o es un callejón de pueblo urbano, se usa una vía vecina): número de carriles, mediana, laterales / carril bici, carril bus, límite de velocidad y nombres de los cruces siguen datos públicos. Abajo a la izquierda ves la velocidad, la señal de límite y la distancia restante; arriba a la derecha, el semáforo del próximo cruce.

![Modo coche](docs/screenshots/drive_6.jpg)

### 💥 Modo Invencible
Se activa con un clic en el menú: no pierdes vidas, ignoras los semáforos y toda moto que choques sale **volando** (+100 cada una, con combos), y los 12 niveles quedan abiertos. Peatones y vehículos siguen siendo sólidos, nada se atraviesa. Las partidas en Modo Invencible no se guardan.

| A pie invencible | En coche invencible |
|---|---|
| ![A pie invencible](docs/screenshots/invincible_walk.jpg) | ![En coche invencible](docs/screenshots/invincible_drive.jpg) |

## Niveles

Guangzhou y Shenzhen se alternan y la dificultad va subiendo. La configuración de cada nivel está en `scripts/levels.gd` (los tramos en coche están en `DRIVE`; los comentarios citan las fuentes y los datos que no se pudieron confirmar llevan la marca «估», estimado).

### Nivel 1 · Guangzhou · Tianhe · Av. Tiyu Oeste
*Guangzhou · Tiyu West Road*

- **A pie / en bici**: Nivel novato: a la salida del metro Tiyu Oeste, lleno de motos en sentido contrario. (Soportales antiguos · 2 cruces (Tianhe Sur 1, Av. Tianhe))
- **En coche · Av. Tiyu Oeste**: 6 carriles, tráfico brutal: taxis parando frente al Teemall y motos de reparto en contra pegadas al bordillo.
  - 6 carriles (3+3) · valla central · máx. 50 km/h · destino a 380 m · verde 8 s / rojo 6 s · cruces: Tianhe Sur 1, Av. Tianhe
  - Fuentes: Av. Tiyu Oeste: norte-sur, 44 m de ancho, 6 carriles, tráfico intensísimo (Wikipedia)

| A pie / en bici | En coche |
|---|---|
| ![Nivel 1 a pie](docs/screenshots/walk_0.jpg) | ![Nivel 1 en coche](docs/screenshots/drive_0.jpg) |

### Nivel 2 · Shenzhen · Futian · Huaqiangbei
*Shenzhen · Huaqiang North*

- **A pie / en bici**: A la puerta del mercado electrónico, motos de carga con cajas más altas que tú. (Calle comercial de cristal · 2 cruces (Av. Zhenhua, Av. Hongli))
- **En coche · Av. Zhenhua (sentido único)**: Huaqiangbei es peatonal, así que vas por Zhenhua: sentido único al este con carril para motos a la derecha… que las motos ignoran para meterse entre los coches.
  - Sentido único, 3 carriles · carril bici a la derecha separado por valla · máx. 40 km/h · destino a 320 m · verde 7 s / rojo 5 s · cruces: Av. Yannan, Huafa Norte
  - Fuentes: el tramo Hongli–Shennan de Huaqiangbei es peatonal desde 2017 y no admite vehículos; Zhenhua es de sentido único de oeste a este y en 2021 probó una calzada compartida con carril para motos separado por valla a la derecha (avisos de la policía de tráfico de Shenzhen / Nanfang+)

| A pie / en bici | En coche |
|---|---|
| ![Nivel 2 a pie](docs/screenshots/walk_1.jpg) | ![Nivel 2 en coche](docs/screenshots/drive_1.jpg) |

### Nivel 3 · Guangzhou · Yuexiu · Av. Beijing
*Guangzhou · Beijing Road*

- **A pie / en bici**: Soportales antiguos de aceras estrechas: puestos de postres y bolardos te obligan a colarte por los huecos. (Soportales antiguos · acera estrecha · 2 cruces (Av. Wenming, Zhongshan 5))
- **En coche · Zhongshan 5**: Beijing es peatonal, así que vas por Zhongshan 5: 4 carriles (aprox.), carril bus a la derecha en hora punta y autobuses parando uno tras otro.
  - 4 carriles (2+2) · doble línea amarilla · 1 carril bus a la derecha · máx. 40 km/h · destino a 240 m · verde 7 s / rojo 6 s · cruces: Cruce Beijing, Cruce Jixiang
  - Fuentes: el tramo central de la Av. Beijing es peatonal; en coche solo se puede ir por la calle Zhongshan que la cruza (Wikipedia); Zhongshan 5 entre el Cruce Beijing y la Av. Jiefang tiene más de treinta líneas de autobús y carril bus en hora punta (Guangzhou Bendibao); carriles estimados: 4 (2+2)

| A pie / en bici | En coche |
|---|---|
| ![Nivel 3 a pie](docs/screenshots/walk_2.jpg) | ![Nivel 3 en coche](docs/screenshots/drive_2.jpg) |

### Nivel 4 · Shenzhen · Nanshan · Tecnoparque
*Shenzhen · Science Park*

- **A pie / en bici**: ¡Hora punta del reparto! Pitidos sin fin a tu espalda y, en rojo, todas las motos apiñadas a tu lado. (Calle comercial de cristal · 3 cruces (Av. Keyuan, Gaoxin Sur 1, Gaoxin Sur 4))
- **En coche · Av. Keyuan**: Atasco del mediodía en Keyuan con motos de reparto colándose entre coches; hay onda verde: a unos 40km/h pillas todos en verde.
  - 7 carriles · mediana ajardinada · máx. 50 km/h · destino a 400 m · verde 10 s / rojo 5 s · **onda verde** · cruces: Gaoxin Centro 1, Gaoxin Sur 1, Gaoxin Sur 4
  - Fuentes: Keyuan se colapsa en las horas punta de mañana y tarde; el sentido sur pasó de 3 a 4 carriles (policía de tráfico de Shenzhen / Zhihu); sentido norte 3 carriles (estimado); la policía de tráfico de Shenzhen optimiza los semáforos con IA para crear tramos de onda verde (policía de tráfico de Shenzhen), así que aquí los tres cruces van coordinados en onda verde

| A pie / en bici | En coche |
|---|---|
| ![Nivel 4 a pie](docs/screenshots/walk_3.jpg) | ![Nivel 4 en coche](docs/screenshots/drive_3.jpg) |

### Nivel 5 · Guangzhou · Haizhu · Kecun
*Guangzhou · Kecun*

- **A pie / en bici**: Bocas de metro una tras otra y montañas de bicis compartidas en la puerta. (Soportales antiguos · 2 cruces (Xingang Centro, Av. Yiyuan))
- **En coche · Xingang Centro**: Arteria de Haizhu a 60, carril bus a la derecha y un montón de autobuses parando en Kecun.
  - 6 carriles (3+3) · mediana ajardinada · 1 carril bus a la derecha · máx. 60 km/h · destino a 450 m · verde 9 s / rojo 6 s · cruces: Av. Xinshitou, Av. Yiyuan
  - Fuentes: Av. Xingang: arteria principal del distrito de Haizhu, de 2 a 6 carriles, límite 60; Xingang Centro tiene carril bus (Wikipedia / Sina)

| A pie / en bici | En coche |
|---|---|
| ![Nivel 5 a pie](docs/screenshots/walk_4.jpg) | ![Nivel 5 en coche](docs/screenshots/drive_4.jpg) |

### Nivel 6 · Shenzhen · Luohu · Dongmen
*Shenzhen · Dongmen*

- **A pie / en bici**: Barrio comercial viejo lleno de tiendas: las motos salen de las puertas en cualquier momento. (Calle comercial de cristal · 2 cruces (Av. Jiefang, Av. Xinyuan))
- **En coche · Dongmen Centro**: 7 carriles, pero 2 por sentido son de bus y los coches se apiñan en el centro; las motos salen de las tiendas sin avisar.
  - 7 carriles · doble línea amarilla · 2 carriles bus a la derecha · máx. 40 km/h · destino a 300 m · verde 7 s / rojo 6 s · cruces: Av. Jiefang, Av. Shaibu
  - Fuentes: Dongmen Centro: originalmente 7 carriles, con los 2 de la derecha de cada sentido reservados al bus; los coches particulares entraban según matrícula par o impar (Shenzhen Bendibao / Wikipedia)

| A pie / en bici | En coche |
|---|---|
| ![Nivel 6 a pie](docs/screenshots/walk_5.jpg) | ![Nivel 6 en coche](docs/screenshots/drive_5.jpg) |

### Nivel 7 · Guangzhou · Zhujiang Xincheng · Bulevar Huacheng
*Guangzhou · Huacheng Avenue*

- **A pie / en bici**: ¡Tormenta! El suelo resbala, no hay quien frene, y las motos con chubasquero no ven nada. (Calle comercial de cristal · tormenta · 2 cruces (Av. Xiancun, Bulevar Liede))
- **En coche · Bulevar Huacheng**: 10 carriles anchos y rápidos; con tormenta se ve poco, el asfalto resbala y la frenada se alarga mucho.
  - 10 carriles (5+5) · mediana ajardinada · máx. 60 km/h · destino a 520 m · verde 10 s / rojo 6 s · cruces: Av. Xiancun, Bulevar Liede
  - Fuentes: Bulevar Huacheng: 71 m de ancho, 10 carriles, con el túnel del CBD bajo la plaza Huacheng (Wikipedia)

| A pie / en bici | En coche |
|---|---|
| ![Nivel 7 a pie](docs/screenshots/walk_6.jpg) | ![Nivel 7 en coche](docs/screenshots/drive_6.jpg) |

### Nivel 8 · Shenzhen · Futian · Chegongmiao
*Shenzhen · Chegongmiao*

- **A pie / en bici**: Vuelta a casa tras currar hasta tarde: farolas tenues, solo los faros te dicen dónde están las motos. (Calle comercial de cristal · noche · 2 cruces (Tairan 9, Av. Tian'an))
- **En coche · Bulevar Shennan**: Shennan: 8 carriles centrales con laterales a ambos lados; de noche se va rápido y las motos cruzan desde el lateral por los huecos de la mediana.
  - 8 carriles (4+4) · mediana ajardinada · laterales a ambos lados · máx. 60 km/h · destino a 480 m · verde 10 s / rojo 6 s · **onda verde** · cruces: Tairan 9, Av. Xiangmei
  - Fuentes: Bulevar Shennan: calzada principal de 6 a 8 carriles, laterales de 4 carriles, límite 60 (wiki de tráfico de Shenzhen)

| A pie / en bici | En coche |
|---|---|
| ![Nivel 8 a pie](docs/screenshots/walk_7.jpg) | ![Nivel 8 en coche](docs/screenshots/drive_7.jpg) |

### Nivel 9 · Guangzhou · Tianhe · Pueblo Shipai
*Guangzhou · Shipai Village*

- **A pie / en bici**: Pueblo urbano de edificios pegados: callejones estrechos, motos aparcadas por todas partes y muchas en zigzag. (Pueblo urbano de edificios pegados · acera estrecha · 1 cruce (Shipai Este))
- **En coche · Shipai Este**: Pegada al pueblo de Shipai: las motos salen de los callejones en cualquier momento y hay coches mal aparcados uno tras otro.
  - 4 carriles (2+2) · doble línea amarilla · máx. 40 km/h · destino a 230 m · verde 6 s / rojo 6 s · cruces: Xintao Norte, Xintao Sur
  - Fuentes: Shipai Este pasó de sentido único norte-sur a doble sentido; dentro del pueblo de Shipai hay cerca de 300 callejuelas (Sina / Xinhua); carriles estimados: 4 (2+2)

| A pie / en bici | En coche |
|---|---|
| ![Nivel 9 a pie](docs/screenshots/walk_8.jpg) | ![Nivel 9 en coche](docs/screenshots/drive_8.jpg) |

### Nivel 10 · Shenzhen · Nanshan · Baishizhou
*Shenzhen · Baishizhou*

- **A pie / en bici**: Abre el mercado nocturno del pueblo urbano: puestos invadiendo la acera y motos zumbando entre luces y sombras. (Pueblo urbano de edificios pegados · noche · acera estrecha · 1 cruce (C/ Shahe))
- **En coche · Lateral Shennan**: Lateral de Shennan en Baishizhou, con la vía principal tras la mediana; parada de bus tras parada y un enjambre de motos saliendo de C/ Shahe.
  - Sentido único, 2 carriles · mediana ajardinada (al otro lado, la vía principal) · 1 carril bus a la derecha · máx. 40 km/h · destino a 250 m · verde 8 s / rojo 6 s · cruces: C/ Shahe, Shizhou Centro
  - Fuentes: Bulevar Shennan, tramo de Baishizhou: laterales a ambos lados de la calzada principal, con varias paradas de autobús en el lateral cerca de C/ Shahe (Wikipedia)

| A pie / en bici | En coche |
|---|---|
| ![Nivel 10 a pie](docs/screenshots/walk_9.jpg) | ![Nivel 10 en coche](docs/screenshots/drive_9.jpg) |

### Nivel 11 · Guangzhou · Baiyun · Xinshixu
*Guangzhou · Xinshixu*

- **A pie / en bici**: Noche de tormenta, resbala y está oscuro, y la boca de metro está llena de bicis compartidas. (Soportales antiguos · tormenta · noche · 2 cruces (Av. Aeropuerto, Xinshi Oeste))
- **En coche · Av. Aeropuerto**: Bajo la autopista elevada del aeropuerto: los pilares tapan la vista, el asfalto brilla en la noche de tormenta y no ves las motos en contra pegadas al bordillo.
  - 6 carriles (3+3) · autopista elevada encima, pilares en la mediana · máx. 50 km/h · destino a 360 m · verde 8 s / rojo 6 s · cruces: Av. Qifu, Huiqiao Sur
  - Fuentes: alrededor de la estación Xinshixu están la Av. Aeropuerto y el viaducto de la autopista del aeropuerto (Wikipedia); carriles a nivel de calle estimados: 6 (3+3)

| A pie / en bici | En coche |
|---|---|
| ![Nivel 11 a pie](docs/screenshots/walk_10.jpg) | ![Nivel 11 en coche](docs/screenshots/drive_10.jpg) |

### Nivel 12 · Shenzhen · Longhua · Minzhi
*Shenzhen · Minzhi*

- **A pie / en bici**: La hora punta definitiva: tres semáforos, frenazos, motos de carga, repartidores y filas de motos. Todo. (Calle comercial de cristal · 3 cruces (Bulevar Minzhi, Av. Renmin, Bulevar Meilong))
- **En coche · Bulevar Minzhi**: 6 carriles apretados en 24 m, máx. 40, hora punta y tres semáforos: frenazos, motos de carga y motos colándose, todo junto.
  - 6 carriles (3+3) · valla central · máx. 40 km/h · destino a 270 m · verde 7 s / rojo 6 s · cruces: Av. Renmin, Av. Meilong, Av. Gongye
  - Fuentes: Bulevar Minzhi: vía principal del distrito de Longhua, 24 m de ancho, límite 40, 6 carriles (Wikipedia)

| A pie / en bici | En coche |
|---|---|
| ![Nivel 12 a pie](docs/screenshots/walk_11.jpg) | ![Nivel 12 en coche](docs/screenshots/drive_11.jpg) |

## Ejecutar

Necesitas [Godot 4.7](https://godotengine.org/download).

```
Godot --path .                                         # 直接玩
Godot -e --path .                                      # 打开编辑器
Godot --path . -- --autostart=drive --level=7 --god    # 跳过菜单直接进关卡（walk/bike/drive，level 0–11），不掉血
Godot --path . -- --unlock-all | --reset-save | --rules | --support | --invincible
```

(Comentarios: jugar directamente · abrir el editor · saltar el menú e ir directo a un nivel (walk/bike/drive, level 0–11) sin perder vidas.)

## Pruebas
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

Qué comprueba cada prueba:
- `car_overlap_test.gd`: a pie / en bici, los coches no se solapan, no pisan motos y aparecen todos los cruces.
- `drive_test.gd`: en coche, conducción automática por los 12 niveles sin que ningún participante se solape con otro.
- `jaywalk_test.gd`: saltarse el rojo resta el 25%, luego se sigue avanzando, y un atropello da GAME OVER.
- `jaywalk_keys_test.gd`: con teclas reales, mantener W o Espacio permite cruzar.
- `font_test.gd`: todos los caracteres chinos se muestran (lista los que faltan en Smiley Sans y usan la fuente del sistema).
- `invincible_test.gd`: en Modo Invencible, embistiendo a lo loco, el jugador no atraviesa nada.
- `light_test.gd`: los semáforos nunca se quedan atascados en rojo.
- `audit_test.gd`: revisión de los niveles en coche: tasa de llegada / atascos / rojo más largo / desvíos / solapamientos.

Las capturas se generan con `tools/screenshot.gd` (mientras graba, no tapes la ventana o añade `--always-on-top`):
```
Godot --always-on-top --path . --script tools/screenshot.gd --write-movie /tmp/shot/f.png --fixed-fps 10 --quit-after 200 -- --only=0 --mode=drive
```

## Web / Móvil

Se puede jugar en el navegador del móvil o la tableta sin teclado ni mando (los controles táctiles aparecen solos).
- Táctil: pulsa y arrastra en la mitad izquierda = joystick (cambio de carril en coche); acelerar / frenar abajo a la derecha en coche; a pie aparece un botón para saltarte el semáforo en el bordillo; II arriba para pausar. Juega en horizontal.
- Exportar: `Godot --headless --path . --export-release "Web" build/web/index.html` (un solo hilo, sirve cualquier hosting estático)
- Prueba local / en la red: `python3 tools/serve_web.py` y abre la dirección mostrada en un móvil de la misma Wi-Fi
- Prueba de extremo a extremo (Chrome emulando un móvil táctil en horizontal): `python3 tools/mobile_web_test.py`; prueba unitaria táctil: `tests/touch_test.gd`
- Los navegadores no tienen fuentes del sistema: japonés, coreano, árabe y vietnamita usan los subconjuntos Noto de `fonts/noto/` (generados con `tools/build_fonts.py`)

## Otros
- Gráficos y sonidos se generan por código; no hay recursos artísticos externos.
- Fuente: [得意黑 Smiley Sans](https://github.com/atelier-anchor/smiley-sans) (SIL OFL 1.1, licencia en `fonts/SmileySans-OFL.txt`); si falta algún carácter, se usa la fuente china del sistema.
- Partida guardada: `user://save.cfg` (niveles desbloqueados, mejor puntuación de cada nivel, modo de transporte, si ya viste las reglas y el interruptor del Modo Invencible).
- En el menú hay una página «Apoya al autor» (haz clic en una dirección para copiarla); para ocultarla, cambia `SUPPORT_ENABLED` a `false` en `scripts/main.gd`.
