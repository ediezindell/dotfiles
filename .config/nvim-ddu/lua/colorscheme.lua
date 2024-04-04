vim.api.nvim_create_autocmd({ "ColorScheme", "LspAttach" }, {
  callback = function()
    -- italicにしないようguiを再設定
    local italicGroup = {
      "@keyword.function",
      "@keyword",
      "@function",
      "@include",
      "@specialComment",
      "@comment",
    }
    for _, group in ipairs(italicGroup) do
      vim.cmd("hi " .. group .. " gui=NONE")
    end
  end,
})

vim.cmd([[colorscheme monokai]])
