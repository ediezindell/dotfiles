---@type LazySpec
local spec = {
  "stevearc/overseer.nvim",
  cmd = {
    "OverseerOpen",
    "OverseerRun",
    "OverseerRestartLast",
  },
  init = function()
    vim.api.nvim_create_user_command("OverseerRestartLast", function()
      local overseer = require("overseer")
      local tasks = overseer.list_tasks({ recent_first = true })
      if vim.tbl_isempty(tasks) then
        vim.notify("No tasks found", vim.log.levels.WARN)
      else
        overseer.run_action(tasks[1], "restart")
      end
    end, {})
  end,
  keys = {
    { "<space>or", "<Cmd>OverseerRun<CR>", desc = "OverseerRun" },
    { "<space>oo", "<Cmd>OverseerOpen<CR>", desc = "OverseerOpen" },
    { "<space>ol", "<Cmd>OverseerRestartLast<CR>", desc = "OverseerRestartLast" },
  },
  opts = {
    -- strategy = {
    --   "toggleterm",
    --   use_shell = false,
    --   close_on_exit = false,
    -- },
  },
}

return spec
