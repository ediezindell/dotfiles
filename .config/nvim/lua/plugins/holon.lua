---@type LazySpec
local spec = {
  "sunbluesome/holon.nvim",
  keys = {
    { "<space>zn", "<cmd>Holon<cr>",          desc = "Holon: Notes" },
    { "<space>zg", "<cmd>HolonGrep<cr>",      desc = "Holon: Grep" },
    { "<space>zc", "<cmd>HolonNew<cr>",       desc = "Holon: New note" },
    { "<space>zb", "<cmd>HolonBacklinks<cr>", desc = "Holon: Backlinks" },
    { "<space>zi", "<cmd>HolonIndexes<cr>",   desc = "Holon: Indexes" },
    { "<space>zj", "<cmd>HolonJournal<cr>",   desc = "Holon: Journal" },
    { "<space>zt", "<cmd>HolonTags<cr>",      desc = "Holon: Tags" },
    { "<space>zT", "<cmd>HolonTypes<cr>",     desc = "Holon: Types" },
    { "<space>zf", "<cmd>HolonFollow<cr>",    desc = "Holon: Follow link" },
    { "<space>zd", "<cmd>HolonToday<cr>",     desc = "Holon: Today's journal" },
    { "<space>zG", "<cmd>HolonGtd<cr>",       desc = "Holon: GTD board" },
    { "<space>zl", "<cmd>HolonBrowse<cr>",    desc = "Holon: Link browser" },
    { "<space>zo", "<cmd>HolonOrphans<cr>",   desc = "Holon: Orphan notes" },
  },
  opts = {
    notes_path = vim.fn.expand("~/notes"),
  },
  event = "BufEnter",
}

return spec
