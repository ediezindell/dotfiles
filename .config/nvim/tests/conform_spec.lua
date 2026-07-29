package.path = vim.fs.dirname(debug.getinfo(1, "S").source:sub(2)) .. "/?.lua;" .. package.path
local h = require("helper")
local by_ft = require("plugins.conform").opts.formatters_by_ft

do
  local root = h.fixture({ files = { ["biome.json"] = "{}", ["package.json"] = "{}", ["a.ts"] = "" } })
  local bufnr = h.buf(root .. "/a.ts")
  vim.bo[bufnr].filetype = "typescript"
  h.eq("function", type(by_ft.typescript), "typescript は関数で選択する")
  h.eq({ "biome" }, by_ft.typescript(bufnr), "biome プロジェクトは biome")
end

do
  local root = h.fixture({ files = { ["deno.json"] = "{}", ["a.tsx"] = "" } })
  local bufnr = h.buf(root .. "/a.tsx")
  vim.bo[bufnr].filetype = "typescriptreact"
  h.eq({ "deno_fmt" }, by_ft.typescriptreact(bufnr), "deno プロジェクトは deno_fmt")
end

do
  local root = h.fixture({
    files = { ["package.json"] = "{}", ["a.css"] = "" },
    exe = { "node_modules/.bin/prettier" },
  })
  local bufnr = h.buf(root .. "/a.css")
  vim.bo[bufnr].filetype = "css"
  h.eq({ "prettier" }, by_ft.css(bufnr), "css も同じ選択ロジックを通る")
end

do
  h.eq({ "stylua" }, by_ft.lua, "lua は stylua 固定")
  h.eq({ "prettier" }, by_ft.markdown, "markdown は prettier 固定")
end

h.finish()
