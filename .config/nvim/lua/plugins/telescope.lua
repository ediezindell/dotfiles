-- ファイル検索
return {
  "nvim-telescope/telescope.nvim",
  tag = "0.1.5",
  -- event = "VimEnter",
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
            ["<C-h>"] = "which_key",
            ["<esc>"] = actions.close,
          },
          n = { ["q"] = actions.close },
        },
        layout_strategy = "vertical",
        winblend = 20,
      },
    })
    -- telescope.load_extension("fzf")

    local builtin = require("telescope.builtin")

    -- keymap
    vim.keymap.set("n", "<leader>ff", builtin.find_files)
    vim.keymap.set("n", "<leader>fg", builtin.live_grep)
    vim.keymap.set("n", "<leader>fb", builtin.buffers)
    vim.keymap.set("n", "<leader>fh", builtin.help_tags)
  end,
}
