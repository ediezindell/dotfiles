local wezterm = require('wezterm')

wezterm.on("gui-startup", function(cmd)
    local tab, pane, window = wezterm.mux.spawn_window(cmd or {})
    window:gui_window():toggle_fullscreen()
end)

local config = {
  window_background_opacity = 0.4,
  keys = {
    {
      key = 'f',
      mods = 'SHIFT|META',
      action = wezterm.action.ToggleFullScreen,
    },
  },
  color_scheme = 'AdventureTime',
  font = wezterm.font("FirgeNerd Console", {
    weight = "Medium",
    stretch = "Normal",
    style = "Normal",
  }),
  font_size = 15,
}

return config
