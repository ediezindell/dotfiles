local wezterm = require('wezterm')
local keybind = require('keybinds')

wezterm.on("gui-startup", function(cmd)
    local tab, pane, window = wezterm.mux.spawn_window(cmd or {})
    window:gui_window():toggle_fullscreen()
end)

local config = {
  -- appearance
  color_scheme = 'nord',
  window_background_opacity = 0.95,
  font = wezterm.font("FirgeNerd Console", {
    weight = "Medium",
    stretch = "Normal",
    style = "Normal",
  }),
  font_size = 15,
  -- keybinds
  disable_default_key_bindings = true,
  keys = keybind.keys,
  key_tables = keybind.key_tables,
}

return config
