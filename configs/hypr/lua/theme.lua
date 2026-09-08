--[[
  Catppuccin Mocha — tüm masaüstünün tek renk kaynağı.

  Bu dosya deponun renk otoritesidir. Waybar, rofi, mako, wlogout, alacritty ve
  hyprlock aynı paleti kullanır; bir rengi burada değiştirdiğinizde karşılığını
  ilgili stil dosyasında da güncelleyin (dosya başlarında palet blokları var).

  Palet referansı: https://catppuccin.com/palette
--]]

local M = {}

-- Ham hex değerleri (# olmadan) — Hyprland rgb()/rgba() bunları bu şekilde ister.
M.hex = {
    rosewater = "f5e0dc",
    flamingo  = "f2cdcd",
    pink      = "f5c2e7",
    mauve     = "cba6f7",
    red       = "f38ba8",
    maroon    = "eba0ac",
    peach     = "fab387",
    yellow    = "f9e2af",
    green     = "a6e3a1",
    teal      = "94e2d5",
    sky       = "89dceb",
    sapphire  = "74c7ec",
    blue      = "89b4fa",
    lavender  = "b4befe",

    text      = "cdd6f4",
    subtext1  = "bac2de",
    subtext0  = "a6adc8",
    overlay2  = "9399b2",
    overlay1  = "7f849c",
    overlay0  = "6c7086",
    surface2  = "585b70",
    surface1  = "45475a",
    surface0  = "313244",
    base      = "1e1e2e",
    mantle    = "181825",
    crust     = "11111b",
}

--- Bir palet rengini Hyprland rgba() dizesine çevirir.
--- @param name string  M.hex içindeki renk adı
--- @param alpha string|nil  iki haneli hex alfa, varsayılan "ff"
--- @return string
function M.rgba(name, alpha)
    local value = M.hex[name]
    if value == nil then
        -- Bilinmeyen renk adı sessizce siyaha düşmesin; görünür ama zararsız olsun.
        return "rgba(ff00ffff)"
    end
    return "rgba(" .. value .. (alpha or "ff") .. ")"
end

--- Semantik roller. Bileşenler doğrudan renk adı yerine bunları kullanır,
--- böylece paleti değiştirmek tek noktadan mümkün olur.
M.role = {
    accent    = "blue",     -- odak, aktif öğe
    accent_alt = "mauve",   -- ikincil vurgu
    ok        = "green",
    warn      = "yellow",
    danger    = "red",
}

return M
