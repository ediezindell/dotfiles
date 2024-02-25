vim.cmd("autocmd!")

vim.scriptencoding = "utf-8"

vim.api.nvim_set_var('mapleader', ' ')
vim.api.nvim_set_var('maplocalleader', '_')

vim.loader.enable()
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

local opts = {
  defaults = {
    lazy = true,
  },
  performance = {
    cache = {
      enabled = true,
    },
  },
}
require("lazy").setup("plugins", opts)
