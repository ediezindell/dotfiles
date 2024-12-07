-- 検索のヒット件数を表示
---@type LazySpec
local spec = {
  "kevinhwang91/nvim-hlslens",
  event = "SearchWrapped",
  keys = {
    {
      "n",
      [[<Cmd>set hlsearch<CR><Cmd>execute('normal! ' . v:count1 . 'n')<CR><Cmd>lua require('hlslens').start()<CR>]],
    },
    {
      "N",
      [[<Cmd>set hlsearch<CR><Cmd>execute('normal! ' . v:count1 . 'N')<CR><Cmd>lua require('hlslens').start()<CR>]],
    },
    { "*", [[*<Cmd>lua require('hlslens').start()<CR>]] },
    {
      "#",
      [[#<Cmd>lua require('hlslens').start()<CR>]],
    },
    { "g*", [[g*<Cmd>lua require('hlslens').start()<CR>]] },
    { "g#", [[g#<Cmd>lua require('hlslens').start()<CR>]] },
  },
  config = true,
}

return spec
