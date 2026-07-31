--- Linting configuration with nvim-lint
local JS_FILETYPES = {
  javascript = true,
  javascriptreact = true,
  typescript = true,
  typescriptreact = true,
}

--- ddu の preview のような実ファイルでない buffer では linter を起動しない。
--- ddu-ui-ff は preview 毎に buftype=nofile の buffer を作り、その window で
--- `doautocmd BufRead` を叩くため、ガードが無いと preview 毎に linter が起動する。
---@param bufnr integer
---@return boolean
local function is_real_file(bufnr)
  return vim.bo[bufnr].buftype == "" and vim.api.nvim_buf_get_name(bufnr) ~= ""
end

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

    ---@param ev { event: string }
    local function lint_buffer(ev)
      local bufnr = vim.api.nvim_get_current_buf()
      if not is_real_file(bufnr) then
        return
      end
      if not JS_FILETYPES[vim.bo[bufnr].filetype] then
        lint.try_lint()
        return
      end

      -- eslint は大きな project だと 1 回数分 CPU を張り付かせるので、
      -- InsertLeave の度には走らせない（JS/TS は読み込み時と保存時のみ）
      if ev.event == "InsertLeave" then
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

    -- BufEnter だと buffer を切り替えるだけで linter が起動するので使わない
    vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost", "InsertLeave" }, {
      group = vim.api.nvim_create_augroup("lint", { clear = true }),
      callback = lint_buffer,
    })
  end,
}

return spec
