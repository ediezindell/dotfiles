-- ファイル検索
---@type LazySpec
local spec = {
  "nvim-telescope/telescope.nvim",
  event = "VimEnter",
  requires = {
    "nvim-tree/nvim-web-devicons",
    "nvim-lua/plenary.nvim",
    { "nvim-telescope/telescope-fzf-native.nvim", run = "make" },
  },
  keys = {
    { "<space>ff", [[<Cmd>lua require("telescope.builtin").find_files()<CR>]], desc = "telescope find_files" },
    { "<space>fg", [[<Cmd>lua require("telescope.builtin").live_grep()<CR>]],  desc = "telescope live_grep" },
    { "<space>fb", [[<Cmd>lua require("telescope.builtin").buffers()<CR>]],    desc = "telescope buffers" },
    { "<space>fh", [[<Cmd>lua require("telescope.builtin").help_tags()<CR>]],  desc = "telescope help" },
  },
  config = function()
    local telescope = require("telescope")
    local actions = require("telescope.actions")

    telescope.setup({
      defaults = {
        mappings = {
          i = {
            ["<esc>"] = actions.close,
          },
          n = {
            ["<esc>"] = actions.close,
            [":"] = actions.close,
            ["q"] = actions.close,
          },
        },
        path_display = {
          filename_first = {
            reverse_directories = false,
          },
        },
        layout_strategy = "vertical",
        winblend = 20,
      },
    })
  end,
}

return spec
