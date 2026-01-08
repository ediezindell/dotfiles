vim.cmd("autocmd!")

vim.scriptencoding = "utf-8"

-- leaderキーを指定
vim.api.nvim_set_var("mapleader", " ")
vim.api.nvim_set_var("maplocalleader", "_")

-- treesitterのパースエラーを無視
---@see https://zenn.dev/kawarimidoll/articles/18ee967072def7
vim.treesitter.start = (function(wrapped)
  return function(bufnr, lang)
    lang = lang or vim.fn.getbufvar(bufnr or "", "&filetype")
    pcall(wrapped, bufnr, lang)
  end
end)(vim.treesitter.start)

-- diagnosticの表示フォーマット変更
local function formatDiagnostics(diagnostic)
  if diagnostic.code ~= nil then
    return string.format("%s (%s: %s)", diagnostic.message, diagnostic.source, diagnostic.code)
  else
    return string.format("%s (%s)", diagnostic.message, diagnostic.source)
  end
end
vim.diagnostic.config({
  severity_sort = true,
  float = {
    border = "rounded",
    format = formatDiagnostics,
  },
  virtual_text = {
    format = formatDiagnostics,
  },
})

vim.filetype.add({
  extension = {
    pcss = "postcss",
  },
})
vim.treesitter.language.register("css", "postcss")

-- lazy.nvimの有効化
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
  ui = {
    icons = vim.g.have_nerd_font and {} or {
      cmd = "⌘",
      config = "🛠",
      event = "📅",
      ft = "📂",
      init = "⚙",
      keys = "🗝",
      plugin = "🔌",
      runtime = "💻",
      require = "🌙",
      source = "📄",
      start = "🚀",
      task = "📌",
      lazy = "💤 ",
    },
  },
}
require("lazy").setup("plugins", opts)

-- require("vim._extui").enable({
--   enable = true,
--   msg = {
--     target = "cmd",
--     timeout = 5000,
--   },
-- })
