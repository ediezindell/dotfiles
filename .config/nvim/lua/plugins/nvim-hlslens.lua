-- 検索のヒット件数を表示
---@type LazySpec
local spec = {
  "kevinhwang91/nvim-hlslens",
  config = function()
    require("hlslens").setup()

    -- keymap
    NormalKeymap(
      "n",
      [[<Cmd>set hlsearch<CR><Cmd>execute('normal! ' . v:count1 . 'n')<CR><Cmd>lua require('hlslens').start()<CR>]],
      "search next"
    )
    NormalKeymap(
      "N",
      [[<Cmd>set hlsearch<CR><Cmd>execute('normal! ' . v:count1 . 'N')<CR><Cmd>lua require('hlslens').start()<CR>]],
      "search prev"
    )
    NormalKeymap("*", [[*<Cmd>lua require('hlslens').start()<CR>]], "*")
    NormalKeymap("#", [[#<Cmd>lua require('hlslens').start()<CR>]], "#")
    NormalKeymap("g*", [[g*<Cmd>lua require('hlslens').start()<CR>]], "g*")
    NormalKeymap("g#", [[g#<Cmd>lua require('hlslens').start()<CR>]], "g#")
  end,
  event = "SearchWrapped",
}

return spec
