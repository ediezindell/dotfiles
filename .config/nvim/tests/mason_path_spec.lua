package.path = vim.fs.dirname(debug.getinfo(1, "S").source:sub(2)) .. "/?.lua;" .. package.path
local h = require("helper")
local mason_path = require("mason-path")

do
  local original = vim.env.PATH
  vim.env.PATH = "/usr/bin:/bin"

  mason_path.prepend()

  h.eq(
    vim.fn.stdpath("data") .. "/mason/bin:/usr/bin:/bin",
    vim.env.PATH,
    "mason の bin ディレクトリが PATH の先頭に追加される"
  )
  vim.env.PATH = original
end

do
  local original = vim.env.PATH
  vim.env.PATH = "/opt/tools/bin:/sbin"

  mason_path.prepend()

  h.eq(
    vim.fn.stdpath("data") .. "/mason/bin:/opt/tools/bin:/sbin",
    vim.env.PATH,
    "元の PATH は置き換えられずすべて残る"
  )
  vim.env.PATH = original
end

do
  local original = vim.env.PATH
  vim.env.PATH = "/usr/bin"

  mason_path.prepend()
  mason_path.prepend()

  h.eq(
    vim.fn.stdpath("data") .. "/mason/bin:/usr/bin",
    vim.env.PATH,
    "二重に呼んでも同じディレクトリが重複して積まれない"
  )
  vim.env.PATH = original
end

h.finish()
