--[[
  Klavye, fare, touchpad ve dokunma hareketleri.
--]]

hl.config({
    input = {
        kb_layout  = "tr",
        kb_variant = "",
        kb_model   = "",
        kb_options = "",
        kb_rules   = "",

        -- Tuş tekrarı. Eski değer (rate 70 / delay 400) çok agresifti; bir tuşu
        -- basılı tutunca imleç kaçıyordu. 40/300 hızlı ama kontrollü.
        repeat_rate  = 40,
        repeat_delay = 300,

        numlock_by_default = true,

        -- 1 = fare hangi pencerenin üzerindeyse odak oraya geçer.
        follow_mouse = 1,
        -- Odak değişmeden önce farenin gitmesi gereken mesafe; pencere kenarında
        -- fareyi hafifçe oynattığınızda odağın kaçmasını engeller.
        follow_mouse_threshold = 2,

        sensitivity  = 0,     -- -1.0 .. 1.0, 0 = değişiklik yok
        accel_profile = "flat", -- fare ivmesi kapalı, 1:1 hareket

        touchpad = {
            natural_scroll       = false,
            disable_while_typing = true,
            tap_to_click         = true,
            tap_and_drag         = true,
            drag_lock            = 1,
            scroll_factor        = 0.5,
            -- 2 parmak = sağ tık, 3 parmak = orta tık
            tap_button_map       = "lrm",
        },
    },

    gestures = {
        -- Kaydırma hareketinin ne kadar mesafede tamamlanacağı.
        workspace_swipe_distance    = 300,
        workspace_swipe_cancel_ratio = 0.5,
        -- Boş workspace'e kaydırınca yeni workspace oluşturma; monitör başına
        -- sabit workspace kullandığımız için kapalı.
        workspace_swipe_create_new  = false,
        workspace_swipe_direction_lock = true,
    },
})

-- ---------------------------------------------------------------------------
-- Touchpad hareketleri
-- ---------------------------------------------------------------------------
-- Not: Hyprland 0.51'de eski `gestures:workspace_swipe = true` ayarı KALDIRILDI.
-- Yerine gelen API `hl.gesture()`. Eski config'te bu satır hâlâ vardı ve
-- (üstelik iki kez tanımlıydı) hiçbir işe yaramıyordu.

-- 3 parmak yatay: workspace'ler arasında geç.
hl.gesture({
    fingers   = 3,
    direction = "horizontal",
    action    = "workspace",
})

-- 4 parmak yukarı: özel (scratchpad) workspace'i aç/kapat.
hl.gesture({
    fingers   = 4,
    direction = "up",
    action    = "special",
    workspace_name = "magic",
})

-- ---------------------------------------------------------------------------
-- Cihaza özel ayarlar
-- ---------------------------------------------------------------------------
-- Cihaz adlarını görmek için:  hyprctl devices
-- Örnek (harici fareyi ayrı ayarlamak isterseniz):
--
-- hl.device({
--     name        = "logitech-usb-receiver",
--     sensitivity = -0.2,
--     accel_profile = "flat",
-- })
