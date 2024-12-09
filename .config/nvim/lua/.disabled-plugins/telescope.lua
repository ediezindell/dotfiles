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

    -- keymap
    CommandKeymap("<space>ff", [[lua require("telescope.builtin").find_files()]], "telescope find_files")
    CommandKeymap("<space>fg", [[lua require("telescope.builtin").live_grep()]], "telescope live_grep")
    CommandKeymap("<space>fb", [[lua require("telescope.builtin").buffers()]], "telescope buffers")
    CommandKeymap("<space>fh", [[lua require("telescope.builtin").help_tags()]], "telescope help")
  end,
}

return spec
