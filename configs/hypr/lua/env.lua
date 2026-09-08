--[[
  Ortam değişkenleri.

  Bu dosyada YALNIZCA her Arch makinesinde doğru olan değişkenler bulunur.
  Donanıma bağlı olan hiçbir şey yok — ekran kartı, sürücü ve ekran adı
  varsayımı yapılmaz. Böylece depo düzenlenmeden farklı bir bilgisayarda da
  çalışır.

  GPU'ya özel ayarlar (NVIDIA değişkenleri, VA-API sürücü zorlaması) için:
      ~/.config/hypr/lua/local.lua      (örnek: local.lua.example)

  Neden burada değil:
  · LIBVA_DRIVER_NAME sabitlenirse yanlış GPU'ya yönlenen makinede tarayıcı
    video hızlandırması tamamen bozulur. Ayarlanmadığında libva doğru sürücüyü
    kendisi seçer.
  · NVIDIA değişkenleri hibrit dizüstülerde XWayland uygulamalarını gereksiz
    yere ayrık GPU'da çalıştırıp pil tüketir. Tek bir uygulamayı ayrık GPU'da
    çalıştırmak için `prime-run <uygulama>` doğru yöntemdir (nvidia-prime).
--]]

-- İmleç boyutu. XCURSOR_SIZE XWayland/GTK için, HYPRCURSOR_SIZE hyprcursor için.
-- İmleç TEMASI burada sabitlenmez: kurulum betiği gerçekten kurulu olan temayı
-- (Catppuccin varsa o, yoksa Adwaita) tespit edip lua/cursor.lua dosyasına
-- yazar; aşağıda o dosya varsa yüklenir ve bu varsayılanları geçersiz kılar.
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

-- Kurulum betiğinin ürettiği imleç ayarları (varsa).
pcall(require, "lua.cursor")

-- Qt uygulamaları Wayland altında native çalışsın, mevcut olmayanlar xcb'ye düşsün.
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
-- Qt teması qt6ct üzerinden. Kurulum betiği qt5ct + qt6ct kurar ve ikisine de
-- Catppuccin Mocha renk şemasını yazar (setup_qt). Eski config burada "qt5ct"
-- diyordu ama qt5ct paketi hiç kurulmuyordu; Qt uygulamaları açılışta
-- "could not find platform theme" uyarısı verip açık gri temaya düşüyordu.
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
-- Qt'nin kendi başlık çubuğunu çizmesini engelle (Hyprland zaten dekorasyon çiziyor).
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", "1")

-- Toolkit backend'leri
hl.env("GDK_BACKEND", "wayland,x11,*")
hl.env("SDL_VIDEODRIVER", "wayland")
hl.env("CLUTTER_BACKEND", "wayland")
hl.env("MOZ_ENABLE_WAYLAND", "1")

-- XDG masaüstü kimliği. Portallar ve .desktop dosyaları bunu okur.
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")

-- GTK teması BURADA ayarlanmaz.
--
-- Eskiden `hl.env("GTK_THEME", "Andromeda-gtk")` vardı. GTK_THEME bir hata
-- ayıklama değişkenidir ve her şeyi ezer: tema kurulu değilse (başka bir
-- bilgisayarda) tüm GTK uygulamaları varsayılan açık temaya düşer, üstelik
-- nwg-look ile tema değiştirmek imkânsız hale gelir.
--
-- Doğru yol, GTK'nın kendi ayar kaynaklarını kullanmaktır; kurulum betiği
-- (setup_gtk) gerçekten KURULU olan tema adını tespit edip üçünü birden yazar:
--   ~/.config/gtk-3.0/settings.ini      GTK3
--   ~/.config/gtk-4.0/settings.ini      GTK4
--   gsettings org.gnome.desktop.interface   portal üzerinden GTK4 + Flatpak
