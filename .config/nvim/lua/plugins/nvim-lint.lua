--- Linting configuration with nvim-lint
---@type LazySpec
local spec = {
  "mfussenegger/nvim-lint",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local lint = require("lint")

    -- Define standard linters for other filetypes
    lint.linters_by_ft = {
      astro = { "markuplint" },
      html = { "markuplint" },
    }

    local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })
    vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
      group = lint_augroup,
      callback = function()
        local bufnr = vim.api.nvim_get_current_buf()
        local ft = vim.bo[bufnr].filetype

        -- Check if it is a JavaScript/TypeScript file
        if ft == "javascript" or ft == "typescript" or ft == "javascriptreact" or ft == "typescriptreact" then
          local has_deno = vim.fs.root(bufnr, { "deno.json", "deno.jsonc", "denops" }) ~= nil
          local has_biome = vim.fs.root(bufnr, { "biome.json", "biome.jsonc" }) ~= nil
          local has_oxlint = vim.fs.root(bufnr, { "oxlint.json", ".oxlintrc" }) ~= nil

          if not has_deno and (not has_biome or not has_oxlint) then
            local pkg_path = vim.fs.root(bufnr, { "package.json" })
            if pkg_path then
              local f = io.open(pkg_path .. "/package.json", "r")
              if f then
                local content = f:read("*a")
                f:close()
                if not has_biome and (content:match('"@?biomejs/biome"') or content:match('"biome"')) then
                  has_biome = true
                end
                if not has_oxlint and (content:match('"oxlint"') or content:match('"eslint-plugin-oxlint"')) then
                  has_oxlint = true
                end
              end
            end
          end

          if has_deno then
            lint.try_lint("deno")
          elseif has_biome then
            lint.try_lint("biomejs")
          else
            local active_linters = {}
            if has_oxlint then
              table.insert(active_linters, "oxlint")
            end
            table.insert(active_linters, "eslint")
            lint.try_lint(active_linters)
          end
        else
          -- Run default linters defined in linters_by_ft
          lint.try_lint()
        end
      end,
    })
  end,
}

return spec
