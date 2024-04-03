return {
  "dinhhuy258/git.nvim",
  event = "VimEnter",
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
