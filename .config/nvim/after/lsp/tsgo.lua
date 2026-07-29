local toolchain = require("toolchain")

--- @typescript/native-preview の tsgo と TypeScript 7 の tsc は同じ LSP を話す。
--- TypeScript 7 未満の tsc には --lsp が無いため、typescript の major が 7 以上の時だけ候補に入れる。
--- グローバルの tsc は版を特定できないため候補に入れない。
---@param dir string?
---@return string
local function resolve_cmd(dir)
  if dir then
    local tsgo_bin = toolchain.local_bin(dir, "tsgo")
    if tsgo_bin then
      return tsgo_bin
    end
    if (toolchain.dep_major(dir, "typescript") or 0) >= 7 then
      local tsc_bin = toolchain.local_bin(dir, "tsc")
      if tsc_bin then
        return tsc_bin
      end
    end
  end
  return "tsgo"
end

---@type vim.lsp.Config
return {
  cmd = function(dispatchers, config)
    local cmd = resolve_cmd((config or {}).root_dir)
    return vim.lsp.rpc.start({ cmd, "--lsp", "--stdio" }, dispatchers)
  end,
  filetypes = {
    "javascript",
    "javascriptreact",
    "javascript.jsx",
    "typescript",
    "typescriptreact",
    "typescript.tsx",
  },
  root_dir = function(bufnr, on_dir)
    toolchain.activate_ts(bufnr, "tsgo", on_dir)
  end,
}
