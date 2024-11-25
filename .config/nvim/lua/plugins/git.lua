-- gbでblame, goでGitHubを開く
---@type LazySpec
local spec = {
  "dinhhuy258/git.nvim",
  event = "VeryLazy",
  config = function()
    require("git").setup({
      keymaps = {
        -- Open blame window
        blame = "<space>gb",
        -- Open file/folder in git repository
        browse = "<space>go",
      },
    })
  end,
}

return spec
