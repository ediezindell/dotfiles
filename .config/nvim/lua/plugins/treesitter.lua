-- code highlight
---@type LazySpec[]
local spec = {
  {
    "nvim-treesitter/nvim-treesitter",
    event = { "BufNewFile", "BufReadPre" },
    run = ":TSUpdate",
    opts = {
      highlight = {
        enable = true,
        disable = { "text" },
      },
      indent = {
        enable = true,
        disable = { "text" },
      },
      ensure_installed = "all",
    },
  },
  {
    "nvim-treesitter/nvim-treesitter-context",
    event = { "BufNewFile", "BufReadPre" },
    opts = {
      enable = true,
      multiwindow = false,
      max_lines = 0,
      min_window_height = 0,
      line_numbers = false,
      multiline_threshold = 20,
      trim_scope = "outer",
      mode = "cursor",
      separator = nil,
      zindex = 20,
      on_attach = nil,
    },
  },
}

return spec
