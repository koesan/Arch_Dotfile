--[[
  ═══════════════════════════════════════════════════════════════════════════
   Waybar köprüsü — panel göstergelerini olay bazlı tazeler
   Arch_Dotfile · https://github.com/koesan/Arch_Dotfile

   NEDEN VAR: Paneldeki workspace göstergesi (waybar/config içindeki
   custom/ws1 … custom/ws10) yerleşik `hyprland/workspaces` modülünün yerini
   aldı. Gerekçesi orada anlatılıyor — kısaca: yerleşik modülün tıklaması
   Hyprland'in Lua yapılandırma biçiminde çalışmıyor.

   Yerleşik modül Hyprland'in olay soketini kendisi dinlerdi. Custom modüller
   dinleyemez; ya saniyede bir yoklarlar (on ayrı süreç, boşuna CPU) ya da
   dışarıdan bir sinyalle tazelenirler. İkincisi seçildi: aşağıdaki olaylarda
   waybar'a SIGRTMIN+9 gönderiliyor, modüller yalnızca o an çalışıyor.

   SİNYAL NUMARASI, waybar/config'teki `"signal": 9` ile AYNI olmalıdır.
   (Kahve düğmesi SIGRTMIN+8, ekran kaydı göstergesi SIGRTMIN+10
   kullanıyor — çakışmasın.)
  ═══════════════════════════════════════════════════════════════════════════
--]]

-- waybar/config → "custom/wsN" → "signal"
local SIGNAL = 9

-- waybar çalışmıyorsa pkill sessizce başarısız olur; oturum açılışında panel
-- henüz ayağa kalkmamışken de bu yüzden sorun çıkmaz.
local function refresh_bar()
    hl.exec_cmd("pkill -RTMIN+" .. SIGNAL .. " waybar")
end

-- Göstergeyi etkileyen her şey:
--   workspace.*  → hangi workspace odaklı / oluştu / silindi
--   window.*     → bir workspace doldu ya da boşaldı (gösterge yalnızca DOLU
--                  workspace'leri çizdiği için doğrudan görünümü değiştirir)
--   monitor.focused → çok monitörlü kurulumda odak başka ekrana geçti
for _, event in ipairs({
    "workspace.active",
    "workspace.created",
    "workspace.removed",
    "window.open",
    "window.close",
    "window.move_to_workspace",
    "monitor.focused",
}) do
    hl.on(event, refresh_bar)
end
