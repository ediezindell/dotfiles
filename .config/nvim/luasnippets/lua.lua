local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

return {
  s("spec", {
    t({ "---@type LazySpec", "local spec = {", '  "' }),
    i(1, "user/repo"),
    t({ '",', "}", "", "return spec" }),
  }),
}
