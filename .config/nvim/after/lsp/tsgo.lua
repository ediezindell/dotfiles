local toolchain = require("toolchain")

--- @typescript/native-preview の tsgo と TypeScript 7 の tsc は同じ LSP を話す。
--- グローバルの tsc は版を特定できず --lsp を持たない可能性があるため候補に入れない。
---@param dir string?
---@return string
local function resolve_cmd(dir)
  if dir then
    for _, name in ipairs({ "tsgo", "tsc" }) do
      local bin = toolchain.local_bin(dir, name)
      if bin then
        return bin
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
