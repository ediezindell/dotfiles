-- file tree
vim.cmd([[
    :hi      NvimTreeExecFile    guifg=#ffa0a0
    :hi      NvimTreeSpecialFile guifg=#ff80ff gui=underline
    :hi      NvimTreeSymlink     guifg=Yellow  gui=italic
    :hi link NvimTreeImageFile   Title
]])

vim.api.nvim_set_var('loaded_netrw', 1)
vim.api.nvim_set_var('loaded_netrwPlugin', 1)
vim.api.nvim_set_var('termguicolors', true)

return {
  'nvim-tree/nvim-tree.lua',
  requires = {
    'nvim-tree/nvim-web-devicons',
  },
  event = "VimEnter",
  config = function()
    require('nvim-tree').setup({
      sort_by = 'case_sensitive',
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
        highlight_opened_files = "icon",
      },
      diagnostics = {
        enable = true,
        show_on_dirs = true,
      },
      filters = {
        dotfiles = true,
      },
    })
  end,
}
