🌐 [简体中文](README.md) · [English](README.en.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Français](README.fr.md) · [Español](README.es.md) · [Deutsch](README.de.md) · [العربية](README.ar.md) · [Tiếng Việt](README.vi.md) · **Português** · [Italiano](README.it.md)

# Desvie das Bikes Elétricas (Avoiding Electric Vehicles)

> Em Guangzhou e Shenzhen, muitas ruas não têm ciclofaixa. Você sai a pé, de bicicleta ou de carro, e as bikes elétricas (电鸡, "galinhas elétricas", no apelido chinês) brotam de todos os lados: na contramão, ultrapassando, costurando, cruzando do nada, freando de repente… Sobreviva por um minuto.

Godot 4 (GL Compatibility) · Windows / macOS · 1280×720 · 12 fases · a pé / de bicicleta / de carro + Modo Invencível

![Menu principal](docs/screenshots/menu.jpg)

## Como jogar

| Ação | A pé / de bicicleta | De carro |
|---|---|---|
| Mover | WASD / setas / analógico do controle | W acelera · S freia · A / D muda de faixa |
| Avançar o sinal | No meio-fio, segure ↑ por meio segundo ou aperte Espaço / botão A do controle | No vermelho, é só passar da faixa de retenção |
| Pausar / sair | ESC pausa; na pausa, Q volta ao menu | Igual |
| Tela cheia | F11 ou Alt+Enter | Igual |

**Objetivo**
- A pé / de bicicleta: cada fase dura 60 segundos; siga em frente pela calçada. Levou 3 batidas, perdeu.
- De carro: chegue ao destino em até 60 segundos, senão é atraso; bater em carro, bike elétrica ou pedestre custa uma vida.

**O que você vai encontrar**
- **Bikes elétricas**: na contramão, ultrapassando por trás (aviso com triângulo vermelho na parte de baixo da tela + "bi-bi"), em zigue-zague, saindo de lojas / da calçada, costurando no trânsito, freando do nada para fazer uma entrega (e virando obstáculo), levando carga, de capa de chuva…
- **Pedestres**: andando devagar no mesmo sentido, vindo de frente, olhando o celular e saindo da linha, andando lado a lado, parados no meio do caminho; de carro, ainda tem gente na faixa de pedestres e atravessando fora dela.
- **Obstáculos**: entradas de metrô, bikes compartilhadas, bikes elétricas estacionadas, frades de pedra, barracas; de carro, carros parados em local proibido, tapumes de obra e ônibus encostando no ponto. Os obstáculos são sólidos: se eles te empurrarem até a borda de baixo da tela, você tropeça e perde vida.
- **Semáforos**: a pé, no vermelho a tela para, e mesmo assim bikes elétricas furam o sinal e se espremem ao seu lado; de carro, você mesmo tem que frear. **Avançar o sinal tira 25% da pontuação atual, e ser atingido pelo trânsito transversal dentro do cruzamento é GAME OVER na hora.**
- **Clima**: no temporal o chão fica escorregadio e a frenagem fica mais longa; à noite a tela escurece e só os faróis e os postes ajudam.

**Pontuação e rank**
- Quanto mais tempo você aguenta / mais longe chega, mais pontos; quase-acidente +50; ao concluir, cada vida restante vale +300 (de carro, mais um bônus pelo tempo restante).
- De carro, ficar no corredor de ônibus custa -15 por segundo (desviar de obra ou de carro parado não é multado).
- Rank: S sem erros · A 1 batida · B concluída · C derrota.
- **Conclua uma fase para liberar a próxima**; o progresso é salvo automaticamente.

| Tela de regras (abre sozinha na primeira partida) | Resultado de derrota |
|---|---|
| ![Regras](docs/screenshots/rules.jpg) | ![Resultado](docs/screenshots/result.jpg) |

## Modos de jogo

### 🚶 A pé
O mais flexível: para e anda quando quiser. Desvie de bikes elétricas e pedestres nas calçadas de ruas com arcadas (qilou), avenidas comerciais de fachadas de vidro e vilas urbanas; nos cruzamentos, espere o sinal abrir.

![Esperando o sinal a pé](docs/screenshots/red_light.jpg)

### 🚲 De bicicleta
Mais rápido, mas com inércia e área de colisão maior; no temporal, é bem mais fácil não conseguir frear.

![Modo bicicleta](docs/screenshots/bike_mode.jpg)

### 🚗 De carro
Cada fase troca para uma **rua de verdade, onde dá para dirigir**, ali perto (quando a rua original é calçadão ou viela de vila urbana, usa-se uma via vizinha): número de faixas, canteiro central, marginal / ciclofaixa, corredor de ônibus, limite de velocidade e nomes dos cruzamentos seguem dados públicos. No canto inferior esquerdo ficam a velocidade, a placa de limite e a distância restante; no canto superior direito, o semáforo do próximo cruzamento.

![Modo carro](docs/screenshots/drive_6.jpg)

### 💥 Modo Invencível
Ativado com um clique no menu: você não perde vida, ignora o sinal vermelho e toda bike elétrica que bater é **arremessada** longe (+100 cada, com combo), e as 12 fases ficam liberadas. Pedestres e veículos continuam sólidos, nada atravessa nada. Os resultados do Modo Invencível não são salvos.

| A pé invencível | De carro invencível |
|---|---|
| ![A pé invencível](docs/screenshots/invincible_walk.jpg) | ![De carro invencível](docs/screenshots/invincible_drive.jpg) |

## Fases

Guangzhou e Shenzhen se alternam, com dificuldade crescente. A configuração de cada fase está em `scripts/levels.gd` (os trechos de carro ficam em `DRIVE`; os comentários citam as fontes sobre as vias, e o que não tinha dado exato está marcado como "估", estimado).

### Fase 1 · Guangzhou · Tianhe · Av. Tiyu Oeste
*Guangzhou · Tiyu West Road*

- **A pé / de bicicleta**: Fase inicial: na saída do metrô Tiyu Oeste, o recorde de bikes elétricas na contramão. (Rua antiga com arcadas · 2 cruzamentos (Tianhe Sul 1, Rua Tianhe))
- **De carro · Av. Tiyu Oeste**: Mão dupla com 6 faixas e trânsito pesadíssimo; táxis param na porta do Teemall e bikes de entrega vêm na contramão pelo canto.
  - Mão dupla, 6 faixas · guard-rail central · máx. 50 km/h · destino a 380 m · verde 8 s / vermelho 6 s · cruzamentos: Tianhe Sul 1, Rua Tianhe
  - Fontes: Av. Tiyu Oeste: sentido norte-sul, 44 m de largura, mão dupla com 6 faixas, trânsito muito intenso (Wikipédia)

| A pé / de bicicleta | De carro |
|---|---|
| ![Fase 1 a pé](docs/screenshots/walk_0.jpg) | ![Fase 1 de carro](docs/screenshots/drive_0.jpg) |

### Fase 2 · Shenzhen · Futian · Huaqiangbei
*Shenzhen · Huaqiang North*

- **A pé / de bicicleta**: Na porta do mercado de eletrônicos, bikes elétricas de carga com caixas mais altas que gente. (Avenida comercial de vidro · 2 cruzamentos (Rua Zhenhua, Rua Hongli))
- **De carro · Rua Zhenhua (mão única)**: A Huaqiangbei é calçadão, carro não entra; vá pela Rua Zhenhua: mão única de oeste para leste, com faixa para elétricas à direita, mas as bikes elétricas insistem em invadir a pista dos carros.
  - Mão única, 3 faixas · ciclofaixa à direita separada por guard-rail · máx. 40 km/h · destino a 320 m · verde 7 s / vermelho 5 s · cruzamentos: Rua Yannan, Rua Huafa Norte
  - Fontes: o trecho da Rua Huaqiangbei entre a Rua Hongli e a Av. Shennan é calçadão desde 2017, fechado a veículos; a Rua Zhenhua é mão única de oeste para leste e, desde 2021, testa a pista compartilhada carro-bike, com uma faixa para elétricas separada por guard-rail à direita (avisos da polícia de trânsito de Shenzhen / Nanfang+)

| A pé / de bicicleta | De carro |
|---|---|
| ![Fase 2 a pé](docs/screenshots/walk_1.jpg) | ![Fase 2 de carro](docs/screenshots/drive_1.jpg) |

### Fase 3 · Guangzhou · Yuexiu · Rua Beijing
*Guangzhou · Beijing Road*

- **A pé / de bicicleta**: Rua antiga de arcadas (qilou) com calçada estreita; barracas de doce e frades de pedra no caminho, tem que passar pela fresta. (Rua antiga com arcadas · calçada estreita · 2 cruzamentos (Rua Wenming, Rua Zhongshan 5))
- **De carro · Rua Zhongshan 5**: A Rua Beijing é calçadão, carro não entra; vá pela Rua Zhongshan 5: mão dupla com 4 faixas (est.), corredor de ônibus na faixa da direita no pico da tarde e ônibus parando um atrás do outro.
  - Mão dupla, 4 faixas · faixa amarela dupla · 1 corredor de ônibus à direita · máx. 40 km/h · destino a 240 m · verde 7 s / vermelho 6 s · cruzamentos: Cruz. Rua Beijing, Cruz. Rua Jixiang
  - Fontes: o trecho central da Rua Beijing é calçadão; de carro, só pela Rua Zhongshan, que a cruza (Wikipédia); Rua Zhongshan 5 entre a Rua Beijing e a Rua Jiefang; mais de trinta linhas de ônibus, corredor de ônibus nos horários de pico (Guangzhou Bendibao); número de faixas estimado: mão dupla com 4 faixas

| A pé / de bicicleta | De carro |
|---|---|
| ![Fase 3 a pé](docs/screenshots/walk_2.jpg) | ![Fase 3 de carro](docs/screenshots/drive_2.jpg) |

### Fase 4 · Shenzhen · Nanshan · Parque Tec.
*Shenzhen · Science Park*

- **A pé / de bicicleta**: Pico de entregas no almoço! Bi-bi sem parar atrás de você, e no vermelho as bikes elétricas se amontoam ao seu lado. (Avenida comercial de vidro · 3 cruzamentos (Rua Keyuan, Gaoxin Sul 1, Gaoxin Sul 4))
- **De carro · Rua Keyuan**: No pico do almoço a Rua Keyuan vira fila; bikes de entrega costuram entre os carros. Há onda verde: a cerca de 40 km/h você pega todos os sinais abertos.
  - Mão dupla, 7 faixas · canteiro central · máx. 50 km/h · destino a 400 m · verde 10 s / vermelho 5 s · **onda verde** · cruzamentos: Gaoxin Centro 1, Gaoxin Sul 1, Gaoxin Sul 4
  - Fontes: a Rua Keyuan fica extremamente congestionada nos picos; o sentido sul passou de 3 para 4 faixas (polícia de trânsito de Shenzhen / Zhihu); sentido norte com 3 faixas (est.); a polícia de trânsito de Shenzhen otimiza os tempos semafóricos com IA e cria trechos de onda verde (polícia de trânsito de Shenzhen), por isso os três cruzamentos aqui são coordenados em onda verde

| A pé / de bicicleta | De carro |
|---|---|
| ![Fase 4 a pé](docs/screenshots/walk_3.jpg) | ![Fase 4 de carro](docs/screenshots/drive_3.jpg) |

### Fase 5 · Guangzhou · Haizhu · Kecun
*Guangzhou · Kecun*

- **A pé / de bicicleta**: Saídas de estação de baldeação uma atrás da outra, com montanhas de bikes compartilhadas na porta. (Rua antiga com arcadas · 2 cruzamentos (Rua Xingang Centro, Rua Yiyuan))
- **De carro · Rua Xingang Centro**: Via principal de Haizhu, máx. 60, corredor de ônibus na faixa da direita; perto de Kecun os ônibus param o tempo todo.
  - Mão dupla, 6 faixas · canteiro central · 1 corredor de ônibus à direita · máx. 60 km/h · destino a 450 m · verde 9 s / vermelho 6 s · cruzamentos: Rua Xinshitou, Rua Yiyuan
  - Fontes: Rua Xingang: via principal do distrito de Haizhu, mão dupla com 2 a 6 faixas, máx. 60; a Rua Xingang Centro tem corredor de ônibus (Wikipédia / Sina)

| A pé / de bicicleta | De carro |
|---|---|
| ![Fase 5 a pé](docs/screenshots/walk_4.jpg) | ![Fase 5 de carro](docs/screenshots/drive_4.jpg) |

### Fase 6 · Shenzhen · Luohu · Dongmen
*Shenzhen · Dongmen*

- **A pé / de bicicleta**: Centro comercial antigo cheio de lojas; bikes elétricas saem das portas a qualquer momento. (Avenida comercial de vidro · 2 cruzamentos (Rua Jiefang, Rua Xinyuan))
- **De carro · Rua Dongmen Centro**: Mão dupla com 7 faixas, mas 2 de cada lado são só de ônibus e os carros se espremem no meio; na porta das lojas as bikes elétricas saem do nada.
  - Mão dupla, 7 faixas · faixa amarela dupla · 2 corredores de ônibus à direita · máx. 40 km/h · destino a 300 m · verde 7 s / vermelho 6 s · cruzamentos: Rua Jiefang, Rua Shaibu
  - Fontes: Rua Dongmen Centro: originalmente mão dupla com 7 faixas, sendo as 2 da direita de cada sentido corredores de ônibus; carros particulares entram em rodízio por placa par/ímpar (Shenzhen Bendibao / Wikipédia)

| A pé / de bicicleta | De carro |
|---|---|
| ![Fase 6 a pé](docs/screenshots/walk_5.jpg) | ![Fase 6 de carro](docs/screenshots/drive_5.jpg) |

### Fase 7 · Guangzhou · Zhujiang · Av. Huacheng
*Guangzhou · Huacheng Avenue*

- **A pé / de bicicleta**: Temporal! O chão está um sabão e ninguém consegue frear; com capa de chuva, os motoqueiros não enxergam nada. (Avenida comercial de vidro · temporal · 2 cruzamentos (Rua Xiancun, Av. Liede))
- **De carro · Av. Huacheng**: Mão dupla com 10 faixas, larga e rápida; no temporal a visibilidade cai, a pista fica lisa e a frenagem fica bem mais longa.
  - Mão dupla, 10 faixas · canteiro central · máx. 60 km/h · destino a 520 m · verde 10 s / vermelho 6 s · cruzamentos: Rua Xiancun, Av. Liede
  - Fontes: Av. Huacheng: 71 m de largura, mão dupla com 10 faixas, com túnel do CBD no trecho da Praça Huacheng (Wikipédia)

| A pé / de bicicleta | De carro |
|---|---|
| ![Fase 7 a pé](docs/screenshots/walk_6.jpg) | ![Fase 7 de carro](docs/screenshots/drive_6.jpg) |

### Fase 8 · Shenzhen · Futian · Chegongmiao
*Shenzhen · Chegongmiao*

- **A pé / de bicicleta**: Voltando do serão tarde da noite; postes fracos, só os faróis mostram onde estão as bikes elétricas. (Avenida comercial de vidro · noite · 2 cruzamentos (Rua Tairan 9, Rua Tian'an))
- **De carro · Av. Shennan**: Pista central da Av. Shennan com 8 faixas e marginais dos dois lados; de madrugada todo mundo corre, e bikes elétricas cortam o canteiro vindo da marginal.
  - Mão dupla, 8 faixas · canteiro central · marginais dos dois lados · máx. 60 km/h · destino a 480 m · verde 10 s / vermelho 6 s · **onda verde** · cruzamentos: Rua Tairan 9, Rua Xiangmei
  - Fontes: Av. Shennan: pista central com 6 a 8 faixas em mão dupla, marginais com 4 faixas em mão dupla, máx. 60 (Wiki de Transportes de Shenzhen)

| A pé / de bicicleta | De carro |
|---|---|
| ![Fase 8 a pé](docs/screenshots/walk_7.jpg) | ![Fase 8 de carro](docs/screenshots/drive_7.jpg) |

### Fase 9 · Guangzhou · Tianhe · Vila Shipai
*Guangzhou · Shipai Village*

- **A pé / de bicicleta**: Vila urbana de prédios colados, vielas estreitas lotadas de bikes elétricas e muito zigue-zague. (Vila urbana de prédios colados · calçada estreita · 1 cruzamento (Rua Shipai Leste))
- **De carro · Rua Shipai Leste**: Colada na vila Shipai: bikes elétricas brotam das vielas a qualquer hora, e há carro parado irregular um atrás do outro.
  - Mão dupla, 4 faixas · faixa amarela dupla · máx. 40 km/h · destino a 230 m · verde 6 s / vermelho 6 s · cruzamentos: Rua Xintao Norte, Rua Xintao Sul
  - Fontes: Rua Shipai Leste: deixou de ser mão única norte-sul e voltou a ser mão dupla; a vila Shipai tem quase 300 vielas (Sina / Xinhua); número de faixas estimado: mão dupla com 4 faixas

| A pé / de bicicleta | De carro |
|---|---|
| ![Fase 9 a pé](docs/screenshots/walk_8.jpg) | ![Fase 9 de carro](docs/screenshots/drive_8.jpg) |

### Fase 10 · Shenzhen · Nanshan · Baishizhou
*Shenzhen · Baishizhou*

- **A pé / de bicicleta**: A feira noturna da vila abriu, barracas tomam a calçada e bikes elétricas zanzam entre as sombras. (Vila urbana de prédios colados · noite · calçada estreita · 1 cruzamento (Rua Shahe))
- **De carro · Marginal Av. Shennan**: Marginal da Av. Shennan em Baishizhou, com a pista central depois do canteiro à esquerda; um ponto de ônibus atrás do outro, e as bikes elétricas da vila saem em bando da Rua Shahe.
  - Mão única, 2 faixas · canteiro (pista central do outro lado) · 1 corredor de ônibus à direita · máx. 40 km/h · destino a 250 m · verde 8 s / vermelho 6 s · cruzamentos: Rua Shahe, Rua Shizhou Centro
  - Fontes: trecho de Baishizhou da Av. Shennan: marginais dos dois lados da pista central, com vários pontos de ônibus na marginal perto da Rua Shahe (Wikipédia)

| A pé / de bicicleta | De carro |
|---|---|
| ![Fase 10 a pé](docs/screenshots/walk_9.jpg) | ![Fase 10 de carro](docs/screenshots/drive_9.jpg) |

### Fase 11 · Guangzhou · Baiyun · Xinshixu
*Guangzhou · Xinshixu*

- **A pé / de bicicleta**: Noite de temporal, escorregadio e escuro; na saída do metrô, fileiras de bikes compartilhadas. (Rua antiga com arcadas · temporal · noite · 2 cruzamentos (Av. do Aeroporto, Rua Xinshi Oeste))
- **De carro · Av. do Aeroporto**: Por cima passa o elevado da via expressa do aeroporto e os pilares tapam a visão; na noite de temporal a pista reflete tudo e não dá para ver as bikes elétricas na contramão pelo canto.
  - Mão dupla, 6 faixas · elevado por cima, pilares no meio · máx. 50 km/h · destino a 360 m · verde 8 s / vermelho 6 s · cruzamentos: Rua Qifu, Rua Huiqiao Sul
  - Fontes: em volta da estação Xinshixu ficam a Av. do Aeroporto e o elevado da via expressa do aeroporto (Wikipédia); número de faixas da via de baixo estimado: mão dupla com 6 faixas

| A pé / de bicicleta | De carro |
|---|---|
| ![Fase 11 a pé](docs/screenshots/walk_10.jpg) | ![Fase 11 de carro](docs/screenshots/drive_10.jpg) |

### Fase 12 · Shenzhen · Longhua · Minzhi
*Shenzhen · Minzhi*

- **A pé / de bicicleta**: O pico da tarde final: três sinais vermelhos, freadas, cargueiros, entregadores e fileiras de bikes elétricas, vem tudo junto. (Avenida comercial de vidro · 3 cruzamentos (Av. Minzhi, Rua Renmin, Av. Meilong))
- **De carro · Av. Minzhi**: Mão dupla com 6 faixas espremidas em 24 m, máx. 40, três sinais vermelhos no pico da tarde: freadas, cargueiros e bikes elétricas costurando, vem tudo junto.
  - Mão dupla, 6 faixas · guard-rail central · máx. 40 km/h · destino a 270 m · verde 7 s / vermelho 6 s · cruzamentos: Rua Renmin, Rua Meilong, Rua Gongye
  - Fontes: Av. Minzhi: via arterial do distrito de Longhua, 24 m de largura, máx. 40, mão dupla com 6 faixas (Wikipédia)

| A pé / de bicicleta | De carro |
|---|---|
| ![Fase 12 a pé](docs/screenshots/walk_11.jpg) | ![Fase 12 de carro](docs/screenshots/drive_11.jpg) |

## Como rodar

Requer o [Godot 4.7](https://godotengine.org/download).

```
Godot --path .                                         # 直接玩
Godot -e --path .                                      # 打开编辑器
Godot --path . -- --autostart=drive --level=7 --god    # 跳过菜单直接进关卡（walk/bike/drive，level 0–11），不掉血
Godot --path . -- --unlock-all | --reset-save | --rules | --support | --invincible
```

Os comentários acima, em ordem: jogar direto; abrir o editor; pular o menu e entrar direto numa fase (walk/bike/drive, level 0–11), sem perder vida.

## Testes
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

O que cada teste verifica:
- `car_overlap_test.gd`: a pé / de bicicleta — carros não se sobrepõem, carros não passam por cima de bikes elétricas, todos os cruzamentos aparecem.
- `drive_test.gd`: de carro — piloto automático percorre as 12 fases sem nenhuma sobreposição entre participantes.
- `jaywalk_test.gd`: avançar o sinal tira 25%, o avanço é retomado, ser atingido por carro dá GAME OVER.
- `jaywalk_keys_test.gd`: teclas reais — segurar W / Espaço permite avançar o sinal.
- `font_test.gd`: todos os caracteres chineses são exibidos (lista os que faltam na Smiley Sans e caem na fonte do sistema).
- `invincible_test.gd`: correria no Modo Invencível — o jogador não atravessa nada.
- `light_test.gd`: os semáforos não travam no vermelho.
- `audit_test.gd`: check-up das fases de carro — taxa de chegada / engarrafamento / maior vermelho / desvios / sobreposições.

As capturas de tela são geradas com `tools/screenshot.gd` (durante a gravação, mantenha a janela sem nada por cima, ou use `--always-on-top`):
```
Godot --always-on-top --path . --script tools/screenshot.gd --write-movie /tmp/shot/f.png --fixed-fps 10 --quit-after 200 -- --only=0 --mode=drive
```

## Outros
- Todos os gráficos e sons são gerados por código, sem nenhum asset de arte externo.
- Fonte: [得意黑 Smiley Sans](https://github.com/atelier-anchor/smiley-sans) (SIL OFL 1.1, licença em `fonts/SmileySans-OFL.txt`); caracteres ausentes caem na fonte chinesa do sistema.
- Local do save: `user://save.cfg` (progresso desbloqueado, melhor resultado de cada fase, meio de transporte, se as regras já foram vistas, Modo Invencível ligado/desligado).
- O menu tem uma página "Apoie o autor" (clique no endereço para copiar); para escondê-la, mude `SUPPORT_ENABLED` para `false` em `scripts/main.gd`.
