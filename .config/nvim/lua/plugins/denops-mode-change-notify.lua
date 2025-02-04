---@type LazySpec
local spec = {
  "ediezindell/denops-mode-change-notify.vim",
  dependencies = {
    "vim-denops/denops.vim",
  },
  event = "BufEnter",
  config = function()
    vim.api.nvim_create_autocmd({
      "ModeChanged",
    }, {
      pattern = "*:i",
      callback = function()
        vim.cmd([[call denops#request('denops-mode-change-notify', 'showToast', ["Insert"])]])
      end,
    })
    vim.api.nvim_create_autocmd({
      "ModeChanged",
    }, {
      pattern = "*:n",
      callback = function()
        vim.cmd([[call denops#request('denops-mode-change-notify', 'showToast', ["Normal"])]])
      end,
    })
    vim.api.nvim_create_autocmd({
      "ModeChanged",
    }, {
      pattern = "*:v",
      callback = function()
        vim.cmd([[call denops#request('denops-mode-change-notify', 'showToast', ["Visual"])]])
      end,
    })
  end,
}
return spec
