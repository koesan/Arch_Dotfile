--[[
  Pencere ve katman kuralları.

  Sınıf/başlık öğrenmek için:  hyprctl clients   |   hyprctl activewindow
--]]

-- ---------------------------------------------------------------------------
-- Genel davranış düzeltmeleri
-- ---------------------------------------------------------------------------

-- Uygulamaların kendi kendine "ekranı kapla" isteğini yok say; döşemeli
-- düzende bu istek pencereleri bozar.
hl.window_rule({
    name  = "suppress-maximize",
    match = { class = ".*" },
    suppress_event = "maximize",
})

-- XWayland sürükle-bırak sırasında oluşan görünmez yardımcı pencerelerin
-- odağı çalmasını engeller.
hl.window_rule({
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },
    no_focus = true,
})

-- ---------------------------------------------------------------------------
-- Yüzen pencereler
-- ---------------------------------------------------------------------------
-- Diyaloglar ve küçük yardımcı araçlar döşenmek yerine ortada yüzsün.

local float_classes = {
    "^(pavucontrol)$",
    "^(blueman-manager)$",
    "^(nm-connection-editor)$",
    "^(nwg-look)$",
    "^(qt5ct)$",
    "^(qt6ct)$",
    "^(org.gnome.Calculator)$",
    "^(file-roller)$",
    "^(xdg-desktop-portal-gtk)$",
    "^(polkit-gnome-authentication-agent-1)$",
    "^(hyprpolkitagent)$",
}

for _, class in ipairs(float_classes) do
    hl.window_rule({
        match  = { class = class },
        float  = true,
        center = true,
        size   = { 900, 600 },
    })
end

-- Başlığa göre yüzen diyaloglar (sınıf uygulamanın kendisiyle aynı olduğu için
-- başlıkla eşleşmek gerekiyor).
local float_titles = {
    "^(Open File)$",
    "^(Open Folder)$",
    "^(Save As)$",
    "^(Dosya Aç)$",
    "^(Farklı Kaydet)$",
    "^(Confirm to replace files)$",
    "^(File Operation Progress)$",
    "^(Authentication Required)$",
    "^(Kimlik Doğrulama Gerekli)$",
}

for _, title in ipairs(float_titles) do
    hl.window_rule({
        match  = { title = title },
        float  = true,
        center = true,
    })
end

-- ---------------------------------------------------------------------------
-- Gizlilik / güvenlik
-- ---------------------------------------------------------------------------
-- Parola yöneticisi ve kimlik doğrulama pencereleri ekran paylaşımında
-- görünmesin. Toplantı sırasında sudo şifresi paylaşmamak için.
hl.window_rule({
    name  = "hide-auth-from-screenshare",
    match = { class = "^(hyprpolkitagent|polkit-gnome-authentication-agent-1|org.keepassxc.KeePassXC|Bitwarden)$" },
    no_screen_share = true,
})

-- ---------------------------------------------------------------------------
-- Opaklık
-- ---------------------------------------------------------------------------
-- Görsel içerik gösteren uygulamalarda saydamlık renkleri bozar; bunlar opak.
hl.window_rule({
    name  = "opaque-media",
    match = { class = "^(mpv|vlc|imv|Gimp|obs|brave-browser|Brave-browser|firefox|Code|code-oss)$" },
    opaque = true,
})

-- Video oynatan pencerede boşta kalma sayacı işlemesin (ekran kilitlenmesin).
hl.window_rule({
    name  = "inhibit-idle-on-fullscreen",
    match = { class = ".*", fullscreen = true },
    idle_inhibit = "fullscreen",
})

-- ---------------------------------------------------------------------------
-- Scratchpad
-- ---------------------------------------------------------------------------
-- SUPER+S ile açılan özel workspace boşsa bir terminal açılsın.
hl.workspace_rule({
    workspace        = "special:magic",
    on_created_empty = "alacritty",
})

-- ---------------------------------------------------------------------------
-- Katman kuralları (Waybar, rofi, mako)
-- ---------------------------------------------------------------------------
-- Bu yüzeylerin arkası bulanıklaşsın; kendi yarı saydam arka planlarıyla
-- birlikte panel/menülere derinlik kazandırır.

hl.layer_rule({ match = { namespace = "^(waybar)$" },     blur = true, ignore_alpha = 0.2 })
hl.layer_rule({ match = { namespace = "^(rofi)$" },       blur = true, ignore_alpha = 0.2 })
hl.layer_rule({ match = { namespace = "^(notifications)$" }, blur = true, ignore_alpha = 0.2 })
hl.layer_rule({ match = { namespace = "^(wlogout)$" },    blur = true })

-- Kilit ekranı ve oturum menüsü animasyonsuz açılsın (anında tepki versin).
hl.layer_rule({ match = { namespace = "^(hyprlock)$" }, no_anim = true })
