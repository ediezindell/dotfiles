local wezterm = require("wezterm")
local keybind = require("keybinds")

local fonts = {
  "Moralerspace Argon HWNF",
  "Moralerspace Neon HWNF",
  "FirgeNerd",
  "FirgeNerd Console",
  "HackGen Console NF",
  "Firge",
}

local config = {
  -- appearance
  color_scheme = "nord",
  window_background_opacity = 0.9,
  font = wezterm.font(fonts[1], {
    weight = "Medium",
    stretch = "Normal",
    style = "Normal",
  }),
  font_size = 16,

  -- keybinds
  disable_default_key_bindings = true,
  keys = keybind.keys,
  key_tables = keybind.key_tables,
}

return config
