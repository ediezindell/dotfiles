local wezterm = require("wezterm")
local act = wezterm.action

return {
  keys = {
    { key = "Copy", mods = "NONE", action = act.CopyTo("Clipboard") },
    { key = "Paste", mods = "NONE", action = act.PasteFrom("Clipboard") },
    { key = "Tab", mods = "CTRL", action = act.ActivateTabRelative(1) },
    { key = "Tab", mods = "SHIFT|CTRL", action = act.ActivateTabRelative(-1) },
    { key = "c", mods = "SUPER", action = act.CopyTo("Clipboard") },
    { key = "e", mods = "SUPER", action = act({ EmitEvent = "trigger-nvim-with-scrollback" }) },
    { key = "f", mods = "SUPER", action = act.Search("CurrentSelectionOrEmptyString") },
    { key = "n", mods = "SUPER", action = act.SpawnWindow },
    { key = "p", mods = "SUPER", action = act.ActivateCommandPalette },
    { key = "q", mods = "SUPER", action = act.QuitApplication },
    { key = "r", mods = "SUPER", action = act.ReloadConfiguration },
    { key = "t", mods = "SUPER", action = act.SpawnTab("CurrentPaneDomain") },
    { key = "v", mods = "SUPER", action = act.PasteFrom("Clipboard") },
    { key = "w", mods = "SUPER", action = act.CloseCurrentTab({ confirm = true }) },
  },

  key_tables = {
    copy_mode = {},

    search_mode = {
      { key = "c", mods = "CTRL", action = act.CopyMode("ClearPattern") },
      { key = "UpArrow", mods = "NONE", action = act.CopyMode("PriorMatch") },
      { key = "DownArrow", mods = "NONE", action = act.CopyMode("NextMatch") },
      { key = "Enter", mods = "NONE", action = act.CopyMode("PriorMatch") },
      { key = "Enter", mods = "SHIFT", action = act.CopyMode("NextMatch") },
      { key = "Escape", mods = "NONE", action = act.CopyMode("Close") },
    },
  },
}
