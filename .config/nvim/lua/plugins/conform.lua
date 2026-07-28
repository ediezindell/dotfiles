--- Formatting configuration with conform.nvim

local function has_deno(bufnr)
  return vim.fs.root(bufnr, { "deno.json", "deno.jsonc", "denops" }) ~= nil
end

local function has_biome(bufnr)
  local has = vim.fs.root(bufnr, { "biome.json", "biome.jsonc" }) ~= nil
  if not has then
    local pkg_path = vim.fs.root(bufnr, { "package.json" })
    if pkg_path then
      local f = io.open(pkg_path .. "/package.json", "r")
      if f then
        local content = f:read("*a")
        f:close()
        if content:match('"@?biomejs/biome"') or content:match('"biome"') then
          has = true
        end
      end
    end
  end
  return has
end

local function select_formatter(bufnr)
  if has_deno(bufnr) then
    return { "deno_fmt" }
  elseif has_biome(bufnr) then
    return { "biome" }
  else
    return { "prettier" }
  end
end

---@type LazySpec
local spec = {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  opts = {
    formatters_by_ft = {
      javascript = select_formatter,
      typescript = select_formatter,
      javascriptreact = select_formatter,
      typescriptreact = select_formatter,
      css = function(bufnr)
        if has_biome(bufnr) then
          return { "biome" }
        else
          return { "prettier" }
        end
      end,
      json = select_formatter,
      html = { "prettier" },
      markdown = { "prettier" },
      astro = { "prettier" },
      lua = { "stylua" },
    },
    default_format_opts = {
      lsp_format = "fallback",
    },
  },
}

return spec
