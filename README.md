# 🚀 Arch Linux Dotfile Kurulum Scripti

[](https://archlinux.org/)
[](https://hyprland.org/)
[![License MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

| ![Masaüstü ve panel](/resimler/2026-09-10_08-21-48.png) | ![Alacritty terminal](/resimler/2026-09-10_08-22-14.png) |
| --- | --- |
| ![Nemo dosya yöneticisi](/resimler/2026-09-10_08-22-42.png) | ![Rofi uygulama başlatıcı](/resimler/2026-09-10_08-23-16.png) |

---

## 🚀 Hızlı Kurulum

```bash
git clone https://github.com/koesan/Arch_Dotfile.git
cd Arch_Dotfile
chmod +x arch_dotfile_installer.sh
./arch_dotfile_installer.sh
```

Hepsi bu. Script paketleri kurar, servisleri açar, yapılandırmaları yerine
taşır ve temayı ayarlar. Sonunda yeniden başlatıp giriş ekranında **Hyprland**
oturumunu seçmeniz yeterli.

### 🔎 Önce görmek isterseniz

```bash
./arch_dotfile_installer.sh --dry-run   # hiçbir şey yapmaz, ne olacağını yazar
```

### ✅ Kurulumdan sonra doğrulama

```bash
./arch_dotfile_installer.sh --check     # eksik paket / dosya / servis var mı?
```

### ⚙️ Diğer seçenekler

| Seçenek | Ne yapar |
| --- | --- |
| `--dry-run` | Hiçbir değişiklik yapmadan tüm komutları listeler |
| `--check` | Kurulum sonrası doğrulama raporu üretir |
| `--minimal` | İsteğe bağlı paketleri atlar: LibreOffice, Docker, VS Code, Brave, Flatpak (+MarkText), MS fontları, xsensors |
| `--no-aur` | AUR paketlerini atlar (wlogout ve Catppuccin temaları kurulmaz) |
| `-y`, `--yes` | Soru sormaz, tam otomatik kurar |
| `--help` | Yardım |

---

## ✨ Bu kurulumun özellikleri

- **Tek komut.** Paketler, servisler, yapılandırmalar, tema — hepsi tek çalıştırmada.
- **Taşınabilir.** Depoda hiçbir ekran adı, GPU modeli veya sensör yolu sabit
  değildir. Ekran düzeni otomatik algılanır, CPU sıcaklık sensörü kurulum
  sırasında bulunur. Aynı depo farklı bir Arch bilgisayarda düzenlenmeden çalışır.
- **Yeniden çalıştırılabilir.** İkinci kez çalıştırmak zarar vermez; sadece
  eksikleri tamamlar.
- **Yıkıcı değil.** Üzerine yazılan her dosya önce
  `~/.config/arch-dotfile-backup/<tarih>/` altına yedeklenir.
- **Kısmi hataya dayanıklı.** Bir paket kurulamazsa kurulum durmaz; sonunda
  neyin başarısız olduğu özetlenir.
- **Makineye özel ayarlarınız korunur.** `~/.config/hypr/lua/local.lua` ve
  kendi koyduğunuz duvar kağıdı güncellemelerde silinmez.

---

## 🎨 Tema

Masaüstünün tamamı tek bir palet kullanır: **Catppuccin Mocha**. Tek istisna
terminaldir: Alacritty **Blood Moon** paletini kullanır (arka planı neredeyse
siyah olduğu için `opacity = 0.9` ile duvar kağıdı gerçekten görünür — Mocha'nın
daha açık arka planında aynı değer opak görünüyordu).

| Bileşen | Nereden gelir |
| --- | --- |
| Hyprland kenarlık/gölge | `configs/hypr/lua/theme.lua` (renklerin tek kaynağı) |
| Waybar | `configs/waybar/style.css` |
| Rofi | `configs/rofi/theme.rasi` |
| Mako (bildirimler) | `configs/mako/config` |
| wlogout | `configs/wlogout/style.css` |
| Hyprlock (kilit ekranı) | `configs/hypr/hyprlock.conf` |
| Alacritty | `configs/alacritty/themes/blood_moon.toml` (hafif saydam) |
| GTK 3 / GTK 4 | Kurulum sırasında `catppuccin-gtk-theme-mocha` (AUR) |
| Qt 5 / Qt 6 | Kurulum sırasında üretilen qt5ct/qt6ct renk şeması |
| İmleç | Kurulum sırasında `catppuccin-cursors-mocha` (AUR) → **koyu (siyah) varyant** |
| Simgeler | `dracula-icons-main` (depoda gömülü) |

**Tema otomatik indirilir.** GTK teması ve imleçler AUR'dan kurulur. AUR'a
erişilemezse veya `--no-aur` kullanılırsa kurulum durmaz: depoda gömülü olan
`Andromeda-gtk` temasına ve `Adwaita` imleçlerine düşülür. Script her zaman
**gerçekten kurulu olan** temanın adını yazar — var olmayan bir tema adı
hiçbir ayar dosyasına yazılmaz.

İmleç renginde bir ayrıntı: `catppuccin-cursors-mocha` on altı renk varyantını
birden kurar. Kurulum betiği bunlar arasından `catppuccin-mocha-dark-cursors`
(siyah) varyantını seçer. Başka bir renk isterseniz tek yapmanız gereken
`~/.icons/default/index.theme` içindeki `Inherits=` satırını ve
`~/.config/hypr/lua/cursor.lua` içindeki tema adını değiştirmek.

Paleti değiştirmek isterseniz başlangıç noktası `configs/hypr/lua/theme.lua`
dosyasıdır; her stil dosyasının başında da kendi palet bloğu bulunur.

---

## 🖥️ Ekran düzeni ve makineye özel ayarlar

Varsayılan olarak **hiçbir ekran adı varsayılmaz**: bağlı olan tüm ekranlar
tercih edilen çözünürlükte, otomatik konumda ve **1:1 ölçekte** açılır;
dizüstü paneli varsa en yüksek tazeleme hızı seçilir.

> Ölçek neden `auto` değil? Hyprland'in otomatik ölçeği EDID'deki fiziksel
> panel boyutundan DPI hesaplıyor ve 14–15" bir 1080p dizüstü panelinde 1.5
> çıkarıyor: yazılar, panel ve pencereler %50 büyüyor, ekran 1280x720 gibi
> davranıyor. Buradaki yazı boyutları 1080p'de doğru görünecek şekilde
> seçildiği için varsayılan ölçek 1. 4K bir ekranda büyütmek isterseniz
> `local.lua` içinde `scale = 1.5` (ya da 2) verin.

Kendi düzeninizi (ikinci ekran, dikey monitör, özel ölçek, farklı klavye
düzeni, NVIDIA seçenekleri) tanımlamak için:

```bash
cp ~/.config/hypr/lua/local.lua.example ~/.config/hypr/lua/local.lua
$EDITOR ~/.config/hypr/lua/local.lua
hyprctl reload
```

`local.lua` git'te izlenmez ve kurulum betiği **üzerine yazmaz** — depoyu
güncellediğinizde ayarlarınız kalır.

---

## ⌨️ Kısayollar

`SUPER` = Windows tuşu. Tam liste: `configs/hypr/lua/binds.lua` — ya da
masaüstündeyken **`SUPER + K`**: tüm kısayollar aranabilir bir listede açılır.

> **Kısayol listesi nasıl üretiliyor?** Ayrı, elle tutulan bir liste yok.
> `binds.lua` içindeki her kısayolun `description` alanı Hyprland'e kayıtlıdır;
> `~/.local/bin/keybinds` (kaynağı: `configs/bin/keybinds`) bunları
> `hyprctl binds -j` ile okuyup rofi'de gösterir. Yeni bir kısayol eklerken
> açıklamasını da yazın, yoksa listede "(açıklama yok)" görünür. Liste salt
> okunurdur: Lua yapılandırmasında kısayollar Hyprland'e yalnızca bir numara
> (`__lua`, `arg: "5"`) olarak göründüğü için seçilen satır çalıştırılamaz.

### Uygulamalar
| Kısayol | İşlev |
| --- | --- |
| `SUPER + RETURN` | Terminal (Alacritty) |
| `SUPER + E` | Dosya yöneticisi (Nemo) |
| `SUPER + B` | Tarayıcı (Brave) |
| `SUPER + SHIFT + C` | Kod editörü (VS Code) |
| `SUPER + I` | Sistem izleyici (btop) |
| `SUPER + R` | Uygulama başlatıcı (rofi) |
| `SUPER + SHIFT + R` | Komut çalıştır |
| `SUPER + TAB` | Açık pencereler |
| `SUPER + PERIOD` | Emoji seçici |
| `SUPER + C` | Pano geçmişi (cliphist) |
| `SUPER + SHIFT + V` | Pano geçmişi (aynı komut, ikinci kısayol) |
| `SUPER + CTRL + C` | Renk seçici — tıklanan pikselin hex kodu panoya (hyprpicker) |
| `SUPER + K` | Kısayol listesi (aranabilir) |

### Terminal (Alacritty içinde)
| Kısayol | İşlev |
| --- | --- |
| `SHIFT + ENTER` | Göndermeden alt satıra geç (Claude Code, zsh; `ALT + ENTER` ile aynı) |
| `F11` | Pencereyi büyüt / geri al |
| `CTRL + SHIFT + U` | Ekrandaki bağlantıları işaretle, seçileni aç |

> Alacritty varsayılan olarak `SHIFT + ENTER`'a düz `ENTER` ile aynı baytı
> gönderir, bu yüzden istem alt satıra geçmek yerine gönderilirdi.
> `configs/alacritty/alacritty.toml` bu tuşa `ALT + ENTER`'ın dizisini
> (`ESC` + `\r`) bağlar.

> **Pano geçmişi nasıl çalışır?**
> Oturum açılışında `wl-paste --watch cliphist store` arka planda başlar
> (bkz. `hypr/lua/autostart.lua`) ve kopyaladığınız her metni/görseli
> `~/.cache/cliphist/db` içine yazar. `SUPER + C` bu geçmişi rofi'de
> açar: yazarak arayın, Enter'a basın — seçtiğiniz kayıt panoya geri konur,
> ardından normal `CTRL + V` ile yapıştırırsınız.
> Terminalden de bakabilirsiniz: `cliphist list` (tümü),
> `cliphist list | head -1` (en son kopyaladığınız),
> `cliphist wipe` (geçmişi temizler).

### Pencere
| Kısayol | İşlev |
| --- | --- |
| `SUPER + Q` | Pencereyi kapat |
| `SUPER + SHIFT + Q` | Zorla sonlandır |
| `SUPER + V` | Yüzen / döşeli |
| `SUPER + F` | Tam ekran |
| `SUPER + SHIFT + F` | Ekranı kapla |
| `SUPER + T` | Ortala |
| `SUPER + SHIFT + P` | Tüm workspace'lerde sabitle |
| `SUPER + G` | Grup (sekmeli pencere) |
| `ALT + TAB` | Pencereler arasında geç |
| `SUPER + ok tuşları` | Odağı taşı |
| `SUPER + SHIFT + ok` | Pencereyi taşı |
| `SUPER + CTRL + ok` | Yeniden boyutlandır |
| `SUPER + ALT + ok` | Diğer monitöre taşı |
| `SUPER + ALT + H/J/K/L` | Odağı taşı (vim yönleri) |
| `SUPER + P` | Pseudotile (dwindle) |
| `SUPER + J` | Bölme yönünü çevir |
| `SUPER + sol tık sürükle` | Pencereyi taşı |
| `SUPER + sağ tık sürükle` | Pencereyi yeniden boyutlandır |

### Oturum ve sistem
| Kısayol | İşlev |
| --- | --- |
| `SUPER + L` | Ekranı kilitle (hyprlock) |
| `SUPER + ESCAPE` | Oturum menüsü (wlogout) |
| `SUPER + M` | Hyprland'den çık (`SUPER + SHIFT + M` de aynı işi yapar) |
| `SUPER + N` | Bildirimleri temizle |
| `SUPER + SHIFT + N` | Son bildirimi geri getir |
| `SUPER + U` | Waybar'ı yeniden başlat |
| `SUPER + 1..0` | Workspace değiştir |
| `SUPER + SHIFT + 1..0` | Pencereyi workspace'e taşı |
| `SUPER + S` | Scratchpad (özel workspace) |
| `SUPER + SHIFT + S` | Pencereyi scratchpad'e taşı |
| `SUPER + fare tekerleği` | Bir sonraki / önceki workspace |

### Ekran görüntüsü
| Kısayol | İşlev |
| --- | --- |
| `PRINT` | Bölge seç → swappy ile düzenle → kaydet düğmesi `~/Resimler` |
| `SUPER + PRINT` | Bölge seç (PRINT ile aynı) |
| `SHIFT + PRINT` | Tam ekran → panoya + `~/Resimler` |
| `ALT + PRINT` | Aktif pencere → panoya + `~/Resimler` |

Üç kısayol da `~/.local/bin/screenshot` betiğini çağırır (kaynağı:
`configs/bin/screenshot`). Görüntü **hem panoya kopyalanır hem dosyaya
yazılır**, ardından dosya yolunu gösteren bir bildirim çıkar — kaydın nereye
gittiğini aramak gerekmez. Dosya adı her modda aynı biçimdedir:
`YYYY-AA-GG_SS-DD-ss.png`.

**Bölge görüntüsünde kaydetme kararını swappy verir.** Görüntü önce swappy
penceresinde açılır (ok, kutu, metin, bulanıklık çizebilirsiniz); araç
çubuğundaki aşağı oklu düğme dosyayı yazar. O düğmenin nereye yazacağı
`~/.config/swappy/config` içindeki `save_dir` satırıyla belirlenir ve kurulum
betiği orayı gerçek "Resimler" dizininize göre doldurur
(`setup_swappy`). Bu dosya olmadan swappy görüntüyü sessizce `~/Desktop`
altına atar — ayrıntı için aşağıdaki sorun giderme başlığına bakın.

### Ekran kaydı
| Kısayol | İşlev |
| --- | --- |
| `CTRL + PRINT` | Bölge seç → kaydı başlat. Kayıt sürerken basınca **durdurur** |
| `CTRL + SHIFT + PRINT` | Odaklı ekranın tamamını kaydet. Kayıt sürerken basınca **durdurur** |

Kayıt sürerken panelin sağında kırmızı **󰑊 REC** göstergesi yanar; ona
tıklamak da kaydı durdurur. Durunca dosya yolunu gösteren bir bildirim çıkar.
Dosyalar `~/Videolar` altına `YYYY-AA-GG_SS-DD-ss.mp4` adıyla yazılır.
Bilgisayardan çıkan ses kaydedilir, mikrofon kaydedilmez.

- **Kayıt başlarken bildirim çıkmaz** — bilerek: bildirim videonun ilk
  saniyelerine girerdi. Geri bildirim paneldeki göstergedir.
- **İşlemciyi yormaz.** Betik (`~/.local/bin/screenrecord`, kaynağı
  `configs/bin/screenrecord`) önce GPU'nun donanım kodlayıcısını (VAAPI) dener;
  çalışmazsa yazılım kodlayıcıya (`libx264`) geçer, ses aygıtı açılamazsa
  sessiz kaydeder. Hangisinin kullanıldığı `$XDG_RUNTIME_DIR/screenrecord.log`
  dosyasında görünür.
- **GPU numarayla seçilmez.** `/dev/dri/renderD128` her makinede aynı kart
  değildir: AMD + NVIDIA bir dizüstünde renderD128 NVIDIA'ya aittir ve orada
  VAAPI kodlaması yoktur. Betik kartı sürücü adına bakarak bulur.
- Panelin `privacy` modülü bu kaydı **göremez**: wf-recorder ekranı
  PipeWire'dan değil doğrudan Wayland'den alır. Ayrı gösterge bu yüzden var.

### Dizüstü / medya tuşları
Hepsi **ekran kilitliyken de çalışır**; ses ve parlaklık tuşları basılı
tutunca tekrar eder.

| Tuş | İşlev |
| --- | --- |
| `Ses aç / kıs / sustur` | `wpctl` ile ana çıkış (açarken %100'ü aşmaz) |
| `Mikrofonu sustur` | `wpctl` ile varsayılan giriş |
| `Parlaklık +/−` | `brightnessctl` (%5 adım, algısal eğri; en düşükte ekran tamamen kararmaz) |
| `Oynat / duraklat / ileri / geri` | `playerctl` |

### Düşük pil bildirimi
Panelin pil modülü azalınca yalnızca rengini değiştirir; tam ekran video ya da
sunum sırasında görünmez. Bu yüzden pil **%15'e** inince bir bildirim,
**%5'e** inince kırmızı ve tıklanana kadar kalan **kritik** bildirim çıkar.
Her eşikte yalnızca bir kez uyarılır; şarj cihazı takılınca sayaç sıfırlanır.

Arka planda sürekli çalışan bir süreç yoktur: systemd kullanıcı zamanlayıcısı
(`battery-notify.timer`) `~/.local/bin/battery-notify` betiğini dakikada bir
çalıştırır, betik bir saniyeden kısa sürede çıkar. Kurulum betiği zamanlayıcıyı
**yalnızca pili olan makinede** etkinleştirir; masaüstünde birim dosyaları
kopyalanır ama çalışmaz. Fare/klavye pilleri sayılmaz.

```bash
systemctl --user list-timers battery-notify.timer   # çalışıyor mu?
journalctl --user -u battery-notify.service         # günlük
```

---

## 📦 Kurulan bileşenler

### Masaüstü
Hyprland · Waybar · Rofi · Mako · wlogout · Hyprlock · Hypridle · Hyprpaper ·
Alacritty · Nemo

### Sistem
PipeWire (+ WirePlumber, pavucontrol) · NetworkManager · BlueZ + Blueman ·
XDG portalları (hyprland + gtk) · hyprpolkitagent · brightnessctl · playerctl ·
cliphist + wl-clipboard · grim/slurp/swappy · wf-recorder (ekran kaydı) ·
hyprpicker (renk seçici) · libnotify · upower +
power-profiles-daemon ·
gvfs (çöp kutusu, USB/telefon) · nwg-look (GTK tema aracı) · btop · htop ·
fastfetch · tree · xsensors (isteğe bağlı)

### Geliştirme
Git + base-devel · Python (pip, virtualenv) · Docker · VS Code ·
Zsh + Oh My Zsh (autosuggestions, syntax-highlighting)

### Uygulamalar
Brave · LibreOffice (Türkçe) · Flatpak + MarkText

### Yazı tipleri
JetBrainsMono Nerd Font · Nerd Fonts Symbols · Font Awesome ·
Noto Fonts (+ emoji) · MS Fonts

> **Not:** `neofetch` Arch depolarından kaldırıldığı için yerine `fastfetch`
> kuruluyor.

---

## 📊 Panel düzeni (waybar)

```
┌─────────────────────────────┬──────────────┬──────────────────────────────────┐
│ açık uygulamalar + başlık   │ workspace'ler│ durum modülleri … pil, saat      │
│ SOL                         │ ORTA         │ SAĞ                              │
└─────────────────────────────┴──────────────┴──────────────────────────────────┘
```

| Bölge | İçerik |
| --- | --- |
| Sol | `wlr/taskbar` — açık her pencere bir simge (tıkla: geç, orta tık: kapat), yanında odaklı pencerenin başlığı |
| Orta | Workspace numaraları — **tıklanabilir**. Sabit liste yok: yalnızca **dolu** olanlar çizilir, üç workspace kullanıyorsanız `1 2 3` görünür |
| Sağ | **󰑊 REC (yalnızca ekran kaydı sürerken)** · gizlilik · **kahve (uyku engelle)** · ses · **mikrofon** · bluetooth · ağ · parlaklık · CPU · RAM · sıcaklık · pil · **saat (en sağda)** |

Mikrofon modülü yalnızca durum gösterir (yüzde yok): açıkken 󰍬, kapalıyken
kırmızı 󰍭. Tıklayınca açılıp kapanır, sağ tık `pavucontrol`'ün giriş sekmesini
açar.

**Sistem tepsisi panelde yok.** Bu masaüstünde tepsiyi kullanan bir uygulama
yok; tek istisna geçerli bir simge yayımlamadığı için waybar'ın "eksik görsel"
yer tutucusunu (üstü çizili daire) çizdiriyordu. Tepsiyi geri istiyorsanız
`waybar/config` içindeki `"modules-right"` listesine `"tray"` satırını
ekleyin — modülün tanımı dosyada duruyor.

### Workspace göstergesi neden `custom/wsN` modülleri?

Waybar'ın yerleşik `hyprland/workspaces` modülü bir numaraya tıklandığında
Hyprland soketine **eski biçim** bir komut yazar: `dispatch workspace 2`.
Hyprland 0.56'dan itibaren yapılandırma Lua biçimindeyse (bu depoda öyle)
soketten gelen dispatch metni bir **Lua ifadesi** olarak yorumlanır ve
`workspace 2` geçerli Lua olmadığı için tıklama sessizce hiçbir şey yapmaz.
Kendiniz görebilirsiniz:

```bash
hyprctl dispatch workspace 1
# error: [string "return hl.dispatch(workspace 1)"]:1: ')' expected

hyprctl dispatch 'hl.dsp.focus({ workspace = 1 })'
# ok
```

Modülün komutu dışarıdan değiştirmeye izin veren bir `on-click` seçeneği
olmadığı için gösterge, workspace başına bir `custom/wsN` modülüne bölündü.
Durumu da tıklamayı da `~/.local/bin/waybar-workspace` (kaynağı:
`configs/bin/waybar-workspace`) karşılar; betik yeni Lua biçimini kullanır,
bulamazsa eski biçime geri düşer.

Göstergeler **saniyede bir yoklanmaz**: Hyprland tarafındaki
`hypr/lua/waybar.lua`, workspace ve pencere olaylarında waybar'a `SIGRTMIN+9`
gönderir, modüller yalnızca o an tazelenir. Sinyal numarasını değiştirirseniz
iki dosyada da değiştirin.

---

## ☕ Kahve düğmesi ve boşta kalma davranışı

Panelde 󰾪 simgesine tıklayınca kahve **açılır** (dolu sarı ada, 󰅶) ve makine
boşta kalmayı tamamen bırakır. Tekrar tıklayınca kapanır (soluk gri).

| Kahve | Ne olur |
| --- | --- |
| 󰅶 **açık** | Ekran kararmaz, kilitlenmez, kapanmaz, uykuya girmez. Süresiz. |
| 󰾪 **kapalı** | 4.5 dk → ekran kararır (uyarı) · **5 dk → kilitlenir ve ekran kapanır** · 15 dk → uykuya girer (**yalnızca pilde**; prizde asla) |

Tam ekran video oynatan pencereler sayacı zaten kendiliğinden durdurur
(`hypr/lua/rules.lua` → `inhibit-idle-on-fullscreen`), kahveye dokunmanız
gerekmez.

**Kahve neden waybar'ın yerleşik modülü değil?** Waybar'ın `idle_inhibitor`
modülü durumu yalnızca bellekte tutar: waybar her yeniden başladığında (config
değişikliği, oturum açılışı, `killall waybar`) sessizce kapalıya döner —
kullanıcı düğmeyi açık sanırken ekran 5 dakikada kararır. Bu depoda durumu
`~/.local/bin/caffeine` betiği (kaynağı: `configs/bin/caffeine`)
`$XDG_RUNTIME_DIR/caffeine` dosyasında tutar, bu yüzden waybar'dan bağımsız
yaşar. İki bağımsız katman koruma sağlar:

1. `hypridle.conf` içindeki her listener `condition_cmd` ile o dosyaya bakar;
2. betik ayrıca bir systemd `idle:sleep` kilidi alır (`systemd-inhibit --list`
   ile görebilirsiniz), bu da `systemctl suspend` çağrısını bloklar.

Durum oturuma özeldir: `$XDG_RUNTIME_DIR` çıkışta temizlendiği için kahve her
açılışta **kapalı** başlar. Terminalden de kullanılabilir:

```bash
caffeine on        # aç
caffeine off       # kapat
caffeine toggle    # aç/kapat
caffeine active    # açıksa çıkış kodu 0
```

---

## 🎞️ Animasyonlar

Pencere açılış/kapanış, workspace geçişi ve katman animasyonları **kapalıdır**
(`configs/hypr/lua/look.lua` → `animations.enabled = false`). Her şey anında
olur; girdi gecikmesi hissi yoktur ve zayıf GPU'larda kare atlaması olmaz.

Geri açmak için tek satır yeterli — eğri ve animasyon tanımları dosyada
olduğu gibi duruyor, yeniden yazmanız gerekmez:

```lua
animations = {
    enabled = true,
},
```

---

## 📁 Kurulum sonrası dosya yapısı

```
~/.config/
├── hypr/
│   ├── hyprland.lua          # ana giriş — yalnızca modülleri yükler
│   ├── lua/
│   │   ├── theme.lua         # Catppuccin Mocha paleti (renklerin tek kaynağı)
│   │   ├── env.lua           # ortam değişkenleri
│   │   ├── monitors.lua      # ekran düzeni (otomatik algılama)
│   │   ├── look.lua          # boşluk, kenarlık, animasyon (animasyon KAPALI)
│   │   ├── input.lua         # klavye, fare, touchpad
│   │   ├── binds.lua         # kısayollar
│   │   ├── rules.lua         # pencere ve katman kuralları
│   │   ├── autostart.lua     # açılışta başlayan süreçler
│   │   ├── waybar.lua        # panel göstergelerini olay bazlı tazeler (SIGRTMIN+9)
│   │   ├── cursor.lua        # kurulum betiği üretir (imleç teması)
│   │   ├── local.lua         # SİZİN makineye özel ayarlarınız (git'te yok)
│   │   └── local.lua.example # başlangıç şablonu
│   ├── hyprlock.conf         # kilit ekranı
│   ├── hypridle.conf         # boşta kalma → karart / kilitle / uyut (kahveye bakar)
│   ├── hyprpaper.conf        # duvar kağıdı
│   └── wallpaper/
├── waybar/                   # panel
├── swappy/                   # bölge görüntüsü düzenleyici (kayıt dizini)
├── rofi/                     # uygulama başlatıcı
├── mako/                     # bildirimler
├── wlogout/                  # oturum menüsü (+ icons-svg/)
├── alacritty/                # terminal (Blood Moon) + tema koleksiyonu
├── wofi/                     # yedek başlatıcı
├── systemd/user/             # battery-notify.timer + .service (düşük pil)
├── gtk-3.0/  gtk-4.0/        # kurulum betiği üretir
├── qt5ct/    qt6ct/          # kurulum betiği üretir
└── arch-dotfile-backup/      # üzerine yazılan dosyaların yedekleri

# Nemo ayarları dosya değil dconf anahtarıdır; kurulum sırasında
# `dconf load /org/nemo/ < configs/nemo/nemo-dconf.conf` ile uygulanır.

~/
├── .local/bin/
│   ├── caffeine              # kahve (uyku engelleme) anahtarı — panel bunu çağırır
│   ├── waybar-workspace      # panelin tıklanabilir workspace göstergesi
│   ├── screenshot            # PRINT kısayollarının çağırdığı görüntü betiği
│   ├── screenrecord          # CTRL+PRINT ekran kaydı + panel REC göstergesi
│   ├── keybinds              # SUPER+K kısayol listesi
│   └── battery-notify        # düşük pil bildirimi (systemd zamanlayıcısı çağırır)
├── .icons/     .themes/      # simge ve GTK temaları
├── .zshrc      .oh-my-zsh/
└── .cache/arch-dotfile-install-<tarih>.log
```

---

## ❓ Sorun giderme

**Panelde simgeler kutu görünüyor**
JetBrainsMono Nerd Font kurulu değil: `sudo pacman -S ttf-jetbrains-mono-nerd`

**Bildirimler görünmüyor**
`mako` çalışıyor mu: `pgrep mako`. Test: `notify-send "deneme" "merhaba"`

**Ekran paylaşımı çalışmıyor**
`systemctl --user restart xdg-desktop-portal xdg-desktop-portal-hyprland`

**Ekran düzeni yanlış**
`hyprctl monitors all` ile adları öğrenip `~/.config/hypr/lua/local.lua`
içine yazın, sonra `hyprctl reload`.

**Yapılandırma yüklenmiyor / eski ayarlar geçerli**
Hyprland önce `hyprland.lua` arar, bulamazsa eski `hyprland.conf`'a düşer.
Eski dosya duruyorsa silin:
`rm ~/.config/hypr/hyprland.conf` — hangisinin kullanıldığını görmek için:
`grep "\[cfg\]" /run/user/$UID/hypr/*/hyprland.log`

**Kahve açık ama ekran yine de kararıyor**
Önce durumu doğrulayın: `caffeine status` ve `systemd-inhibit --list | grep
caffeine`. İkisi de açık görünüyorsa hypridle eski yapılandırmayla çalışıyor
olabilir: `killall hypridle && hypridle &`. Panelde düğme hiç görünmüyorsa
betik kurulmamıştır: `ls -l ~/.local/bin/caffeine`.

**Ekran kilitleniyor ama kapanmıyor / wlogout'ta "Oturumu Kapat" çalışmıyor**
Düzeltildi. İkisi de eski biçim `hyprctl dispatch dpms off` ve
`hyprctl dispatch exit` kullanıyordu. Yapılandırma Lua olduğunda Hyprland
dispatch metnini Lua ifadesi olarak çalıştırır ve eski biçim hata verir:
`[string "return hl.dispatch(dpms on)"]:1: ')' expected near 'on'`.
`hypridle.conf` artık `hl.dsp.dpms({action = "off"})`, wlogout ise
`hl.dsp.exit()` kullanıyor. Eski dosya hâlâ duruyorsa kurulumu yeniden
çalıştırıp hypridle'ı yeniden başlatın: `killall hypridle && hypridle &`.

**Panelde en soldaki kutunun arka planı kayboluyor**
Düzeltildi. Sebebi `style.css` içinde `window#waybar.empty #taskbar` kuralıydı:
`.empty` sınıfını `hyprland/window` modülü panelin tamamına ekler ve yalnızca
"odaklı pencerenin BAŞLIĞI boş" demektir — "hiç pencere yok" demek değil.
Başlıksız bir pencere odaklanınca görev çubuğu simgeleri yerinde kalıyor ama
arka plan adası kayboluyordu. O kuralı geri eklemeyin.

**swappy'de kaydet düğmesine bastım ama dosya hiçbir yerde yok**
`~/.config/swappy/config` eksik ya da `save_dir` satırı yanlış demektir.
swappy, ayar bulamazsa sırayla `$XDG_DESKTOP_DIR` → `$XDG_CONFIG_HOME/Desktop`
→ `$HOME/Desktop` dener. Tuzak şu: **`XDG_DESKTOP_DIR` bir ortam değişkeni
değildir** — masaüstünün yeri `~/.config/user-dirs.dirs` içinde durur ve oradan
yalnızca `xdg-user-dir DESKTOP` okur, kabuğa export edilmez. Bu yüzden her
zaman son basamak kazanır ve görüntü, masaüstüyle hiçbir ilgisi olmayan
`~/Desktop` dizinine sessizce düşer. Türkçe oturumda gerçek masaüstü "Masaüstü"
olduğu için dosya hiçbir yerde görünmez; hata da verilmez, çünkü swappy o
dizini kendisi oluşturur.

```bash
ls ~/Desktop                 # eski kayıtlarınız buradaysa taşıyın:
mv ~/Desktop/swappy-*.png "$(xdg-user-dir PICTURES)"/ && rmdir ~/Desktop
grep save_dir ~/.config/swappy/config   # doğru dizini gösteriyor mu?
```

Düzeltmek için `./arch_dotfile_installer.sh` betiğini yeniden çalıştırmanız
yeter (`setup_swappy` adımı satırı sizin "Resimler" dizininize göre yazar).

**Panelde workspace numaralarına tıklayınca hiçbir şey olmuyor**
Gösterge `~/.local/bin/waybar-workspace` betiğine dayanır; kurulu mu bakın:
`ls -l ~/.local/bin/waybar-workspace`. Numaralar hiç görünmüyorsa `jq` eksik
olabilir (`sudo pacman -S jq`) — betik o durumda sessizce boş çıktı verir.
Nedeni yukarıdaki "Workspace göstergesi neden `custom/wsN` modülleri?"
başlığında.

**Panelde kırmızı REC yazıyor ama kayıt yok**
Kaydedici beklenmedik şekilde kapanmışsa (disk doldu, `kill -9`) gösterge bir
sonraki tazelemeye kadar ekranda kalabilir. Göstergeye tıklayın: durum
dosyaları temizlenir ve gösterge söner. Aynısını terminalden de yapabilirsiniz:
`screenrecord stop`. Kaydın neden bittiğini görmek için:
`cat $XDG_RUNTIME_DIR/screenrecord.log`

**Ekran kaydı başlamıyor / dosya boş çıkıyor**
Betik kodlayıcıları sırayla dener; hepsi başarısız olursa bildirim çıkar.
Günlüğe bakın (`$XDG_RUNTIME_DIR/screenrecord.log`). Donanım kodlayıcı
kullanılamıyorsa yazılım kodlayıcıya düşer, bu normaldir.

**Panelde sıcaklık yanlış ya da sürekli kırmızı**
Kurulum betiği sensörü `hwmon-path-abs` + `input-filename` çiftiyle yazar;
düz `hwmon-path` kullanılmaz çünkü `hwmonN` numarası her açılışta değişip
başka bir çipin (NVMe SSD, GPU) sıcaklığını CPU diye gösterebilir. Sensörü
yeniden algılatmak için: `./arch_dotfile_installer.sh --check` ile durumu
görün, sonra kurulumu tekrar çalıştırın. Uyarı/kritik eşikleri bilerek 85/95
°C'dir: modern bir CPU'nun Tjmax değeri 100-105 °C'dir ve tek çekirdeğin
anlık turbosu 80'i rahatça geçer.

**Bir şeyi bozdum, geri almak istiyorum**
Kurulum her dosyayı yedekliyor:
`ls ~/.config/arch-dotfile-backup/`

**Genel durum kontrolü**
`./arch_dotfile_installer.sh --check`

---

# 📖 Manuel Kurulum Rehberi

> ⚠️ **Bu bölüm arşiv niteliğindedir ve kurulum betiğini YANSITMAZ.**
>
> Aşağıdaki notlar, bu masaüstünün nasıl elle kurulabileceğini anlatan eski
> kişisel bir rehberdir. Sublime Text, Zen kernel, Timeshift, pywal gibi
> burada geçen bazı adımların `arch_dotfile_installer.sh` içinde karşılığı
> **yoktur**; bazıları da (ör. `wofi` yerine `rofi`, `hyprland.conf` yerine
> `hyprland.lua`) artık güncel değildir.
>
> Kurulumda gerçekten ne yapıldığını görmek için tek doğru kaynak:
> `./arch_dotfile_installer.sh --dry-run`



> **Not**: Manuel kurulum yapmak zorunda değilsiniz! Yukarıdaki otomatik scriptler çoğu kullanıcı için yeterlidir.

## 1. Sistemi Güncelle

Öncelikle, sisteminizi güncelleyerek en son paketleri almanız önemlidir.

```bash
sudo pacman -Syu
```

---

## 2. Timeshift Kurulumu

Sistem yedeği almak için Timeshift uygulamasını kurun.

```bash
sudo pacman -S timeshift
```

---

## 3. Yay (AUR Yardımcısı) Kurulumu

AUR'dan (Arch User Repository) paketleri yüklemek için yay (yay) aracını kurmanız gerekir.

Gerekli araçları yükleyin:

```bash
sudo pacman -S git base-devel
```

Yay’ı klonlayın ve kurun:

```bash
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
cd ..
rm -rf yay/
```

---

## 4. Tarayıcı Kurulumu

```bash
# Brave yada chrome
sudo pacman -S brave 

yay -S google-chrome
```

---

## 5. Sublime Text Kurulumu

Sublime Text, popüler bir metin editörüdür. Kurulum için aşağıdaki kurulum yollarından birini çalıştırın:

### Pacman

```bash
curl -O https://download.sublimetext.com/sublimehq-pub.gpg && sudo pacman-key --add sublimehq-pub.gpg && sudo pacman-key --lsign-key 8A8F901A && rm sublimehq-pub.gpg

echo -e "\n[sublime-text]\nServer = https://download.sublimetext.com/arch/stable/x86_64" | sudo tee -a /etc/pacman.conf

sudo pacman -Syu sublime-text
```

### Aur

```bash
yay -S sublime-text-4
```

---

### 5.1 Key Bindings (Klavye Kısayolları)

1. Sublime Text’te **Preferences → Key Bindings** menüsünü açın.
2. Sağ taraftaki kullanıcı dosyasına aşağıdaki JSON’u ekleyin (veya var olan benzer satırları güncelleyin):

```json
[
    { "keys": ["ctrl+down"],  "command": "move", "args": { "by": "lines", "forward": true,  "extend": true } },
    { "keys": ["ctrl+up"],    "command": "move", "args": { "by": "lines", "forward": false, "extend": true } },
    { "keys": ["ctrl+shift+b"], "command": "exec", "args": { "kill": true } }
]
```

Kaydedip kapattıktan sonra

- **Ctrl + ↓ / Ctrl + ↑** ile satır satır seçim yapabilirsiniz.
- **Ctrl + Shift + B** ile çalışan **build** işlemini sonlandırabilirsiniz.

---

### 5.2 Tema & Renk Şeması

1. **Package Control** kurulu değilse `Tools → Install Package Control` ile yükleyin.
2. **Ctrl + Shift + P** → `Package Control: Install Package` komutunu açın ve **Brogrammer** yazıp **Enter**’a basın.

**Tema seçimi**

- **Preferences → Color Scheme…** menüsünden **Brogrammer**’ı,
- **Preferences → Select Theme…** menüsünden **Adaptive**’i seçin.

Arayüzünüz artık koyu‑renkli, renkli ikonlu ve modern bir görünüme kavuşur.

---

### 5.3 Eklentiler

> **Nasıl kurulur?**  
> `Ctrl + Shift + P` → `Package Control: Install Package` → eklenti adını yazıp **Enter**.

| Eklenti Adı | Ne İşe Yarar? |
| --- | --- |
| **Markdown Preview** | `Ctrl + B` ile aynı dizinde `.html` oluşturur; **Preview in Browser** komutuyla canlı ön‑izleme sunar. |
| **SideBarEnhancements** | Dosya & klasör sağ‑tık menüsüne ek eylemler kazandırır. |
| **BracketHighlighter** | Parantez, köşeli ve süslü parantez eşlerini vurgular. |
| **A File Icon** | Dosya türlerine göre renkli ikonlar gösterir. |
| **AutoFileName** | Dosya yolu/adı tamamlama sağlar. |

---

## 6. Zen Kernel Kurulumu

Çekirdekte bir sorun yaşanması durumunda alternatif bir çekirdeğe sahip olmak faydalı olabilir. Bu nedenle, Zen çekirdeğini mevcut çekirdeğin yanına kurabilirsiniz. Çekirdek seçimi, sistem başlatılırken GRUB ekranı üzerinden yapılabilir.

```bash
sudo pacman -S linux-zen linux-zen-headers
```

grub kullanıyorsanız grub dosyasını güncelle.

```bash
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

---

## 7. Hyprland Kurulumu (Wayland)

Hyprland'i ve gerekli bazı paketleri yükleyin.

```bash
sudo pacman -S hyprland hyprpaper grim slurp swappy libnotify hyprpolkitagent xdg-desktop-portal-hyprland
```

Ekran paylaşımı için gerekli paketleri yükleyin:

```bash
sudo pacman -S pipewire wireplumber
yay -S xdg-desktop-portal-hyprland-git
```

### Ses Sorunu Çözümü - Arch Linux

1. **Ses Sistemlerini Kontrol Etme:**
  Aşağıdaki komutu çalıştırarak sisteminizde hangi ses sistemlerinin aktif olduğunu kontrol edin:
  
  ```bash
  ps -e | grep -E 'pulse|pipe'
  
    31196 ?        00:00:00 pipewire
    31335 ?        00:00:00 pulseaudio
  
  Eğer burdaki gibi PulseAudio ve PipeWire aynı anda çalışıyorsa, çakışmaya sebep olabilir.
  ```
  
2. Eğer çakışan iki sistem varsa, bunlardan birini kaldırın.
  

        **Örneğin**, PulseAudio'yu kaldırmak için(PulseAudio GNOME masaüstü ortamında         gereklidir):

```bash
sudo pacman -Rns pulseaudio
```

3. Kaldırdığınız PulseAudio yerine PipeWire’ı yükleyin:

```bash
sudo pacman -S pipewire pipewire-audio pipewire-pulse wireplumber
```

4. PipeWire servislerini yeniden başlatın:

```bash
systemctl --user daemon-reexec
systemctl --user restart pipewire pipewire-pulse wireplumber
```

Bu Mikrafon sorununu çözmez ise internete araştırma yapman gerekecek.

Hyprland'ı varsayılan yapmak için portals.conf dosyasını oluşturuyoruz:

```bash
mkdir -p ~/.config/xdg-desktop-portal
echo -e "[preferred]\ndefault=xdg-desktop-portal-hyprland" > ~/.config/xdg-desktop-portal/portals.conf
systemctl --user restart xdg-desktop-portal
```

Hyprland NVIDIA ayarı:

GRUB ayarlarını düzenlemek için aşağıdaki komutu kullanın:

```bash
sudo nano /etc/default/grub
```

GRUB_CMDLINE_LINUX_DEFAULT kısmında, eğer aşağıdaki satır varsa:

```json
GRUB_CMDLINE_LINUX_DEFAULT='nowatchdog nvme_load=YES nvidia_drm.modeset=1 loglevel=3'
```

Bunu sonuna boşluk bırakarak ekleyin:

```json
GRUB_CMDLINE_LINUX_DEFAULT='nowatchdog nvme_load=YES nvidia_drm.modeset=1 loglevel=3 nvidia.NVreg_PreserveVideoMemoryAllocations=1'
```

Eğer herhangi bir şey yoksa, `GRUB_CMDLINE_LINUX_DEFAULT=nvidia.NVreg_PreserveVideoMemoryAllocations=1` satırını ekleyin, ardından değişiklikleri kaydedip çıkın.

Son olarak, aşağıdaki komutu çalıştır:

```bash
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

thema ve icon için

```bash
cat > ~/.config/xdg-desktop-portal/hyprland-portals.conf <<'EOF'
[preferred]
default=hyprland;gtk
EOF
```

Dosyaları aktarmak için:

```bash
cp -r configs/hypr "$HOME/.config/"
```

Timeshift gibi uygulamaların düzgün çalışması için DBus çevre değişkenlerini güncelliyoruz (ilk çalıştırma yeterli):

```bash
dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE &
```

Her açılışta root'a yetki verilmesi için ~/.profile dosyasına ekliyoruz:

```bash
sudo pacman -S xorg-xhost
echo "xhost +SI:localuser:root" >> ~/.profile
```

### Gereksiz XDG portal paketlerini temizlemek için:

```bash
pacman -Q | grep xdg-desktop-portal-
sudo pacman -Rns xdg-desktop-portal-wlr
```

Fazladan masaüstü portal paketlerini temizlemek isterseniz aşağıdaki adımları izleyebilirsiniz.

```bash
pacman -Q | grep xdg-desktop-portal-
```

Çıktısı:

```bash
xdg-desktop-portal-gnome 48.0-2
xdg-desktop-portal-gtk 1.15.3-1
xdg-desktop-portal-hyprland-git 1.3.9.r4.g150b0b6-1
```

Burada, ikinci masaüstü ortamınıza ait portal paketlerine, uyumsuzluk yaşanmaması için dokunmamalısınız. xdg-desktop-portal-hyprland-git Hyprland için gereklidir, ayrıca xdg-desktop-portal-gtk bazı uygulamalar için faydalı olabilir. Bunların dışındaki portal paketleri gereksizse kaldırabilirsiniz.

Gereksiz bir portal paketini kaldırmak için

```bash
sudo pacman -Rns xdg-desktop-portal-wlr
```

Bu kadar! Bu adımlarla Hyprland'ı varsayılan yapmış ve xhost yetkisini kalıcı hale getirmiş olduk. Sistemini yeniden başlattığında her şey çalışıyor olmalı.

---

## 8. Waybar Kurulumu

Waybar, Wayland tabanlı bir durum çubuğudur. Gerekli paketleri kurmak için.

```bash
sudo pacman -S waybar otf-font-awesome ttf-arimo-nerd noto-fonts xsensors pulseaudio blueman networkmanager btop
```

Giriş/çıkış ekranı için wlogout'u kurun:

```bash
yay -S wlogout
```

Dosyaları aktarmak için:

```bash
cp -r configs/wlogout "$HOME/.config/"
```

Bir uygulama başlatıcı ekleyin:

```bash
sudo pacman -S wofi
```

Dosyaları aktarmak için:

```bash
cp -r configs/wofi "$HOME/.config/"
```

# veya

```bash
sudo pacman -S rofi rofi-emoji
```

Dosyaları aktarmak için:

```bash
cp -r configs/rofi "$HOME/.config/"
```

Bildirimler için mako:

```bash
sudo pacman -S mako
cp -r configs/mako "$HOME/.config/"
```

---

## 9. Nemo Dosya Yöneticisi Kurulumu

Nemo dosya yöneticisini yüklemek için:

```bash
sudo pacman -S nemo cinnamon-translations file-roller nemo-fileroller
```

Nemo confilerini aktarmak için:

```bash
cp -r /configs/nemo/nemo $HOME/.config/
dconf load /org/nemo/ < /configs/nemo/nemo-dconf.conf
```

---

## 10. Alacritty Terminal Kurulumu

Alacritty, hızlı bir terminal emülatörüdür.

```bash
sudo pacman -S alacritty
```

Dosyaları aktarmak için:

```bash
cp -r configs/alacritty "$HOME/.config/"
```

---

## 11. Zsh Kurulumu ve Yapılandırması

Zsh terminali, zengin özelliklere sahip bir kabuktur.

```bash
sudo pacman -S zsh
```

```bash
chsh -s $(which zsh)
```

Sistemi yeniden başlatın ve değişikliği kontrol etmek için.

```bash
sudo reboot
```

```bash
echo $SHELL #bash yerine zsh çıktısı olamsı lazım bin/zsh gibi
```

Dosyaları aktarmak için:

```bash
cp -r configs/.zshrc "$HOME/"
```

### Gerekli araçlar

```bash
sudo pacman -S curl git wget
```

### Oh My Zsh ve eklenti kurulumu

```bash
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone https://github.com/zsh-users/zsh-autosuggestions.git $ZSH_CUSTOM/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting
```

---

## 12. Python Kurulumu

Python ve pip'yi yükleyin:

```bash
sudo pacman -S python-pip python python-virtualenv

# pip hata çözümü
python3 -m pip config set global.break-system-packages true
```

---

## 13. PYENV:

```bash
pacman -S pyenv
yay -S pyenv-virtualenvwrapper
pyenv virtualenvwrapper
```

```bash
eval "$(pyenv init -)"
export WORKON_HOME=$HOME/.virtualenvs
source /usr/local/bin/virtualenvwrapper.sh
export PYENV_VIRTUALENVWRAPPER_PREFER_PYVENV="true"
source $HOME/.zshrc
```

---

## 14. Swap Alanı Oluşturma

8 GB'lık bir swap alanı oluşturmak için:

```bash
swapon --show
sudo swapoff -v /swapfile
sudo su
dd if=/dev/zero of=/swapfile bs=1024 count=8388608
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo "/swapfile     swap     swap    defaults    0 0" >> /etc/fstab
```

---

## 15. FlatPak:

```bash
sudo pacman -S flatpak
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
```

### Tema ve İcon kullanma:

```bash
# 1) Flatpak uygulamalarına tema‑ikon klasörlerini tanıt
sudo flatpak override --filesystem=$HOME/.themes
sudo flatpak override --filesystem=$HOME/.icons
# 2) Tüm Flatpak uygulamalarına hangi tema / ikon setini kullanacağını söyle
sudo flatpak override --env=GTK_THEME=Andromeda-gtk
sudo flatpak override --env=ICON_THEME=dracula-icons-main
```

### Bazı FlatPak uygulamalar:

#### Google

```bash
flatpak install flathub com.google.Chrome
```

#### Bottles(for exe):

```bash
flatpak install flathub com.usebottles.bottles
```

#### Pinta

```bash
flatpak install flathub com.github.PintaProject.Pinta
```

#### Mark Text

```bash
flatpak install flathub com.github.PintaProject.Pinta
```

### Kurulu FlatPak uygulamalarını listelemek ve çaşıştırmak için

kurulu flatpak uygulamalarını listele:

```bash
flatpak list
```

```json
➜  Arch_Dotfile git:(main) ✗ flatpak list
Ad                                Uygulama Kimliği                        Sürüm  Dal          Kurulum
Şişeler                           com.usebottles.bottles                  51.21  stable       system
Mesa                              org.freedesktop.Platform.GL.default     25.0.3 24.08        system
Mesa (Extra)                      org.freedesktop.Platform.GL.default     25.0.3 24.08extra   system
Mesa                              org.freedesktop.Platform.GL32.default   25.0.3 24.08        system
FFmpeg extension with extra code… org.freedesktop.Platform.ffmpeg-full           24.08        system
i386                              ….freedesktop.Platform.ffmpeg_full.i386        24.08        system
openh264                          org.freedesktop.Platform.openh264       2.5.1  2.5.1        system
GNOME Application Platform versi… org.gnome.Platform                             47           system
i386                              org.gnome.Platform.Compat.i386                 47           system
gecko                             org.winehq.Wine.gecko                          stable-24.08 system
mono                              org.winehq.Wine.mono                           stable-24.08 system
➜  Arch_Dotfile git:(main) ✗
```

Uygulama çalıştır:

```bash
flatpak run com.usebottles.bottles #("uygulama Kimliği")
```

Uygulama güncelle:

```bash
flatpak update # flatpak update com.usebottles.bottles bir uygulama güncelle 
```

---

## 16. Uygulamalar

### LİBREOFFİCE

```bash
sudo pacman -S steam
```

Microsoft office font

```bash
yay -S ttf-ms-fonts
fc-cache -fv
```

---

### STEAM

```bash
sudo pacman -S steam
```

Driver kurma ksımında sisteminizdeki ekran kartına göre bir seçim yapmanız gerekiyor. Benim sistemde nvidia olduğundan dolayı 2.seçeneği seçtim

```bash
:: lib32-vulkan-driver için 9 sağlayıcı mevcut:
:: Depo multilib
   1) lib32-amdvlk  2) lib32-nvidia-utils  3) lib32-vulkan-dzn  4) lib32-vulkan-gfxstream
   5) lib32-vulkan-intel  6) lib32-vulkan-nouveau  7) lib32-vulkan-radeon  8) lib32-vulkan-swrast
   9) lib32-vulkan-virtio

Bir sayı girin (default=1): 2
```

### code

```bash
sudo pacman -S code
```

### VLC

```bash
sudo pacman -S vlc
```

---

## 17. DOCKER

```bash
sudo pacman -S docker 
```

Başlatmak için:

```bash
sudo systemctl start docker          # Docker servisini başlat
#sudo systemctl enable docker         # Docker servisini sistem başlangıcında başlatmak için
```

Sudo kullanmamak için:

```bash
sudo usermod -aG docker $USER
```

---

## 18. Tema ve İkonlar

Görsel özelleştirme için Nwg-look aracını ve ikonları yükleyin:

```bash
sudo pacman -S nwg-look
# Temaları ve ikonları ~/.icons ve ~/.themes dizinlerine yerleştirin
```

Dosyaları aktarmak için:

```bash
cp -r configs/.themes "$HOME/"
cp -r configs/.icons  "$HOME/"
```

Ardından, ***nwg-look*** programını çalıştırarak tema ve ikonları değiştirebilirsiniz.

---
