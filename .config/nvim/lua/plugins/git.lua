-- gbでblame, goでGitHubを開く
---@type LazySpec
local spec = {
  "dinhhuy258/git.nvim",
  event = "BufRead",
  opts = {
    keymaps = {
      blame = "<space>gb",
      browse = "<space>go",
    },
  },
}

return spec
