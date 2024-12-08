---@type LazySpec
local spec = {
  "vim-fall/fall.vim",
  dependencies = { "vim-denops/denops.vim" },
  lazy = false,
  keys = {
    { "<space>f/", "<Cmd>Fall line<CR>", desc = "fall (line)" },
    { "<space>ff", "<Cmd>Fall file<CR>", desc = "fall (file)" },
    { "<space>fp", "<Cmd>Fall file ~/git/dotfiles/.config/nvim/lua/plugins/<CR>", desc = "fall (file)" },
    { "<space>fd", "<Cmd>Fall oldfile<CR>", desc = "fall (file)" },
    { "<space>fb", "<Cmd>Fall buffer<CR>", desc = "fall (buffer)" },
    { "<space>fg", "<Cmd>Fall rg<CR>", desc = "fall (ripgrep)" },
    { "<space>fx", "<Cmd>Fall quickfix<CR>", desc = "fall (quickfix)" },
  },
  init = function()
    vim.cmd([[
      function! s:init() abort
        cnoremap <silent><nowait> <Up> <Plug>(fall-list-prev)
        cnoremap <silent><nowait> <Down> <Plug>(fall-list-next)
        cnoremap <silent><nowait> <C-u> <Plug>(fall-list-prev:scroll)
        cnoremap <silent><nowait> <C-d> <Plug>(fall-list-next:scroll)
        cnoremap <silent><nowait> <k> <Plug>(fall-preview-prev)
        cnoremap <silent><nowait> <j> <Plug>(fall-preview-next)
        cnoremap <silent><nowait> <h> <Plug>(fall-preview-left)
        cnoremap <silent><nowait> <l> <Plug>(fall-preview-right)
        cnoremap <silent><nowait> <S-Up> <Plug>(fall-preview-prev:scroll)
        cnoremap <silent><nowait> <S-Down> <Plug>(fall-preview-next:scroll)
        cnoremap <silent><nowait> <S-Left> <Plug>(fall-preview-left:scroll)
        cnoremap <silent><nowait> <S-Right> <Plug>(fall-preview-right:scroll)
      endfunction
      augroup my_fall
        autocmd!
        autocmd User FallPickerEnter:* call s:init()
        autocmd User FallPreviewRendered:* setlocal nonumber norelativenumber
      augroup END
    ]])
  end,
}

return spec
