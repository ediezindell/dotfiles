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
}

return config
