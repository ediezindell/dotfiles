-- ファイル検索
---@type LazySpec
local spec = {
  "nvim-telescope/telescope.nvim",
  event = "VimEnter",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
    "nvim-lua/plenary.nvim",
    { "nvim-telescope/telescope-fzf-native.nvim", run = "make" },
    "danielvolchek/tailiscope.nvim",
  },
  keys = {
    { "<space>ff", [[<Cmd>lua require("telescope.builtin").find_files()<CR>]], desc = "telescope find_files" },
    { "<space>fg", [[<Cmd>lua require("telescope.builtin").live_grep()<CR>]], desc = "telescope live_grep" },
    { "<space>fb", [[<Cmd>lua require("telescope.builtin").buffers()<CR>]], desc = "telescope buffers" },
    { "<space>fh", [[<Cmd>lua require("telescope.builtin").help_tags()<CR>]], desc = "telescope help" },
    { "<space>fh", [[<Cmd>lua require("telescope.builtin").help_tags()<CR>]], desc = "telescope help" },
    { "<space>ft", [[<Cmd>Telescope tailiscope<CR>]], desc = "telescope Tailwind CSS" },
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
        -- winblend = 20,
      },
      extensions = {
        tailiscope = {
          default = "base",
          doc_icon = "󱏿  ",
          maps = {
            i = {
              back = "<C-h>",
              open_doc = "<C-o>",
            },
          },
        },
      },
    })

    require("telescope").load_extension("tailiscope")
  end,
}

return spec
