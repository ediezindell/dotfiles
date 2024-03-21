-- file tree

return {
  "nvim-tree/nvim-tree.lua",
  requires = {
    "nvim-tree/nvim-web-devicons",
    "nvim-telescope/telescope.nvim",
  },
  -- event = "VimEnter",
  config = function()
    require("nvim-tree").setup({
      sort_by = "case_sensitive",
      sort = {
        folders_first = true,
      },
      update_focused_file = {
        enable = true,
        update_cwd = true,
      },
      view = {
        adaptive_size = true,
        -- number = true,
        --
        -- float = {
        --   enable = true,
        -- },
      },
      renderer = {
        group_empty = true,
        highlight_git = true,
        highlight_modified = "icon",
        -- highlight_opened_files = "icon",
        highlight_opened_files = "name",
        icons = {
          glyphs = {
            git = {
              unstaged = "!",
              renamed = "»",
              untracked = "?",
              deleted = "✘",
              staged = "✓",
              unmerged = "",
              ignored = "◌",
            },
          },
        },
      },
      diagnostics = {
        enable = true,
        show_on_dirs = true,
      },
      actions = {
        expand_all = {
          max_folder_discovery = 100,
          exclude = { ".git", "target", "build", "node_modules" },
        },
      },
      on_attach = require("actions.nvim-tree-actions").on_attach,
      -- on_attach = 'default'
    })

    -- コマンド設定
    vim.cmd([[
      :hi      NvimTreeExecFile    guifg=#ffa0a0
      :hi      NvimTreeSpecialFile guifg=#ff80ff gui=underline
      :hi      NvimTreeSymlink     guifg=Yellow  gui=italic
      :hi link NvimTreeImageFile   Title
    ]])

    vim.api.nvim_set_var("loaded_netrw", 1)
    vim.api.nvim_set_var("loaded_netrwPlugin", 1)
    vim.api.nvim_set_var("termguicolors", true)

    -- keymap
    local opts = { noremap = true, silent = true }
    vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", opts)
  end,
}
