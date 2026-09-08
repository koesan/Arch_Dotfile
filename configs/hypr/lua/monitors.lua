--[[
  Monitör düzeni.

  TASARIM İLKESİ — taşınabilirlik:
  Bu dosya HİÇBİR ekran adını zorunlu kılmaz. Varsayılan kural her çıkışa
  uyar (`output = ""`), böylece depo farklı bir bilgisayarda da ilk açılışta
  doğru çalışır: ekran algılanır, tercih edilen çözünürlük ve otomatik konum
  kullanılır.

  Makineye özel düzen (dikey ikinci ekran, özel konum, ölçek vb.) bu dosyaya
  YAZILMAZ. Onun yeri:  ~/.config/hypr/lua/local.lua
  Örnek için:           ~/.config/hypr/lua/local.lua.example

  local.lua git deposunda izlenmez ve kurulum betiği mevcut dosyanın üzerine
  hiçbir zaman yazmaz — makineye özel ayarlarınız güncellemede kaybolmaz.

  Ekran adlarını ve desteklenen modları görmek için:  hyprctl monitors all
--]]

-- ---------------------------------------------------------------------------
-- Varsayılan: her ekran otomatik
-- ---------------------------------------------------------------------------
-- mode = "preferred" → ekranın bildirdiği tercih edilen mod
-- position = "auto"  → soldan sağa otomatik diz
-- scale = 1          → 1:1 piksel; arayüz ekranın gerçek çözünürlüğünde çizilir
--
-- ÖLÇEK NEDEN "auto" DEĞİL:
-- Hyprland'in `auto` ölçeği, ekranın EDID'de bildirdiği fiziksel boyuta bakıp
-- DPI hesaplar. 14" bir dizüstü paneli 1920x1080 olduğunda bu hesap 1.5
-- çıkarıyor ve her şey (yazı, waybar, rofi, pencere kenarlıkları) %50 büyük
-- görünüyor — kullanılabilir alan 1280x720'ye düşmüş gibi oluyor.
-- Bu depodaki waybar / rofi / mako / alacritty yazı boyutları zaten 1080p'de
-- doğru görünecek şekilde seçildi, bu yüzden varsayılan ölçek 1'dir.
--
-- 4K (3840x2160) gibi gerçekten HiDPI bir ekranda her şey çok küçük gelirse
-- ölçeği burada değil, local.lua içinde büyütün:
--     hl.monitor({ output = "eDP-1", mode = "preferred", position = "auto", scale = 1.5 })
-- Hyprland yalnızca belirli ölçekleri kabul eder (1, 1.25, 1.5, 1.6, 2 ...);
-- kabul edilmeyen bir değerde günlüğe "scale ... is invalid" yazar.
hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = 1,
})

-- Dizüstü paneli varsa en yüksek tazeleme hızını kullan. "highrr" tercih
-- edilen çözünürlükte en yüksek Hz'i seçer; 60Hz bir panelde de, 120/144Hz
-- bir panelde de doğru sonucu verir. Ekran yoksa kural sessizce yok sayılır.
for _, panel in ipairs({ "eDP-1", "eDP-2", "LVDS-1" }) do
    hl.monitor({
        output   = panel,
        mode     = "highrr",
        position = "auto",
        scale    = 1,
    })
end

-- ---------------------------------------------------------------------------
-- Workspace davranışı
-- ---------------------------------------------------------------------------
-- Workspace'ler monitöre SABİTLENMEZ: hangi ekran odaklıysa orada açılırlar.
-- Sabit dağılım (ör. 1-3 dizüstünde, 4-6 haricide) isterseniz local.lua içinde
-- hl.workspace_rule() ile tanımlayın — örnek dosyada hazır blok var.
--
-- Yeni monitör takıldığında ilk workspace'in oraya taşınmasını istemezsiniz;
-- bu yüzden burada `default` bağı da yok.

-- ---------------------------------------------------------------------------
-- Makineye özel geçersiz kılmalar
-- ---------------------------------------------------------------------------
-- local.lua varsa yüklenir. Yoksa hata verilmez (pcall) — depo, dosyayı
-- oluşturmamış bir makinede de sorunsuz açılır.
local ok, err = pcall(require, "lua.local")
if not ok then
    err = tostring(err)
    -- "not found" = dosya hiç yok; bu normal, sessizce geç.
    -- Başka bir hata = dosya var ama içinde sorun var; görünür kıl.
    if not err:find("not found", 1, true) then
        pcall(function()
            hl.notification.create({
                text    = "lua/local.lua yuklenemedi: " .. err,
                timeout = 10000,
            })
        end)
    end
end
