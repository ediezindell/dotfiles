-- code highlight
---@type LazySpec[]
local spec = {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  lazy = false,
  run = ":TSUpdate",
  config = function()
    require("nvim-treesitter").setup({
      install_dir = vim.fs.joinpath(vim.fn.stdpath("data"), "site"),
    })
    require("nvim-treesitter").install({
      "lua",
      "bash",
      "markdown",
      "typescript",
      "javascript",
      --[[
          この辺に使う言語を列挙していってください。
          @see https://github.com/nvim-treesitter/nvim-treesitter/blob/main/SUPPORTED_LANGUAGES.md
        ]]
    }, {
      force = false,   -- force installation of already installed parsers
      generate = true, -- generate `parser.c` from `grammar.json` or `grammar.js` before compiling.
      max_jobs = 4,    -- limit parallel tasks (useful in combination with {generate} on memory-limited systems).
      summary = false, -- print summary of successful and total operations for multiple languages.
    } --[[@as InstallOptions]])

    vim.api.nvim_create_autocmd({ "FileType" }, {
      pattern = {
        "lua",
        "bash",
        "markdown",
        "typescript",
        "typescriptreact",
        "typescript.tsx",
        "javascript",
        "javascriptreact",
        "javascript.jsx",
      },
      callback = function()
        -- syntax highlighting, provided by Neovim
        vim.treesitter.start()
        -- folds, provided by Neovim
        vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
        -- indentation, provided by nvim-treesitter
        vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end,
    })
  end,
}

return spec
