--[[
  Klavye ve fare kısayolları.

  Düzen mantığı:
    SUPER                → odak / uygulama açma
    SUPER + SHIFT        → pencereyi taşı
    SUPER + CTRL         → pencereyi yeniden boyutlandır
    SUPER + ALT          → pencereyi başka monitöre taşı
    XF86*                → donanım tuşları (ses, parlaklık, medya)

  Tuş adlarını öğrenmek için `wev` kullanabilirsiniz.
--]]

local mod = "SUPER"

-- Varsayılan uygulamalar. Değiştirmek için tek yer burası.
local apps = {
    terminal     = "alacritty",
    file_manager = "nemo",
    browser      = "brave",
    editor       = "code",
    launcher     = "rofi -show drun",
    windows      = "rofi -show window",
    run          = "rofi -show run",
    emoji        = "rofi -show emoji",
    clipboard    = "cliphist list | rofi -dmenu -p 'Pano' | cliphist decode | wl-copy",
    logout       = "wlogout --protocol layer-shell",
    lock         = "hyprlock",
    monitor      = "alacritty -e btop",
}

-- Ekran görüntüsü betiği. Kısayollar komutu doğrudan çalıştırmaz; hepsi
-- ~/.local/bin/screenshot üzerinden geçer (bkz. configs/bin/screenshot):
-- hedef dizin, pano kopyası ve "kaydedildi" bildirimi orada tek yerde durur.
-- Tam yol veriliyor: Hyprland'in PATH'i her oturum yöneticisinde
-- ~/.local/bin içermez.
local shot = (os.getenv("HOME") or "~") .. "/.local/bin/screenshot"

-- ---------------------------------------------------------------------------
-- Uygulamalar
-- ---------------------------------------------------------------------------
hl.bind(mod .. " + RETURN",        hl.dsp.exec_cmd(apps.terminal),     { description = "Terminal" })
hl.bind(mod .. " + E",             hl.dsp.exec_cmd(apps.file_manager), { description = "Dosya yöneticisi" })
hl.bind(mod .. " + B",             hl.dsp.exec_cmd(apps.browser),      { description = "Tarayıcı" })
hl.bind(mod .. " + SHIFT + C",     hl.dsp.exec_cmd(apps.editor),       { description = "Kod editörü" })

hl.bind(mod .. " + R",             hl.dsp.exec_cmd(apps.launcher),     { description = "Uygulama başlatıcı" })
hl.bind(mod .. " + TAB",           hl.dsp.exec_cmd(apps.windows),      { description = "Açık pencereler" })
hl.bind(mod .. " + SHIFT + R",     hl.dsp.exec_cmd(apps.run),          { description = "Komut çalıştır" })
hl.bind(mod .. " + PERIOD",        hl.dsp.exec_cmd(apps.emoji),        { description = "Emoji seçici" })
-- Pano geçmişi (cliphist). Ana kısayol SUPER+C; SUPER+SHIFT+V kas hafızası
-- için ikinci bir giriş olarak duruyor, ikisi de aynı komutu çalıştırır.
-- Not: SUPER+C eskiden kod editörünü açıyordu, o SUPER+SHIFT+C'ye taşındı.
hl.bind(mod .. " + C",             hl.dsp.exec_cmd(apps.clipboard),    { description = "Pano geçmişi" })
hl.bind(mod .. " + SHIFT + V",     hl.dsp.exec_cmd(apps.clipboard),    { description = "Pano geçmişi" })

-- ---------------------------------------------------------------------------
-- Oturum
-- ---------------------------------------------------------------------------
hl.bind(mod .. " + L",             hl.dsp.exec_cmd(apps.lock),   { description = "Ekranı kilitle" })
hl.bind(mod .. " + ESCAPE",        hl.dsp.exec_cmd(apps.logout), { description = "Oturum menüsü" })

-- Hyprland'den çıkış. Eski yapılandırmadaki tuş: SUPER+M. Yanlışlıkla basmak
-- oturumu uyarısız kapatır; onaylı çıkış için SUPER+ESCAPE (wlogout) var.
-- SUPER+SHIFT+M de aynı işi yapar — kas hafızası hangisiyse o çalışır.
hl.bind(mod .. " + M",             hl.dsp.exit(), { description = "Hyprland'den çık" })
hl.bind(mod .. " + SHIFT + M",     hl.dsp.exit(), { description = "Hyprland'den çık" })

-- ---------------------------------------------------------------------------
-- Pencere yönetimi
-- ---------------------------------------------------------------------------
hl.bind(mod .. " + Q",             hl.dsp.window.close(),      { description = "Pencereyi kapat" })
hl.bind(mod .. " + SHIFT + Q",     hl.dsp.window.kill(),       { description = "Pencereyi zorla sonlandır" })
hl.bind(mod .. " + V",             hl.dsp.window.float(),      { description = "Yüzen/döşeli" })
hl.bind(mod .. " + P",             hl.dsp.window.pseudo(),     { description = "Pseudotile (dwindle)" })
hl.bind(mod .. " + J",             hl.dsp.layout("togglesplit"), { description = "Bölme yönünü çevir" })
hl.bind(mod .. " + F",             hl.dsp.window.fullscreen({ mode = "fullscreen" }), { description = "Tam ekran" })
hl.bind(mod .. " + SHIFT + F",     hl.dsp.window.fullscreen({ mode = "maximized" }),  { description = "Ekranı kapla" })
hl.bind(mod .. " + T",             hl.dsp.window.center(),     { description = "Pencereyi ortala" })
hl.bind(mod .. " + SHIFT + P",     hl.dsp.window.pin(),        { description = "Tüm workspace'lerde sabitle" })

-- Gruplar (sekmeli pencereler)
hl.bind(mod .. " + G",             hl.dsp.group.toggle(),      { description = "Grup oluştur/dağıt" })
hl.bind("ALT + TAB", function()
    hl.dispatch(hl.dsp.window.cycle_next())
    hl.dispatch(hl.dsp.window.bring_to_top())
end, { description = "Pencereler arasında geç" })

-- ---------------------------------------------------------------------------
-- Odak
-- ---------------------------------------------------------------------------
local directions = {
    { key = "left",  vim = "H", dir = "left" },
    { key = "right", vim = "L", dir = "right" },
    { key = "up",    vim = "K", dir = "up" },
    { key = "down",  vim = "J", dir = "down" },
}

for _, d in ipairs(directions) do
    -- Odak taşı (ok tuşları)
    hl.bind(mod .. " + " .. d.key, hl.dsp.focus({ direction = d.dir }))
    -- Pencereyi taşı
    hl.bind(mod .. " + SHIFT + " .. d.key, hl.dsp.window.move({ direction = d.dir }))
    -- Pencereyi başka monitöre taşı
    hl.bind(mod .. " + ALT + " .. d.key, hl.dsp.window.move({ monitor = d.dir, follow = true }))
end

-- Vim tuşlarıyla odak. SUPER+J zaten "bölme yönünü çevir" olduğu için
-- vim yönleri yalnızca H/L/K ile ve SUPER+CTRL üzerinden verilmedi;
-- çakışmayı önlemek adına odak için ayrı bir kombinasyon kullanılıyor.
hl.bind(mod .. " + ALT + H", hl.dsp.focus({ direction = "left" }))
hl.bind(mod .. " + ALT + L", hl.dsp.focus({ direction = "right" }))
hl.bind(mod .. " + ALT + K", hl.dsp.focus({ direction = "up" }))
hl.bind(mod .. " + ALT + J", hl.dsp.focus({ direction = "down" }))

-- Yeniden boyutlandırma (basılı tutulabilir)
local resize_step = 40
hl.bind(mod .. " + CTRL + left",  hl.dsp.window.resize({ x = -resize_step, y = 0, relative = true }), { repeating = true })
hl.bind(mod .. " + CTRL + right", hl.dsp.window.resize({ x =  resize_step, y = 0, relative = true }), { repeating = true })
hl.bind(mod .. " + CTRL + up",    hl.dsp.window.resize({ x = 0, y = -resize_step, relative = true }), { repeating = true })
hl.bind(mod .. " + CTRL + down",  hl.dsp.window.resize({ x = 0, y =  resize_step, relative = true }), { repeating = true })

-- ---------------------------------------------------------------------------
-- Workspace'ler
-- ---------------------------------------------------------------------------
for i = 1, 10 do
    local key = i % 10  -- 10 → "0" tuşu
    hl.bind(mod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind(mod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i, follow = true }))
end

-- Fare tekerleği ile workspace değiştir
hl.bind(mod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Özel (scratchpad) workspace
hl.bind(mod .. " + S",         hl.dsp.workspace.toggle_special("magic"), { description = "Scratchpad" })
hl.bind(mod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }), { description = "Scratchpad'e taşı" })

-- Fare ile taşı / boyutlandır
hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- ---------------------------------------------------------------------------
-- Ekran görüntüsü
-- ---------------------------------------------------------------------------
-- Bölge seç → swappy ile düzenle (ok/kutu/bulanıklık çizip kaydedebilirsiniz).
-- swappy'deki kaydet düğmesi görüntüyü ~/.config/swappy/config içindeki
-- save_dir dizinine yazar; o dosya olmadan görüntü "$HOME/Desktop" altına
-- düşüyor ve kaybolmuş gibi görünüyordu.
local shot_region = shot .. " region"
-- Tam ekran → hem panoya kopyala hem dosyaya kaydet.
local shot_full   = shot .. " full"
-- Aktif pencere → hem panoya kopyala hem dosyaya kaydet.
local shot_window = shot .. " window"

hl.bind("PRINT",               hl.dsp.exec_cmd(shot_region), { description = "Ekran görüntüsü: bölge" })
hl.bind(mod .. " + PRINT",     hl.dsp.exec_cmd(shot_region), { description = "Ekran görüntüsü: bölge" })
hl.bind("SHIFT + PRINT",       hl.dsp.exec_cmd(shot_full),   { description = "Ekran görüntüsü: tam ekran" })
hl.bind("ALT + PRINT",         hl.dsp.exec_cmd(shot_window), { description = "Ekran görüntüsü: aktif pencere" })

-- ---------------------------------------------------------------------------
-- Donanım tuşları
-- ---------------------------------------------------------------------------
-- `locked = true`  → kilit ekranındayken de çalışır
-- `repeating = true` → basılı tutunca tekrar eder
--
-- Ses PipeWire/WirePlumber üzerinden `wpctl` ile kontrol edilir (pactl değil).
-- `-l 1` ses seviyesinin %100'ü aşmasını engeller.

hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),
    { locked = true, repeating = true, description = "Sesi artır" })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
    { locked = true, repeating = true, description = "Sesi azalt" })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
    { locked = true, description = "Sesi kapat/aç" })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
    { locked = true, description = "Mikrofonu kapat/aç" })

-- Parlaklık. `-e4` algısal (üstel) eğri kullanır, `-n2` en düşük seviyede
-- ekranın tamamen kararmasını engeller.
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),
    { locked = true, repeating = true, description = "Parlaklığı artır" })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),
    { locked = true, repeating = true, description = "Parlaklığı azalt" })

-- Medya (playerctl gerekir)
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })

-- ---------------------------------------------------------------------------
-- Sistem
-- ---------------------------------------------------------------------------
-- Eski yapılandırmadaki davranış: waybar'ı öldür ve yeniden başlat. SIGUSR2
-- yalnızca yeniden yükler; style.css'i düzenlerken tam yeniden başlatma daha
-- güvenilir sonuç veriyor.
hl.bind(mod .. " + U", hl.dsp.exec_cmd("pkill waybar; waybar"),
    { description = "Waybar'ı yeniden başlat" })
hl.bind(mod .. " + N", hl.dsp.exec_cmd("makoctl dismiss --all"),
    { description = "Bildirimleri temizle" })
hl.bind(mod .. " + SHIFT + N", hl.dsp.exec_cmd("makoctl restore"),
    { description = "Son bildirimi geri getir" })
hl.bind(mod .. " + I", hl.dsp.exec_cmd(apps.monitor),
    { description = "Sistem izleyici (btop)" })
