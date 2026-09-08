--[[
  Oturum açılışında başlayan süreçler.

  Sıra önemli: önce D-Bus/portal ortamı hazırlanır, sonra ona ihtiyaç duyan
  ajanlar ve arayüz bileşenleri başlar. Ortam değişkenleri D-Bus'a aktarılmazsa
  ekran paylaşımı, dosya seçici diyalogları ve bildirimler çalışmaz.

  TASARIM İLKESİ — dayanıklılık:
  Her komut `exec_if` üzerinden geçer: program kurulu değilse hiç çalıştırılmaz.
  Böylece eksik bir paket yüzünden açılış sırası yarıda kesilmez; masaüstü
  eksik bileşen olmadan da açılır. Eskiden mako kurulu olmadığı halde
  başlatılmaya çalışılıyordu ve hiçbir bildirim görünmüyordu.

  GÖRÜNÜM (tema/simge/imleç) BURADA AYARLANMAZ. Eski sürümde her açılışta
  `gsettings set ... gtk-theme "Andromeda-gtk"` çalışıyordu; bu hem o tema
  kurulu olmayan bir bilgisayarda GTK'yı bozuyor hem de nwg-look ile yapılan
  her değişikliği bir sonraki açılışta geri alıyordu. Görünüm ayarları kurulum
  betiği tarafından bir kez yazılır (setup_gtk / setup_cursor) ve dconf'ta
  kalıcıdır.
--]]

--- Komutu yalnızca ilk kelimesi PATH'te varsa çalıştırır.
--- @param cmd string
local function exec_if(cmd)
    local bin = cmd:match("^%S+")
    if bin == nil then return end
    -- `command -v` yerleşiktir ve alt kabuk açmadan hızlıca yanıt verir.
    hl.exec_cmd(string.format("command -v %s >/dev/null 2>&1 && %s", bin, cmd))
end

hl.on("hyprland.start", function()
    -- 1) Ortamı systemd ve D-Bus'a aktar.
    --    Bu olmadan xdg-desktop-portal-hyprland doğru WAYLAND_DISPLAY'i görmez;
    --    ekran paylaşımı ve dosya seçici diyalogları sessizce başarısız olur.
    exec_if("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE")
    exec_if("systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE")

    -- 2) Yetkilendirme ajanı. Kurulu değilse sudo/polkit isteyen grafik
    --    uygulamaları (nm-connection-editor, gparted, timeshift) hiç açılmaz.
    hl.exec_cmd("systemctl --user start hyprpolkitagent")

    -- 3) Arayüz bileşenleri.
    exec_if("hyprpaper")   -- duvar kağıdı
    exec_if("waybar")      -- üst panel
    exec_if("mako")        -- bildirim daemon'u
    exec_if("hypridle")    -- boşta kalma → karart / kilitle / uyut

    -- 4) Pano geçmişi. wl-paste --watch, kopyalanan her şeyi cliphist'e yazar;
    --    SUPER+SHIFT+V ile aranabilir hale gelir.
    --    (Kontrol wl-paste için; cliphist onunla birlikte kuruluyor.)
    exec_if("wl-paste --type text --watch cliphist store")
    exec_if("wl-paste --type image --watch cliphist store")

    -- 5) XDG kullanıcı dizinlerini tazele (~/Resimler, ~/İndirilenler ...).
    --    Ekran görüntüsü kısayolları hedef dizini buradan öğrenir.
    exec_if("xdg-user-dirs-update")
end)
