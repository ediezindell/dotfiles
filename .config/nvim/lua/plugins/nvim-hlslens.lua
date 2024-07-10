-- 検索のヒット件数を表示
return {
  "kevinhwang91/nvim-hlslens",
  config = function()
    require("hlslens").setup()

    -- keymap
    local opts = { noremap = true, silent = true }
    vim.keymap.set(
      "n",
      "n",
      [[<Cmd>set hlsearch<CR><Cmd>execute('normal! ' . v:count1 . 'n')<CR><Cmd>lua require('hlslens').start()<CR>]],
      opts
    )
    vim.keymap.set(
      "n",
      "N",
      [[<Cmd>set hlsearch<CR><Cmd>execute('normal! ' . v:count1 . 'N')<CR><Cmd>lua require('hlslens').start()<CR>]],
      opts
    )
    vim.keymap.set("n", "*", [[*<Cmd>lua require('hlslens').start()<CR>]], opts)
    vim.keymap.set("n", "#", [[#<Cmd>lua require('hlslens').start()<CR>]], opts)
    vim.keymap.set("n", "g*", [[g*<Cmd>lua require('hlslens').start()<CR>]], opts)
    vim.keymap.set("n", "g#", [[g#<Cmd>lua require('hlslens').start()<CR>]], opts)
  end,
  event = "BufEnter",
}
