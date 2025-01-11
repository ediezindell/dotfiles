--- HTML / JSXで自動でタグを閉じる
--- NOTE: 動作しない場合は `:TSInstall` する
---@type LazySpec
local spec = {
  "windwp/nvim-ts-autotag",
  opts = {
    opts = {
      enable_close = true, -- Auto close tags
      enable_rename = true, -- Auto rename pairs of tags
      enable_close_on_slash = true, -- Auto close on trailing </
    },
    per_filetype = {
      -- html = {
      --   enable_close = false,
      -- },
    },
  },
  event = "LspAttach",
}

return spec
