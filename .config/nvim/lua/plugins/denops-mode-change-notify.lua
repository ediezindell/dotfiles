---@type LazySpec
local spec = {
  "ediezindell/denops-mode-change-notify.vim",
  dependencies = {
    "vim-denops/denops.vim",
  },
  event = "BufEnter",
  config = function()
    vim.api.nvim_create_autocmd("InsertEnter", {
      pattern = "*",
      callback = function()
        vim.cmd([[call denops#request('denops-mode-change-notify', 'showToast', ["Insert"])]])
      end,
    })
    vim.api.nvim_create_autocmd({
      "InsertLeave",
      -- TODO: 適切なイベント
      -- "VisualLeave",
      -- "CommandLeave"
    }, {
      pattern = "*",
      callback = function()
        vim.cmd([[call denops#request('denops-mode-change-notify', 'showToast', ["Normal"])]])
      end,
    })
  end,
}
return spec
