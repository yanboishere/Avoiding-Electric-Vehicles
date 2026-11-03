🌐 [简体中文](README.md) · [English](README.en.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Français](README.fr.md) · [Español](README.es.md) · [Deutsch](README.de.md) · [العربية](README.ar.md) · **Tiếng Việt** · [Português](README.pt.md) · [Italiano](README.it.md)

▶ **Chơi trên trình duyệt (điện thoại / máy tính)**: https://yanbowa.ng/Avoiding-Electric-Vehicles/

# Né Xe Điện (Avoiding Electric Vehicles)

> Ở Quảng Châu và Thâm Quyến, rất nhiều đoạn đường không có làn xe thô sơ. Bạn ra đường đi bộ, đạp xe hay lái ô tô, và xe điện sẽ ùa ra từ khắp mọi hướng: chạy ngược chiều, vượt ẩu, luồn lách, lao ngang, phanh gấp… Hãy sống sót qua một phút nhé.

Godot 4 (GL Compatibility) · Windows / macOS · 1280×720 · 12 màn · Đi bộ / Đạp xe / Lái xe + Chế độ Vô địch

![Menu chính](docs/screenshots/menu.jpg)

## Cách chơi

| Thao tác | Đi bộ / Đạp xe | Lái xe |
|---|---|---|
| Di chuyển | WASD / phím mũi tên / cần analog tay cầm | W tăng tốc · S phanh · A / D chuyển làn |
| Vượt đèn đỏ | Đứng ở mép vỉa hè giữ ↑ nửa giây, hoặc nhấn Space / nút A tay cầm | Khi đèn đỏ cứ lao thẳng qua vạch dừng |
| Tạm dừng / Thoát | ESC để tạm dừng, trong lúc tạm dừng nhấn Q để về menu | Như bên trái |
| Toàn màn hình | F11 hoặc Alt+Enter | Như bên trái |

**Mục tiêu**
- Đi bộ / Đạp xe: mỗi màn 60 giây, cứ đi thẳng dọc vỉa hè, bị tông 3 lần là thua.
- Lái xe: lái tới đích trong 60 giây, quá giờ tính là trễ; đâm xe, đâm xe điện, đâm người đi bộ đều mất mạng.

**Bạn sẽ gặp**
- **Xe điện**: chạy ngược chiều đâm thẳng tới, vượt từ phía sau (cảnh báo bằng tam giác đỏ ở đáy màn hình + tiếng "bíp bíp"), lạng lách, lao ra từ cửa tiệm / lề đường, luồn lách giữa dòng xe, bất ngờ phanh gấp để giao đồ ăn (dừng lại rồi thành chướng ngại vật), chở hàng, mặc áo mưa…
- **Người đi bộ**: đi chậm cùng chiều, đi ngược lại phía bạn, cắm mặt vào điện thoại đi xiêu vẹo, đi hàng ngang, đứng im một chỗ; khi lái xe còn có người qua vạch kẻ đường và băng ngang đường ẩu.
- **Chướng ngại vật**: lối lên metro, xe đạp công cộng, xe điện đỗ bên đường, cột đá, sạp hàng; khi lái xe có xe đậu sai chỗ, rào công trình, xe buýt vào trạm. Chướng ngại vật là vật cứng, bị ép xuống mép dưới màn hình sẽ vấp ngã và mất máu.
- **Đèn giao thông**: đi bộ gặp đèn đỏ thì màn hình dừng lại, trong lúc chờ đèn vẫn có xe điện vượt đèn đỏ và chen sát bên bạn; lái xe thì phải tự phanh dừng. **Vượt đèn đỏ sẽ mất 25% số điểm hiện có, bị xe phố ngang tông giữa giao lộ là GAME OVER luôn.**
- **Thời tiết**: trời mưa lớn mặt đường trơn, quãng phanh dài hơn; ban đêm màn hình tối lại, chỉ có thể dựa vào đèn xe và đèn đường để quan sát.

**Điểm và xếp hạng**
- Trụ càng lâu / lái càng xa thì càng nhiều điểm; sượt qua +50; qua màn được +300 cho mỗi mạng còn lại (lái xe được cộng thêm điểm thời gian còn dư).
- Khi lái xe, chiếm làn xe buýt bị -15 mỗi giây (mượn làn để tránh công trình hay xe đậu sai chỗ thì không bị trừ).
- Xếp hạng: S qua màn không lỗi · A bị tông 1 lần · B qua màn · C thua.
- **Phải qua màn trước mới mở khóa màn sau**, kết quả được lưu tự động.

| Trang luật chơi (tự hiện ra lần đầu bắt đầu chơi) | Màn hình kết quả khi thua |
|---|---|
| ![Luật chơi](docs/screenshots/rules.jpg) | ![Kết quả](docs/screenshots/result.jpg) |

## Chế độ chơi

### 🚶 Đi bộ
Linh hoạt nhất, muốn dừng là dừng, muốn đi là đi. Né xe điện và người đi bộ trên vỉa hè dưới dãy nhà lầu vòm (qilou), phố thương mại tường kính và làng trong phố; gặp ngã tư thì phải chờ đèn đỏ.

![Đi bộ chờ đèn đỏ](docs/screenshots/red_light.jpg)

### 🚲 Đạp xe
Nhanh hơn, nhưng có quán tính, phạm vi va chạm lớn hơn, trời mưa lớn càng dễ phanh không kịp.

![Chế độ đạp xe](docs/screenshots/bike_mode.jpg)

### 🚗 Lái xe
Mỗi màn được đổi sang một **đoạn đường có thật, ô tô chạy được** ở gần đó (khi phố đi bộ hay hẻm trong làng trong phố không cho ô tô vào thì chuyển sang con đường bên cạnh): số làn, dải phân cách giữa, đường gom / làn xe thô sơ, làn xe buýt, tốc độ tối đa, tên các ngã tư đều được thiết kế theo tài liệu công khai. Góc dưới bên trái là tốc độ, biển tốc độ tối đa và quãng đường còn lại; góc trên bên phải là đèn tín hiệu của ngã tư phía trước.

![Chế độ lái xe](docs/screenshots/drive_6.jpg)

### 💥 Chế độ Vô địch
Bật bằng một nút ở màn hình chính: không mất máu, phớt lờ đèn đỏ, xe điện nào đụng phải đều bị **hất bay** (mỗi xe +100, có combo), mở sẵn cả 12 màn. Người đi bộ và xe cộ vẫn là vật cứng, không xuyên qua nhau. Kết quả ở chế độ Vô địch không được lưu.  
Khi lái xe, ô tô, taxi và xe buýt cũng bị hất bay (ô tô +200, xe buýt +300); người đi bộ và rào công trình thì không.

| Đi bộ vô địch | Lái xe vô địch |
|---|---|
| ![Đi bộ vô địch](docs/screenshots/invincible_walk.jpg) | ![Lái xe vô địch](docs/screenshots/invincible_drive.jpg) |

## Giới thiệu các màn

Quảng Châu và Thâm Quyến xen kẽ nhau, độ khó tăng dần. Cấu hình của từng màn nằm trong `scripts/levels.gd` (đoạn đường lái xe nằm trong `DRIVE`, phần chú thích ghi nguồn tư liệu về tình hình giao thông, chỗ nào không tra được số liệu chính xác thì ghi "估" — ước tính).

### Màn 1 · Quảng Châu · Tianhe · Đường Tiyu Tây
*Guangzhou · Tiyu West Road*

- **Đi bộ / Đạp xe**: Màn tập sự: ngoài ga metro Tiyu Tây, nhiều xe điện chạy ngược chiều đâm thẳng tới nhất. (Phố cổ qilou · 2 ngã tư (Đường Tianhe Nam 1, Đường Tianhe))
- **Lái xe · Đường Tiyu Tây**: 6 làn hai chiều, xe cộ đông nghịt, taxi đón trả khách trước Tianhe City, xe điện giao đồ ăn chạy ngược chiều sát lề.
  - 6 làn hai chiều · rào chắn giữa · tối đa 50 km/h · đích cách 380 m · đèn xanh 8 giây / đèn đỏ 6 giây · ngã tư: Đường Tianhe Nam 1, Đường Tianhe
  - Căn cứ: Đường Tiyu Tây: hướng bắc–nam, rộng 44 m, 6 làn hai chiều, lưu lượng xe cực lớn (Wikipedia)

| Đi bộ / Đạp xe | Lái xe |
|---|---|
| ![Màn 1 đi bộ](docs/screenshots/walk_0.jpg) | ![Màn 1 lái xe](docs/screenshots/drive_0.jpg) |

### Màn 2 · Thâm Quyến · Futian · Huaqiang Bắc
*Shenzhen · Huaqiang North*

- **Đi bộ / Đạp xe**: Trước chợ điện tử, xe điện chở hàng chất thùng giấy cao hơn cả người. (Phố thương mại tường kính · 2 ngã tư (Đường Zhenhua, Đường Hongli))
- **Lái xe · Đường Zhenhua (một chiều)**: Đường Huaqiang Bắc là phố đi bộ, ô tô không vào được nên đi đường Zhenhua: một chiều từ tây sang đông, bên phải có làn xe điện, vậy mà xe điện cứ thích chạy vào làn ô tô.
  - 3 làn một chiều · bên phải có làn xe thô sơ ngăn bằng rào chắn · tối đa 40 km/h · đích cách 320 m · đèn xanh 7 giây / đèn đỏ 5 giây · ngã tư: Đường Yannan, Đường Huafa Bắc
  - Căn cứ: Đường Huaqiang Bắc đoạn Hongli–Shennan là phố đi bộ từ năm 2017, ô tô không được vào; đường Zhenhua một chiều từ tây sang đông, năm 2021 thí điểm chung mặt đường ô tô – xe thô sơ, bên phải có rào chắn tách ra làn xe điện (thông báo của CSGT Thâm Quyến / Nanfang+)

| Đi bộ / Đạp xe | Lái xe |
|---|---|
| ![Màn 2 đi bộ](docs/screenshots/walk_1.jpg) | ![Màn 2 lái xe](docs/screenshots/drive_1.jpg) |

### Màn 3 · Quảng Châu · Yuexiu · Đường Bắc Kinh
*Guangzhou · Beijing Road*

- **Đi bộ / Đạp xe**: Phố cổ nhà lầu vòm (qilou) vỉa hè hẹp, quán chè, cột đá chắn lối, phải lách qua khe hở. (Phố cổ qilou · vỉa hè hẹp · 2 ngã tư (Đường Wenming, Đường Zhongshan 5))
- **Lái xe · Đường Zhongshan 5**: Phố đi bộ Bắc Kinh không cho ô tô vào nên đi đường Zhongshan 5: 4 làn hai chiều (ước tính), giờ cao điểm chiều làn ngoài cùng bên phải dành cho xe buýt, xe buýt nối đuôi nhau vào trạm.
  - 4 làn hai chiều · vạch vàng kép · 1 làn xe buýt ngoài cùng bên phải · tối đa 40 km/h · đích cách 240 m · đèn xanh 7 giây / đèn đỏ 6 giây · ngã tư: Ngã tư Bắc Kinh, Ngã tư Jixiang
  - Căn cứ: đoạn giữa đường Bắc Kinh là phố đi bộ, ô tô chỉ có thể đi đường Zhongshan cắt ngang (Wikipedia); đường Zhongshan 5 từ ngã tư Bắc Kinh đến đường Jiefang; hơn ba mươi tuyến xe buýt, làn xe buýt giờ cao điểm (Guangzhou Bendibao); số làn ước tính: 4 làn hai chiều

| Đi bộ / Đạp xe | Lái xe |
|---|---|
| ![Màn 3 đi bộ](docs/screenshots/walk_2.jpg) | ![Màn 3 lái xe](docs/screenshots/drive_2.jpg) |

### Màn 4 · Thâm Quyến · Nanshan · Khu Công nghệ
*Shenzhen · Science Park*

- **Đi bộ / Đạp xe**: Cao điểm giao cơm trưa! Phía sau bíp bíp liên hồi, đèn đỏ thì xe điện chen chúc quanh bạn. (Phố thương mại tường kính · 3 ngã tư (Đường Keyuan, Gaoxin Nam 1, Gaoxin Nam 4))
- **Lái xe · Đường Keyuan**: Giờ cao điểm trưa đường Keyuan kẹt dài, xe điện giao đồ ăn luồn lách giữa các xe; các ngã tư có làn sóng xanh, giữ khoảng 40km/h là đèn xanh suốt.
  - 7 làn hai chiều · dải cây xanh giữa · tối đa 50 km/h · đích cách 400 m · đèn xanh 10 giây / đèn đỏ 5 giây · **làn sóng xanh** · ngã tư: Gaoxin Trung 1, Gaoxin Nam 1, Gaoxin Nam 4
  - Căn cứ: đường Keyuan giờ cao điểm sáng và chiều kẹt cực nặng, chiều đi về nam được mở rộng từ 3 lên 4 làn (CSGT Thâm Quyến / Zhihu); chiều đi về bắc 3 làn (ước tính); CSGT Thâm Quyến dùng AI tối ưu chu kỳ đèn, tạo các đoạn làn sóng xanh (CSGT Thâm Quyến), ở đây ba ngã tư được phối hợp theo làn sóng xanh

| Đi bộ / Đạp xe | Lái xe |
|---|---|
| ![Màn 4 đi bộ](docs/screenshots/walk_3.jpg) | ![Màn 4 lái xe](docs/screenshots/drive_3.jpg) |

### Màn 5 · Quảng Châu · Haizhu · Kecun
*Guangzhou · Kecun*

- **Đi bộ / Đạp xe**: Cửa ga trung chuyển nối tiếp nhau, xe đạp công cộng trước cửa chất thành núi. (Phố cổ qilou · 2 ngã tư (Đường Xingang Trung, Đường Yiyuan))
- **Lái xe · Đường Xingang Trung**: Trục chính của Haizhu, tối đa 60, làn ngoài cùng bên phải dành cho xe buýt, khu Kecun xe buýt vào trạm dày đặc.
  - 6 làn hai chiều · dải cây xanh giữa · 1 làn xe buýt ngoài cùng bên phải · tối đa 60 km/h · đích cách 450 m · đèn xanh 9 giây / đèn đỏ 6 giây · ngã tư: Đường Xinshitou, Đường Yiyuan
  - Căn cứ: đường Xingang: trục chính quận Haizhu, 2–6 làn hai chiều, tối đa 60; đường Xingang Trung có làn xe buýt (Wikipedia / Sina)

| Đi bộ / Đạp xe | Lái xe |
|---|---|
| ![Màn 5 đi bộ](docs/screenshots/walk_4.jpg) | ![Màn 5 lái xe](docs/screenshots/drive_4.jpg) |

### Màn 6 · Thâm Quyến · Luohu · Dongmen
*Shenzhen · Dongmen*

- **Đi bộ / Đạp xe**: Khu buôn bán cũ dày đặc cửa hàng, xe điện có thể lao ra từ cửa tiệm bất cứ lúc nào. (Phố thương mại tường kính · 2 ngã tư (Đường Jiefang, Đường Xinyuan))
- **Lái xe · Đường Dongmen Trung**: 7 làn hai chiều, nhưng mỗi bên có 2 làn dành cho xe buýt, xe thường chỉ chen được ở giữa; xe điện trước cửa tiệm nói lao là lao.
  - 7 làn hai chiều · vạch vàng kép · 2 làn xe buýt ngoài cùng bên phải · tối đa 40 km/h · đích cách 300 m · đèn xanh 7 giây / đèn đỏ 6 giây · ngã tư: Đường Jiefang, Đường Shaibu
  - Căn cứ: đường Dongmen Trung: vốn có 7 làn hai chiều, mỗi chiều bắc–nam có 2 làn sát bên phải dành cho xe buýt, xe thường vào theo biển số chẵn lẻ (Shenzhen Bendibao / Wikipedia)

| Đi bộ / Đạp xe | Lái xe |
|---|---|
| ![Màn 6 đi bộ](docs/screenshots/walk_5.jpg) | ![Màn 6 lái xe](docs/screenshots/drive_5.jpg) |

### Màn 7 · Quảng Châu · Zhujiang · Đại lộ Huacheng
*Guangzhou · Huacheng Avenue*

- **Đi bộ / Đạp xe**: Mưa lớn! Mặt đường trơn trượt khó dừng chân, xe điện mặc áo mưa chẳng nhìn rõ đường. (Phố thương mại tường kính · mưa lớn · 2 ngã tư (Đường Xiancun, Đại lộ Liede))
- **Lái xe · Đại lộ Huacheng**: 10 làn hai chiều vừa rộng vừa nhanh, trời mưa lớn tầm nhìn kém, mặt đường trơn, quãng phanh dài ra thấy rõ.
  - 10 làn hai chiều · dải cây xanh giữa · tối đa 60 km/h · đích cách 520 m · đèn xanh 10 giây / đèn đỏ 6 giây · ngã tư: Đường Xiancun, Đại lộ Liede
  - Căn cứ: đại lộ Huacheng: rộng 71 m, 10 làn hai chiều, đoạn quảng trường Huacheng có hầm CBD (Wikipedia)

| Đi bộ / Đạp xe | Lái xe |
|---|---|
| ![Màn 7 đi bộ](docs/screenshots/walk_6.jpg) | ![Màn 7 lái xe](docs/screenshots/drive_6.jpg) |

### Màn 8 · Thâm Quyến · Futian · Chegongmiao
*Shenzhen · Chegongmiao*

- **Đi bộ / Đạp xe**: Tăng ca về khuya, đèn đường lờ mờ, chỉ biết nhìn đèn xe đoán xe điện ở đâu. (Phố thương mại tường kính · ban đêm · 2 ngã tư (Đường Tairan 9, Đường Tian'an))
- **Lái xe · Đại lộ Shennan**: Đường chính đại lộ Shennan có 8 làn hai chiều, hai bên là đường gom; đêm khuya xe chạy nhanh, xe điện từ đường gom băng qua khe dải cây xanh lao thẳng vào đường chính.
  - 8 làn hai chiều · dải cây xanh giữa · hai bên có đường gom · tối đa 60 km/h · đích cách 480 m · đèn xanh 10 giây / đèn đỏ 6 giây · **làn sóng xanh** · ngã tư: Đường Tairan 9, Đường Xiangmei
  - Căn cứ: đại lộ Shennan: đường chính 6–8 làn hai chiều, đường gom 4 làn hai chiều, tối đa 60 (Shenzhen Transport Wiki)

| Đi bộ / Đạp xe | Lái xe |
|---|---|
| ![Màn 8 đi bộ](docs/screenshots/walk_7.jpg) | ![Màn 8 lái xe](docs/screenshots/drive_7.jpg) |

### Màn 9 · Quảng Châu · Tianhe · Làng Shipai
*Guangzhou · Shipai Village*

- **Đi bộ / Đạp xe**: Làng trong phố nhà san sát, hẻm hẹp, xe điện đỗ kín, lạng lách cực nhiều. (Làng trong phố nhà san sát · vỉa hè hẹp · 1 ngã tư (Đường Shipai Đông))
- **Lái xe · Đường Shipai Đông**: Sát làng Shipai, xe điện có thể lao ra từ đầu hẻm bất cứ lúc nào, xe đậu sai chỗ bên đường nối đuôi nhau.
  - 4 làn hai chiều · vạch vàng kép · tối đa 40 km/h · đích cách 230 m · đèn xanh 6 giây / đèn đỏ 6 giây · ngã tư: Phố Xintao Bắc, Phố Xintao Nam
  - Căn cứ: đường Shipai Đông: từ một chiều bắc → nam đã trở lại thành hai chiều; trong làng Shipai có gần 300 con hẻm (Sina / Xinhuanet); số làn ước tính: 4 làn hai chiều

| Đi bộ / Đạp xe | Lái xe |
|---|---|
| ![Màn 9 đi bộ](docs/screenshots/walk_8.jpg) | ![Màn 9 lái xe](docs/screenshots/drive_8.jpg) |

### Màn 10 · Thâm Quyến · Nanshan · Baishizhou
*Shenzhen · Baishizhou*

- **Đi bộ / Đạp xe**: Chợ đêm làng trong phố mở hàng, sạp lấn lối đi, xe điện lao loạn xạ trong ánh đèn. (Làng trong phố nhà san sát · ban đêm · vỉa hè hẹp · 1 ngã tư (Phố Shahe))
- **Lái xe · Đường gom Shennan**: Đường gom Shennan đoạn Baishizhou, bên kia dải cây xanh bên trái là đường chính; trạm xe buýt nối tiếp nhau, xe điện từ làng trong phố ùa ra ở đầu phố Shahe.
  - 2 làn một chiều · dải cây xanh (phía ngoài là đường chính) · 1 làn xe buýt ngoài cùng bên phải · tối đa 40 km/h · đích cách 250 m · đèn xanh 8 giây / đèn đỏ 6 giây · ngã tư: Phố Shahe, Đường Shizhou Trung
  - Căn cứ: đại lộ Shennan đoạn Baishizhou: hai bên đường chính có đường gom, gần đầu phố Shahe trên đường gom có nhiều trạm xe buýt (Wikipedia)

| Đi bộ / Đạp xe | Lái xe |
|---|---|
| ![Màn 10 đi bộ](docs/screenshots/walk_9.jpg) | ![Màn 10 lái xe](docs/screenshots/drive_9.jpg) |

### Màn 11 · Quảng Châu · Baiyun · Xinshixu
*Guangzhou · Xinshixu*

- **Đi bộ / Đạp xe**: Đêm mưa lớn, vừa trơn vừa tối, ngoài lối lên metro xếp đầy xe đạp công cộng. (Phố cổ qilou · mưa lớn · ban đêm · 2 ngã tư (Đường Sân Bay, Phố Xinshi Tây))
- **Lái xe · Đường Sân Bay**: Trên đầu là cầu cạn cao tốc sân bay, trụ cầu che khuất tầm nhìn, đêm mưa lớn mặt đường lóa sáng, khó thấy xe điện chạy ngược chiều sát lề.
  - 6 làn hai chiều · cầu cạn trên đầu, trụ cầu phân cách · tối đa 50 km/h · đích cách 360 m · đèn xanh 8 giây / đèn đỏ 6 giây · ngã tư: Đường Qifu, Đường Huiqiao Nam
  - Căn cứ: quanh ga Xinshixu là đường Sân Bay và cầu cạn cao tốc sân bay (Wikipedia); số làn đường mặt đất ước tính: 6 làn hai chiều

| Đi bộ / Đạp xe | Lái xe |
|---|---|
| ![Màn 11 đi bộ](docs/screenshots/walk_10.jpg) | ![Màn 11 lái xe](docs/screenshots/drive_10.jpg) |

### Màn 12 · Thâm Quyến · Longhua · Minzhi
*Shenzhen · Minzhi*

- **Đi bộ / Đạp xe**: Giờ cao điểm chiều tối thượng: ba đèn đỏ, xe điện phanh gấp, chở hàng, giao đồ ăn, nối hàng dài kéo đến đủ cả. (Phố thương mại tường kính · 3 ngã tư (Đại lộ Minzhi, Đường Renmin, Đại lộ Meilong))
- **Lái xe · Đại lộ Minzhi**: 6 làn hai chiều chen trên con đường rộng 24 mét, tối đa 40, giờ cao điểm chiều ba đèn đỏ, xe điện phanh gấp, chở hàng, luồn lách kéo đến đủ cả.
  - 6 làn hai chiều · rào chắn giữa · tối đa 40 km/h · đích cách 270 m · đèn xanh 7 giây / đèn đỏ 6 giây · ngã tư: Đường Renmin, Đường Meilong, Đường Gongye
  - Căn cứ: đại lộ Minzhi: trục chính đô thị của quận Longhua, rộng 24 m, tối đa 40, 6 làn hai chiều (Wikipedia)

| Đi bộ / Đạp xe | Lái xe |
|---|---|
| ![Màn 12 đi bộ](docs/screenshots/walk_11.jpg) | ![Màn 12 lái xe](docs/screenshots/drive_11.jpg) |

## Chạy game

Cần [Godot 4.7](https://godotengine.org/download).

```
Godot --path .                                         # 直接玩
Godot -e --path .                                      # 打开编辑器
Godot --path . -- --autostart=drive --level=7 --god    # 跳过菜单直接进关卡（walk/bike/drive，level 0–11），不掉血
Godot --path . -- --unlock-all | --reset-save | --rules | --support | --invincible
```

Giải thích: dòng 1 — chơi ngay; dòng 2 — mở trình biên tập; dòng 3 — bỏ qua menu vào thẳng màn chơi (walk/bike/drive, level 0–11), không mất máu.

## Kiểm thử
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

- `car_overlap_test.gd`: đi bộ/đạp xe — xe không chồng lên nhau, ô tô không đè lên xe điện, ngã tư nào cũng xuất hiện
- `drive_test.gd`: lái xe — tự lái chạy hết 12 màn, không đối tượng nào chồng lên nhau
- `jaywalk_test.gd`: vượt đèn đỏ mất 25%, tiếp tục tiến lên, bị xe tông là GAME OVER
- `jaywalk_keys_test.gd`: phím thật — giữ W / Space đều vượt được
- `font_test.gd`: mọi ký tự tiếng Trung đều hiển thị được (liệt kê các chữ Smiley Sans thiếu, phải dùng font hệ thống)
- `invincible_test.gd`: lao loạn ở chế độ Vô địch — người chơi không xuyên qua bất cứ thứ gì
- `light_test.gd`: đèn tín hiệu không bị kẹt ở đèn đỏ
- `audit_test.gd`: kiểm tra tổng quát các màn lái xe — tỷ lệ tới đích / kẹt xe / đèn đỏ dài nhất / mượn làn / chồng lấn

Ảnh chụp màn hình được tạo bằng `tools/screenshot.gd` (khi quay hãy để cửa sổ không bị che, hoặc thêm `--always-on-top`):
```
Godot --always-on-top --path . --script tools/screenshot.gd --write-movie /tmp/shot/f.png --fixed-fps 10 --quit-after 200 -- --only=0 --mode=drive
```

## Bản web / Điện thoại

Chơi được trên trình duyệt điện thoại, máy tính bảng mà không cần bàn phím hay tay cầm (nút cảm ứng tự hiện).
- Cảm ứng: nhấn và kéo ở nửa trái = cần điều khiển (khi lái xe là chuyển làn); khi lái xe có ga / phanh ở góc dưới phải; khi đi bộ đến mép đường lúc đèn đỏ sẽ hiện nút "vượt đèn đỏ"; II phía trên để tạm dừng. Hãy chơi ở chế độ ngang.
- Xuất bản: `Godot --headless --path . --export-release "Web" build/web/index.html` (đơn luồng, chạy trên mọi hosting tĩnh)
- Thử trên máy / mạng nội bộ: `python3 tools/serve_web.py`, rồi mở địa chỉ hiện ra trên điện thoại cùng Wi-Fi
- Kiểm thử đầu-cuối (Chrome giả lập điện thoại cảm ứng nằm ngang): `python3 tools/mobile_web_test.py`; kiểm thử cảm ứng: `tests/touch_test.gd`
- Trình duyệt không có font hệ thống nên tiếng Nhật, Hàn, Ả Rập, Việt dùng các font Noto rút gọn trong `fonts/noto/` (tạo bằng `tools/build_fonts.py`)

## Khác
- Hình ảnh và âm thanh đều được tạo bằng code, không dùng tài nguyên đồ họa bên ngoài.
- Font: [得意黑 Smiley Sans](https://github.com/atelier-anchor/smiley-sans) (SIL OFL 1.1, giấy phép xem `fonts/SmileySans-OFL.txt`), khi thiếu chữ sẽ dùng font tiếng Trung của hệ thống.
- Vị trí lưu game: `user://save.cfg` (tiến độ mở khóa, kết quả tốt nhất từng màn, phương tiện, đã xem luật chơi hay chưa, bật/tắt chế độ Vô địch).
- Màn hình chính có trang "Ủng hộ tác giả" (bấm vào địa chỉ để sao chép); đổi `SUPPORT_ENABLED` trong `scripts/main.gd` thành `false` để ẩn trang này.
