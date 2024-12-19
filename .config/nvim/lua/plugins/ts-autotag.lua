---@type LazySpec
local spec = {
  "windwp/nvim-ts-autotag",
  opts = {
    opts = {
      enable_close = false, -- Auto close tags
      enable_rename = true, -- Auto rename pairs of tags
      enable_close_on_slash = true, -- Auto close on trailing </
    },
    per_filetype = {
      -- ["html"] = {
      --   enable_close = false
      -- }
    },
  },
  event = { "BufReadPre", "BufNewFile" },
}

return spec
