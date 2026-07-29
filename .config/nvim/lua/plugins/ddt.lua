---@type LazySpec
local spec = {
  "Shougo/ddt.vim",
  lazy = false,
  dependencies = {
    "Shougo/ddt-ui-shell",
    "Shougo/ddt-ui-terminal",
  },
  config = function()
    vim.fn["ddt#custom#patch_global"]({
      ui = "terminal",
      uiParams = {
        terminal = {
          nvimServer = "~/.cache/nvim/server.pipe",
          command = { "zsh" },
        },
      },
    })

    -- vim.cmd([[
    --   let g:denops#server#deno_args = [
    --   \   '-q',
    --   \   '-A',
    --   \ ]
    --   let g:denops#server#deno_args += ['--unstable-ffi']
    -- ]])
    -- vim.cmd([[
    --   augroup ddt-shell
    --   autocmd!
    --   autocmd FileType ddt-shell inoremap <buffer> <CR> <Cmd>call ddt#ui#do_action('executeLine')<CR>
    --   augroup END
    -- ]])

    NormalKeymap("<space>t", function()
      vim.cmd([[call ddt#start(#{
      \   name: 'terminal-' .. win_getid(),
      \   ui: 'terminal',
      \ })]])
    end, "open ddt terminal")
  end,
}

return spec
