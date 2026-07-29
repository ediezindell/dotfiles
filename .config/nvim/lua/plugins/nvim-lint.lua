--- Linting configuration with nvim-lint
local JS_FILETYPES = {
  javascript = true,
  javascriptreact = true,
  typescript = true,
  typescriptreact = true,
}

---@type LazySpec
local spec = {
  "mfussenegger/nvim-lint",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local lint = require("lint")
    local toolchain = require("toolchain")

    lint.linters_by_ft = {
      astro = { "markuplint" },
      html = { "markuplint" },
    }

    local function lint_buffer()
      local bufnr = vim.api.nvim_get_current_buf()
      if not JS_FILETYPES[vim.bo[bufnr].filetype] then
        lint.try_lint()
        return
      end

      local linters = toolchain.linters(bufnr)
      if #linters == 0 then
        return
      end

      lint.try_lint(linters, {
        cwd = toolchain.project_root(bufnr),
        -- nvim-lint 標準の cmd 解決は nvim の cwd 基準なので buffer 位置から解決し直す
        wrap_linter = function(linter)
          linter.cmd = toolchain.bin(bufnr, linter.name) or linter.cmd
          return linter
        end,
      })
    end

    vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
      group = vim.api.nvim_create_augroup("lint", { clear = true }),
      callback = lint_buffer,
    })
  end,
}

return spec
