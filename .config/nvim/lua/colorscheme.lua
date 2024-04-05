vim.api.nvim_create_autocmd({ "ColorScheme", "LspAttach" }, {
  callback = function()
    -- italicにしないようguiを再設定
    local italicGroup = {
      "@keyword.function",
      "@keyword",
      "Keyword",
      "@function",
      "Function",
      "@include",
      "Include",
      "@specialComment",
      "SpecialComment",
      "@comment",
      "Comment",
    }
    for _, group in ipairs(italicGroup) do
      vim.cmd("hi " .. group .. " gui=NONE")
    end
  end,
})

vim.cmd([[colorscheme monokai]])
