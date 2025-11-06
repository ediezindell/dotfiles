--- モード変更時に通知を表示
---@type LazySpec
local spec = {
  "ediezindell/denops-mode-change-notify.vim",
  dependencies = {
    "vim-denops/denops.vim",
  },
  event = "BufEnter",
  init = function()
    vim.g.mode_change_notify_options = {
      style = "ascii_filled",
      -- timeout = 750,
      position = "center",
      -- position = "top_right",
      -- position = "bottom_right",
      -- position = "top_left",
      -- position = "bottom_left",
    }
  end,
}
return spec
