local wezterm = require("wezterm")
-- local keybind = require("keybinds")

local config = {
  -- appearance
  color_scheme = "nord",
  window_background_opacity = 0.90,
  font = wezterm.font("Firge", {
    weight = "Medium",
    stretch = "Normal",
    style = "Normal",
  }),
  font_size = 16,
  -- keybinds
  -- disable_default_key_bindings = true,
  -- keys = keybind.keys,
  -- key_tables = keybind.key_tables,
}

return config
