local options = {
  ambiwidth = "double",
  cursorline = true,
  tabstop = 2,
	shiftwidth = 2,
  number = true,
  expandtab = true,
  numberwidth = 4,
  incsearch = true,
  shell = "zsh",
  -- relativenumber = true,
  splitright = true,
  termguicolors = true,
  clipboard = "unnamedplus",
  syntax = "enable",
  termguicolors = true,
  winblend = 0,
  pumblend = 0,
}

for k, v in pairs(options) do
  vim.opt[k] = v
end

vim.cmd("set whichwrap+=<,>,[,],h,l")

