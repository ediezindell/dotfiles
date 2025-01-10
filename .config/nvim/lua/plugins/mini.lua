---@type LazySpec
local spec = {
  {
    -- アイコン
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
    opts = {},
    event = "BufRead",
  },
  {
    -- クオートや括弧編集
    "echasnovski/mini.surround",
    version = false,
    event = "BufEnter",
    opts = {
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
    },
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
    opts = {
      delay = 10,
    },
    event = "VeryLazy",
  },
  {
    -- 括弧間移動
    "echasnovski/mini.bracketed",
    version = false,
    opts = {
      -- buffer = { suffix = "b", options = {} },
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
    },
    event = "LspAttach",
  },
}

return spec
