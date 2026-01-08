local wezterm = require("wezterm")
local act = wezterm.action

return {
  keys = {
    { key = "Copy",  mods = "NONE",       action = act.CopyTo("Clipboard") },
    { key = "Paste", mods = "NONE",       action = act.PasteFrom("Clipboard") },
    { key = "Tab",   mods = "CTRL",       action = act.ActivateTabRelative(1) },
    { key = "Tab",   mods = "SHIFT|CTRL", action = act.ActivateTabRelative(-1) },
    { key = "c",     mods = "ALT",        action = act.CopyTo("Clipboard") },
    { key = "e",     mods = "ALT",        action = act({ EmitEvent = "trigger-nvim-with-scrollback" }) },
    { key = "f",     mods = "ALT",        action = act.Search("CurrentSelectionOrEmptyString") },
    { key = "n",     mods = "ALT",        action = act.SpawnWindow },
    { key = "p",     mods = "ALT",        action = act.ActivateCommandPalette },
    { key = "q",     mods = "ALT",        action = act.QuitApplication },
    { key = "r",     mods = "ALT",        action = act.ReloadConfiguration },
    { key = "t",     mods = "ALT",        action = act.SpawnTab("CurrentPaneDomain") },
    { key = "t",     mods = "ALT",        action = act.SpawnTab("CurrentPaneDomain") },
    { key = "v",     mods = "ALT",        action = act.PasteFrom("Clipboard") },
    { key = "w",     mods = "ALT",        action = act.CloseCurrentTab({ confirm = true }) },
  },

  key_tables = {
    copy_mode = {},

    search_mode = {
      { key = "c",         mods = "CTRL",  action = act.CopyMode("ClearPattern") },
      { key = "UpArrow",   mods = "NONE",  action = act.CopyMode("PriorMatch") },
      { key = "DownArrow", mods = "NONE",  action = act.CopyMode("NextMatch") },
      { key = "Enter",     mods = "NONE",  action = act.CopyMode("PriorMatch") },
      { key = "Enter",     mods = "SHIFT", action = act.CopyMode("NextMatch") },
      { key = "Escape",    mods = "NONE",  action = act.CopyMode("Close") },
    },
  },
}
