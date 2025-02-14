local M = {}

---@see https://github.com/folke/snacks.nvim/blob/main/lua/snacks/picker/transform.lua
---@param item snacks.picker.finder.Item
function M.text_to_file(item)
  item.file = item.file or item.text
end

local p = require("snacks").picker
---@module "lazy"
---@type LazyKeysSpec[]
M.keys = {
  { "<space>pp", p.pickers, desc = "Pickers" },
  { "<space><space>", p.smart, desc = "Smart Find Files" },
  { "<space>pb", p.buffers, desc = "Buffers" },
  { "<space>p/", p.grep, desc = "Grep" },
  { "<space>p:", p.command_history, desc = "Command History" },
  { "<space>e", p.explorer, desc = "File Explorer" },
  { "<space>pf", p.files, desc = "Find Files" },
  { "<space>pgf", p.git_files, desc = "Find Git Files" },
  { "<space>pgb", p.git_branches, desc = "Git Branches" },
  { "<space>pgl", p.git_log, desc = "Git Log" },
  { "<space>pgL", p.git_log_line, desc = "Git Log Line" },
  { "<space>pgs", p.git_status, desc = "Git Status" },
  { "<space>pgS", p.git_stash, desc = "Git Stash" },
  { "<space>pgd", p.git_diff, desc = "Git Diff (Hunks)" },
  { "<space>pl", p.lines, desc = "Buffer Lines" },
  { "<space>pgr", p.grep, desc = "Grep" },
  { "<space>pw", p.grep_word, desc = "Visual selection or word", mode = { "n", "x" } },
  { '<space>p"', p.registers, desc = "Registers" },
  { "<space>pc", p.command_history, desc = "Command History" },
  { "<space>pC", p.commands, desc = "Commands" },
  { "<space>pd", p.diagnostics, desc = "Diagnostics" },
  { "<space>pD", p.diagnostics_buffer, desc = "Buffer Diagnostics" },
  { "<space>pq", p.qflist, desc = "Quickfix List" },
  { "<space>pR", p.resume, desc = "Resume" },
  { "<space>pu", p.undo, desc = "Undo History" },
  { "gt", p.lsp_type_definitions, desc = "Goto Type Definition" },
  {
    "<space>fs",
    function()
      p({
        finder = "proc",
        cmd = "fd",
        args = { ".", vim.fn.expand("%:h"), "-t", "file", "--exclude", vim.fn.expand("%:t") },
        ---@param item snacks.picker.finder.Item
        transform = M.text_to_file,
      })
    end,
    desc = "Find file in same directory",
  },
}

return M
