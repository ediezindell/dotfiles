--- Formatting configuration with conform.nvim

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

---@type LazySpec
local spec = {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  opts = {
    formatters_by_ft = {
      javascript = function(bufnr)
        if has_biome(bufnr) then
          return { "biome" }
        else
          return { "prettier" }
        end
      end,
      typescript = function(bufnr)
        if has_biome(bufnr) then
          return { "biome" }
        else
          return { "prettier" }
        end
      end,
      javascriptreact = function(bufnr)
        if has_biome(bufnr) then
          return { "biome" }
        else
          return { "prettier" }
        end
      end,
      typescriptreact = function(bufnr)
        if has_biome(bufnr) then
          return { "biome" }
        else
          return { "prettier" }
        end
      end,
      css = function(bufnr)
        if has_biome(bufnr) then
          return { "biome" }
        else
          return { "prettier" }
        end
      end,
      json = function(bufnr)
        if has_biome(bufnr) then
          return { "biome" }
        else
          return { "prettier" }
        end
      end,
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
