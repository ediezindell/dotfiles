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
  font_size = 15,
  hyperlink_rules = {
    -- Matches: a URL in parens: (URL)
    {
      regex = "\\((\\w+://\\S+)\\)",
      format = "$1",
      highlight = 1,
    },
    -- Matches: a URL in brackets: [URL]
    {
      regex = "\\[(\\w+://\\S+)\\]",
      format = "$1",
      highlight = 1,
    },
    -- Matches: a URL in curly braces: {URL}
    {
      regex = "\\{(\\w+://\\S+)\\}",
      format = "$1",
      highlight = 1,
    },
    -- Matches: a URL in angle brackets: <URL>
    {
      regex = "<(\\w+://\\S+)>",
      format = "$1",
      highlight = 1,
    },
    -- Then handle URLs not wrapped in brackets
    {
      regex = "\\b\\w+://\\S+[)/a-zA-Z0-9-]+",
      format = "$0",
    },
    -- implicit mailto link
    -- {
    --   regex = "\\b\\w+@[\\w-]+(\\.[\\w-]+)+\\b",
    --   format = "mailto:$0",
    -- },
  },

  -- keybinds
  disable_default_key_bindings = true,
  keys = keybind.keys,
  key_tables = keybind.key_tables,
  macos_window_background_blur = 20,
  window_decorations = "RESIZE",
  hide_tab_bar_if_only_one_tab = true,
  show_new_tab_button_in_tab_bar = false,
  show_close_tab_button_in_tabs = false,
  colors = {
    tab_bar = {
      inactive_tab_edge = "none",
    },
  },
}

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
  local background = "#2E323C"
  local foreground = "#f8f8f0"

  if tab.is_active then
    background = "#4D5154"
  end

  local space = "      "
  local title = space .. wezterm.truncate_right(tab.active_pane.title, max_width - 1) .. space

  return {
    { Background = { Color = background } },
    { Foreground = { Color = foreground } },
    { Text = title },
  }
end)

return config
