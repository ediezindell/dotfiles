vim.cmd([[colorscheme monokai]])

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
