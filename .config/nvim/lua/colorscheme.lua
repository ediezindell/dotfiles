vim.cmd([[colorscheme monokai]])

-- italicにしないようhi guiを再設定
local italicTypes = {
  "Function",
  "Keyword",
  "Include",
  "SpecialComment",
  "Comment",
}
for _, type in pairs(italicTypes) do
  vim.cmd("hi " .. type .. " gui=NONE")
end
