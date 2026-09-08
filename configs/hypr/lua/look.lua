--[[
  Görünüm: boşluklar, kenarlıklar, dekorasyon, animasyonlar, düzen.
  Renkler tek kaynaktan (lua/theme.lua) gelir.
--]]

local theme = require("lua.theme")

hl.config({
    general = {
        -- Sıkı ama nefes alan bir ızgara. gaps_in pencereler arası,
        -- gaps_out ekran kenarı ile pencere arası.
        gaps_in  = 4,
        gaps_out = 8,

        border_size = 2,

        col = {
            -- Aktif pencere tek renk vurgu; degrade yerine düz renk daha sakin
            -- ve okunaklı durur.
            active_border   = theme.rgba(theme.role.accent),
            inactive_border = theme.rgba("surface0", "aa"),
        },

        -- Kenarlık/boşluk sürükleyerek yeniden boyutlandırma. Açık olması
        -- fare ile çalışırken pratik; yanlışlıkla tetiklenmesi zor.
        resize_on_border      = true,
        extend_border_grab_area = 8,
        hover_icon_on_border  = true,

        -- Oyun/video'da yırtılma izni. Kapalı bırakın; açmadan önce:
        -- https://wiki.hypr.land/Configuring/Extra/Tearing/
        allow_tearing = false,

        layout = "dwindle",

        -- Yüzen pencereleri kenarlara/birbirine yapıştır.
        snap = {
            enabled     = true,
            window_gap  = 10,
            monitor_gap = 10,
        },
    },

    decoration = {
        rounding       = 10,
        rounding_power = 2,

        active_opacity   = 1.0,
        -- Eski değer 0.7 idi; arka plandaki pencerelerdeki metni okumayı
        -- zorlaştırıyordu. 0.94 hem derinlik hissi verir hem okunaklı kalır.
        inactive_opacity = 0.94,

        shadow = {
            enabled      = true,
            range        = 12,
            render_power = 3,
            color        = theme.rgba("crust", "aa"),
        },

        blur = {
            enabled          = true,
            size             = 6,
            passes           = 2,
            new_optimizations = true,
            vibrancy         = 0.1696,
            -- Waybar/rofi/mako gibi katman yüzeylerinin açılır menüleri de bulanık olsun.
            popups           = true,
            popups_ignorealpha = 0.2,
        },
    },

    animations = {
        -- KAPALI (kullanıcı tercihi). Pencere açılış/kapanış, workspace geçişi
        -- ve katman geçişleri anında olur; girdi gecikmesi hissi ortadan kalkar
        -- ve zayıf GPU'larda kare atlaması olmaz.
        -- Geri açmak için: enabled = true. Aşağıdaki eğri/animasyon tanımları
        -- olduğu yerde duruyor, tekrar yazmanıza gerek yok.
        enabled = false,
    },

    dwindle = {
        -- Not: eski config'teki `pseudotile = true` artık bir ayar değil,
        -- yalnızca bir dispatcher (SUPER+P ile aç/kapa — bkz. binds.lua).
        preserve_split = true,  -- bölme yönünü koru
        smart_split    = false,
        smart_resizing = true,
    },

    master = {
        new_status = "master",
    },

    misc = {
        -- Hyprland'in kendi duvar kağıdını ve logosunu kapat; hyprpaper zaten
        -- duvar kağıdı çiziyor. Aksi halde açılışta kısa bir logo/maskot yanıp söner.
        force_default_wallpaper = 0,
        disable_hyprland_logo   = true,
        disable_splash_rendering = true,

        -- Pencere yokken görünen zemin. Duvar kağıdı yüklenene dek bu renk görünür,
        -- palet dışı bir renk yanıp sönmesin diye ayarlanıyor.
        background_color = "rgb(" .. theme.hex.crust .. ")",

        -- Bir uygulama kendini öne almak istediğinde odağı ona ver
        -- (ör. tarayıcıdan bir bağlantı açıldığında).
        focus_on_activate = true,

        -- Orta tık ile yapıştırma: terminalde ve editörde kazara yapıştırmanın
        -- en sık sebebi. Kapalı.
        middle_click_paste = false,

        -- Terminalden bir GUI uygulaması açtığınızda terminal penceresi gizlensin,
        -- uygulama kapanınca geri gelsin.
        enable_swallow = true,
        swallow_regex  = "^(Alacritty|kitty|foot)$",

        -- Yanıt vermeyen uygulama için "kapatmak ister misiniz?" diyaloğu.
        enable_anr_dialog = true,
    },

    binds = {
        -- Aynı workspace'e tekrar basınca bir öncekine dön.
        workspace_back_and_forth = true,
        -- Workspace değiştirince özel (scratchpad) workspace kapansın.
        hide_special_on_workspace_change = true,
    },

    cursor = {
        -- Not: eski config'te WLR_NO_HARDWARE_CURSORS vardı. O bir wlroots
        -- değişkeni; Hyprland 0.28'den beri wlroots kullanmıyor, dolayısıyla
        -- etkisizdi. Doğru ayar budur ve donanım imleci sorunsuz çalıştığı için
        -- kapatmaya gerek yok.
        no_hardware_cursors = 2,  -- 2 = otomatik karar ver
        enable_hyprcursor   = true,
        -- Yazarken imleci gizle, fare hareket edince geri getir.
        hide_on_key_press   = true,
        inactive_timeout    = 5,
    },

    ecosystem = {
        -- Her güncellemede açılan "yeni sürüm" ve bağış bildirimlerini kapat.
        no_update_news  = true,
        no_donation_nag = true,
    },

    xwayland = {
        -- XWayland uygulamalarında bulanık/ölçekli metin sorununu önler.
        force_zero_scaling = true,
    },
})

-- ---------------------------------------------------------------------------
-- Animasyonlar
-- ---------------------------------------------------------------------------
-- ŞU AN ETKİSİZ: yukarıda animations.enabled = false. Aşağıdaki tanımlar
-- bilerek duruyor; animasyonları geri açmak isterseniz tek satır yeter
-- (enabled = true) ve bu ayarlar olduğu gibi devreye girer.
-- Tümü kısa tutulmuştu: hareket hissi verir ama beklemeye sebep olmaz.

hl.curve("easeOutQuint",   { type = "bezier", points = { { 0.23, 1 },    { 0.32, 1 } } })
hl.curve("easeInOutCubic", { type = "bezier", points = { { 0.65, 0.05 }, { 0.36, 1 } } })
hl.curve("linear",         { type = "bezier", points = { { 0, 0 },       { 1, 1 } } })
hl.curve("almostLinear",   { type = "bezier", points = { { 0.5, 0.5 },   { 0.75, 1 } } })
hl.curve("quick",          { type = "bezier", points = { { 0.15, 0 },    { 0.1, 1 } } })

-- Yay (spring) eğrisi: pencere açılış/kapanışına doğal bir sönümleme verir.
hl.curve("snappy", { type = "spring", mass = 1, stiffness = 250, dampening = 26 })

hl.animation({ leaf = "global",        enabled = true, speed = 8,    bezier = "easeOutQuint" })
hl.animation({ leaf = "border",        enabled = true, speed = 4,    bezier = "easeOutQuint" })

hl.animation({ leaf = "windows",       enabled = true, speed = 4,    spring = "snappy" })
hl.animation({ leaf = "windowsIn",     enabled = true, speed = 3.5,  spring = "snappy",       style = "popin 92%" })
hl.animation({ leaf = "windowsOut",    enabled = true, speed = 2,    bezier = "linear",       style = "popin 92%" })

hl.animation({ leaf = "fade",          enabled = true, speed = 3,    bezier = "quick" })
hl.animation({ leaf = "fadeIn",        enabled = true, speed = 2,    bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut",       enabled = true, speed = 1.5,  bezier = "almostLinear" })

hl.animation({ leaf = "layers",        enabled = true, speed = 3,    bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn",      enabled = true, speed = 3,    bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut",     enabled = true, speed = 2,    bezier = "linear",       style = "fade" })

hl.animation({ leaf = "workspaces",    enabled = true, speed = 3,    bezier = "easeOutQuint", style = "slidefade 15%" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 3, bezier = "easeOutQuint", style = "slidevert" })

-- ---------------------------------------------------------------------------
-- "Tek pencere varsa boşluk/kenarlık olmasın" (smart gaps)
-- ---------------------------------------------------------------------------
-- Tek pencereyle çalışırken ekranın her pikselini kullanır; ikinci pencere
-- açılınca boşluklar geri gelir.
hl.workspace_rule({ workspace = "w[tv1]", gaps_out = 0, gaps_in = 0 })
hl.workspace_rule({ workspace = "f[1]",   gaps_out = 0, gaps_in = 0 })

hl.window_rule({
    name  = "no-gaps-single-window",
    match = { float = false, workspace = "w[tv1]" },
    border_size = 0,
    rounding    = 0,
})

hl.window_rule({
    name  = "no-gaps-fullscreen",
    match = { float = false, workspace = "f[1]" },
    border_size = 0,
    rounding    = 0,
})
