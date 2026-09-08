--[[
  ═══════════════════════════════════════════════════════════════════════════
   Hyprland yapılandırması — Arch_Dotfile
   https://github.com/koesan/Arch_Dotfile

   Bu dosya yalnızca modülleri yükler. Asıl ayarlar lua/ dizinindedir:

     lua/theme.lua      Catppuccin Mocha paleti — tüm renklerin tek kaynağı
     lua/env.lua        Ortam değişkenleri (GPU, toolkit, XDG)
     lua/monitors.lua   Ekran düzeni (taşınabilir, otomatik algılama)
     lua/look.lua       Boşluk, kenarlık, dekorasyon, animasyon, düzen
     lua/input.lua      Klavye, fare, touchpad, hareketler
     lua/binds.lua      Klavye ve fare kısayolları
     lua/rules.lua      Pencere ve katman kuralları
     lua/autostart.lua  Oturum açılışında başlayan süreçler

   MAKİNEYE ÖZEL AYARLAR — lua/local.lua
   Ekran düzeni, klavye düzeni, NVIDIA seçenekleri gibi o bilgisayara özgü
   ayarları buraya yazın. Dosya git'te izlenmez, kurulum betiği üzerine
   yazmaz. Başlamak için:

       cp ~/.config/hypr/lua/local.lua.example ~/.config/hypr/lua/local.lua

   Depodaki hiçbir dosya ekran adı (eDP-1, HDMI-A-1 ...) varsaymaz; bu yüzden
   yapılandırma hiç düzenlenmeden farklı bir bilgisayarda da açılır.

   NOT — config biçimi:
   Hyprland önce `hyprland.lua` arar; bulamazsa eski `hyprland.conf`
   biçimine düşer (günlükte: "Using lua config found at ..." / "Lua config
   not found, using legacy config at ..."). Bu depo Lua biçimini kullanır ve
   artık `hyprland.conf` GÖNDERMEZ — iki dosya bir arada bulunursa hangisinin
   geçerli olduğu karışır. Sürümünüzü kontrol edin:

       hyprctl version

   Lua desteği olmayan eski bir Hyprland'de bu yapılandırma çalışmaz; kurulum
   betiği sürümü denetler ve uyarır. Sürüm denetimi için ölçüt: sistemde
   /usr/share/hypr/stubs/hl.meta.lua dosyasının bulunması.

   Ayarları doğrulamak / canlı denemek için:
       hyprctl reload          yapılandırmayı yeniden yükle
       hyprctl -j getoption general:gaps_in      bir ayarın etkin değeri
       hyprctl clients         açık pencerelerin class/title bilgisi

   Editörde otomatik tamamlama için depo kökündeki .luarc.json yeterlidir
   (stub: /usr/share/hypr/stubs).
  ═══════════════════════════════════════════════════════════════════════════
--]]

-- Modüller ayrı Lua "scope"larında çalışır: birinde oluşan hata diğerlerini
-- durdurmaz. Bu yüzden tek bir dev dosya yerine require tercih ediliyor.
require("lua.env")
require("lua.monitors")
require("lua.look")
require("lua.input")
require("lua.binds")
require("lua.rules")
require("lua.autostart")
