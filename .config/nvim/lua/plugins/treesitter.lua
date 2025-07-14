-- code highlight
---@type LazySpec[]
local spec = {
  {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    run = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        modules = {},
        ensure_installed = "all",
        ignore_install = {},
        sync_install = false,
        auto_install = true,
        highlight = {
          enable = true,
          disable = { "text" },
        },
      })
    end,
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
