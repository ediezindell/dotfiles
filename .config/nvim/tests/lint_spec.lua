package.path = vim.fs.dirname(debug.getinfo(1, "S").source:sub(2)) .. "/?.lua;" .. package.path
local h = require("helper")

vim.opt.runtimepath:append(vim.fn.stdpath("data") .. "/lazy/nvim-lint")

local lint = require("lint")
local spec = require("plugins.nvim-lint")

-- try_lint を差し替えて、呼び出し回数と引数だけを観測する
local calls, last = 0, nil
lint.try_lint = function(names, opts)
  calls = calls + 1
  last = { names = names, opts = opts }
end

spec.config()

---@param bufnr integer
---@param ft string
---@return { calls: integer, names?: string[], opts?: table }
local function run(bufnr, ft)
  vim.bo[bufnr].filetype = ft
  vim.api.nvim_set_current_buf(bufnr)
  calls, last = 0, nil
  vim.api.nvim_exec_autocmds("BufWritePost", { buffer = bufnr })
  return { calls = calls, names = last and last.names, opts = last and last.opts }
end

do
  local root = h.fixture({
    files = { ["package.json"] = [[{"devDependencies":{"oxlint":"^1.0.0","eslint":"^9.0.0"}}]], ["a.ts"] = "" },
    exe = { "node_modules/.bin/oxlint", "node_modules/.bin/eslint" },
  })
  local result = run(h.buf(root .. "/a.ts"), "typescript")
  h.eq({ "oxlint", "eslint" }, result.names, "oxlint と eslint を両方実行する")
  h.eq(root, result.opts.cwd, "project root を cwd にする")
  h.eq(
    root .. "/node_modules/.bin/eslint",
    result.opts.wrap_linter({ name = "eslint", cmd = "eslint" }).cmd,
    "eslint は local install を使う"
  )
  h.eq(
    root .. "/node_modules/.bin/oxlint",
    result.opts.wrap_linter({ name = "oxlint", cmd = "oxlint" }).cmd,
    "oxlint は local install を使う"
  )
end

do
  local root = h.fixture({ files = { ["deno.json"] = "{}", ["a.ts"] = "" } })
  h.eq({ calls = 0 }, run(h.buf(root .. "/a.ts"), "typescript"), "deno プロジェクトでは try_lint を呼ばない")
end

do
  local root = h.fixture({ files = { ["biome.json"] = "{}", ["package.json"] = "{}", ["a.ts"] = "" } })
  h.eq({ calls = 0 }, run(h.buf(root .. "/a.ts"), "typescript"), "biome プロジェクトでは try_lint を呼ばない")
end

do
  local root = h.fixture({ files = { ["package.json"] = "{}", ["a.ts"] = "" } })
  h.eq({ calls = 0 }, run(h.buf(root .. "/a.ts"), "typescript"), "検出ゼロなら try_lint を呼ばない")
end

do
  local root = h.fixture({ files = { ["a.html"] = "" } })
  h.eq({ calls = 1 }, run(h.buf(root .. "/a.html"), "html"), "JS/TS 以外は引数なしで try_lint を呼ぶ")
  h.eq({ "markuplint" }, lint.linters_by_ft.html, "html は markuplint")
end

h.finish()
