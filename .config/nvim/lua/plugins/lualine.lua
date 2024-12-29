-- ステータスラインをカスタマイズする
---@type LazySpec
local spec = {
  "nvim-lualine/lualine.nvim",
  event = "BufEnter",
  opts = {
    options = {
      icons_enabled = true,
      theme = "auto",
      use_mode_colors = true,
      component_separators = { left = "", right = "" },
      section_separators = { left = "", right = "" },
      disabled_filetypes = {
        statusline = { "oil" },
        winbar = { "oil" },
      },
      ignore_focus = {},
      always_divide_middle = true,
      globalstatus = false,
      refresh = {
        statusline = 1000,
        tabline = 1000,
        winbar = 1000,
      },
    },
    sections = {
      lualine_a = { "mode" },
      lualine_b = { "branch", "diff", "diagnostics" },
      lualine_c = {
        {
          "filetype",
          icon_only = true,
        },
        {
          "filename",
          file_status = true,
          newfile_status = true,
          path = 1, -- 1: Relative path
          symbols = {
            modified = "[+]",
            readonly = "[-]",
            unnamed = "[No Name]",
            newfile = "[New]",
          },
        },
      },
      lualine_x = { "filetype" },
      lualine_y = {
        {
          "fileformat",
          symbols = {
            unix = "LF",
            mac = "CR",
            os = "CRLF",
          },
        },
      },
      lualine_z = { "encoding" },
    },
    inactive_sections = {
      lualine_a = {},
      lualine_b = {},
      lualine_c = { "filename" },
      lualine_x = {},
      lualine_y = {},
      lualine_z = {},
    },
    tabline = {},
    winbar = {},
    inactive_winbar = {},
    extensions = {},
  },
}

return spec
