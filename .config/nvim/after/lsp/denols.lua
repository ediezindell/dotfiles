---@type vim.lsp.Config
return {
  single_file_support = true,
  on_attach = function(_, buffer)
    vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost" }, {
      buffer = buffer,
      callback = function()
        vim.cmd.DenolsCache()
      end,
    })
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
