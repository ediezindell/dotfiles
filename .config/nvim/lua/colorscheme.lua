vim.api.nvim_create_autocmd({ "ColorScheme", "LspAttach" }, {
  callback = function()
    -- italicにしないようguiを再設定
    local italicGroup = {
      "@comment",
      "@function",
      "@function.macro",
      "@include",
      "@keyword",
      "@keyword.function",
      "@specialComment",
      "@text.reference",
      "Comment",
      "Function",
      "Include",
      "Keyword",
      "SpecialComment",
    }
    for _, group in ipairs(italicGroup) do
      vim.cmd("hi " .. group .. " gui=NONE")
    end
  end,
})

vim.cmd([[colorscheme monokai]])
