-- emmet parserの実装
---@type LazySpec
local spec = {
  -- アイコン
  {
    "echasnovski/mini.icons",
    opts = {
      filetype = {
        typescript = {
          hl = "MiniIconsCyan",
        },
        lua = {
          hl = "MiniIconsCyan",
        },
      },
    },
  },
  {
    -- git差分表示
    "echasnovski/mini.diff",
    version = false,
    config = function()
      if not vim.tbl_contains({ "oil" }, vim.bo.filetype) then
        require("mini.diff").setup({})
      end
    end,
    event = "BufEnter",
  },
  {
    -- クオートや括弧編集
    "echasnovski/mini.surround",
    version = false,
    event = "BufEnter",
    config = function()
      require("mini.surround").setup({
        mappings = {
          add = "sa", -- Add surrounding in Normal and Visual modes
          delete = "sd", -- Delete surrounding
          find = "sf", -- Find surrounding (to the right)
          find_left = "sF", -- Find surrounding (to the left)
          highlight = "", -- Highlight surrounding
          replace = "sr", -- Replace surrounding

          suffix_last = "", -- Suffix to search with "prev" method
          suffix_next = "", -- Suffix to search with "next" method
        },
        n_lines = 100,
      })
    end,
  },
  {
    -- Option + j/k で行ごと移動
    "echasnovski/mini.move",
    version = false,
    config = true,
    event = "BufEnter",
  },
  {
    -- gSで引数を1行にまとめたり複数行に展開したり
    "echasnovski/mini.splitjoin",
    version = false,
    config = true,
    event = "BufEnter",
  },
  {
    -- カーソル上の単語ハイライト
    "echasnovski/mini.cursorword",
    version = false,
    config = function()
      require("mini.cursorword").setup({
        delay = 10,
      })
      vim.api.nvim_create_autocmd("BufEnter", {
        pattern = "*",
        callback = function()
          -- local options = { fg = "lightgray", bg = "darkcyan" }
          -- vim.api.nvim_set_hl(0, "MiniCursorword", options)
          -- vim.api.nvim_set_hl(0, "MiniCursorwordCurrent", options)
        end,
      })
    end,
    event = "VeryLazy",
  },
  {
    -- 括弧間移動
    "echasnovski/mini.bracketed",
    version = false,
    config = function()
      require("mini.bracketed").setup({
        buffer = { suffix = "b", options = {} },
        -- comment = { suffix = "c", options = {} },
        -- conflict = { suffix = "x", options = {} },
        -- diagnostic = { suffix = "d", options = {} },
        -- file = { suffix = "f", options = {} },
        indent = { suffix = "i", options = {} },
        -- jump = { suffix = "j", options = {} },
        -- location = { suffix = "l", options = {} },
        -- oldfile = { suffix = "o", options = {} },
        -- quickfix = { suffix = "q", options = {} },
        -- treesitter = { suffix = "t", options = {} },
        -- undo = { suffix = "u", options = {} },
        -- window = { suffix = "w", options = {} },
        -- yank = { suffix = "y", options = {} },
      })
    end,
    event = "LspAttach",
  },
  -- {
  --   -- fの強化
  --   "echasnovski/mini.jump",
  --   version = false,
  --   config = true,
  --   event = "BufEnter",
  -- },
  -- {
  --   -- start page
  --   "echasnovski/mini.starter",
  --   version = false,
  --   config = true,
  --   event = "VimEnter",
  -- },
  -- {
  --   -- autoclose
  --   "echasnovski/mini.pairs",
  --   version = false,
  --   config = true,
  --   event = "InsertEnter",
  -- },
  -- {
  --   -- コメント
  --   "echasnovski/mini.comment",
  --   version = false,
  --   config = true,
  --   event = "BufEnter",
  -- },
  -- {
  --   -- 補完
  --   "echasnovski/mini.completion",
  --   version = false,
  --   config = true,
  --   event = "InsertEnter",
  -- },
  -- {
  --   -- Neovimアクションのアニメーション
  --   "echasnovski/mini.animate",
  --   version = false,
  --   config = true,
  --   event = "VimEnter",
  -- },
  -- {
  --   -- インデント表示
  --   "echasnovski/mini.indentscope",
  --   version = false,
  --   config = function()
  --     require("mini.indentscope").setup({
  --       -- Draw options
  --       draw = {
  --         -- Delay (in ms) between event and start of drawing scope indicator
  --         delay = 10,
  --
  --         -- Symbol priority. Increase to display on top of more symbols.
  --         priority = 2,
  --       },
  --
  --       -- Module mappings. Use `''` (empty string) to disable one.
  --       mappings = {
  --         -- Textobjects
  --         object_scope = "ii",
  --         object_scope_with_border = "ai",
  --
  --         -- Motions (jump to respective border line; if not present - body line)
  --         goto_top = "[i",
  --         goto_bottom = "]i",
  --       },
  --
  --       -- Options which control scope computation
  --       options = {
  --         -- Type of scope's border: which line(s) with smaller indent to
  --         -- categorize as border. Can be one of: 'both', 'top', 'bottom', 'none'.
  --         border = "both",
  --
  --         -- Whether to use cursor column when computing reference indent.
  --         -- Useful to see incremental scopes with horizontal cursor movements.
  --         indent_at_cursor = true,
  --
  --         -- Whether to first check input line to be a border of adjacent scope.
  --         -- Use it if you want to place cursor on function header to get scope of
  --         -- its body.
  --         try_as_border = false,
  --       },
  --
  --       -- Which character to use for drawing scope indicator
  --       symbol = "╎",
  --     })
  --     vim.api.nvim_create_autocmd({ "BufEnter" }, {
  --       callback = function()
  --         local ignore_filetypes = {
  --           "",
  --           "aerial",
  --           "help",
  --           "lazy",
  --           -- "NvimTree",
  --           "notify",
  --         }
  --         if vim.tbl_contains(ignore_filetypes, vim.bo.filetype) then
  --           vim.b.miniindentscope_disable = true
  --         end
  --       end,
  --     })
  --   end,
  --   event = "BufEnter",
  -- },
}

return spec
