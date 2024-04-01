vim.api.nvim_create_autocmd({ "ColorScheme" }, {
  callback = function()
    -- italicにしないようguiを再設定
    local italicGroup = {
      "@function",
      "@keyword",
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
