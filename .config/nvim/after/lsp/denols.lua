---@type vim.lsp.Config
return {
  root_dir = function(bufnr, on_dir)
    require("toolchain").activate_ts(bufnr, "denols", on_dir)
  end,
  init_options = {
    lint = true,
    unstable = true,
    suggest = {
      imports = {
        hosts = {
          ["https://deno.land"] = true,
          ["https://cdn.nest.land"] = true,
          ["https://crux.land"] = true,
          ["https://esm.sh"] = true,
        },
      },
    },
  },
}
