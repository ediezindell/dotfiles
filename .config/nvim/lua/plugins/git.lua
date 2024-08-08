-- gbでblame, goでGitHubを開く
---@type LazySpec
local spec = {
  "dinhhuy258/git.nvim",
  event = "VeryLazy",
  config = function()
    require("git").setup({
      keymaps = {
        -- Open blame window
        blame = "<Leader>gb",
        -- Open file/folder in git repository
        browse = "<Leader>go",
      },
    })
  end,
}

return spec
