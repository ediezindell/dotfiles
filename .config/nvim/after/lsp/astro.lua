---@type vim.lsp.Config
return {
  cmd = { "astro-ls", "--stdio" },
  filetypes = { "astro" },
  root_markers = { "package.json", "tsconfig.json", "jsconfig.json", ".git" },
  init_options = {
    typescript = {},
  },
  before_init = function(_, config)
    local function get_typescript_server_path(root_dir)
      local project_root = root_dir or vim.fn.getcwd()
      local local_tsdk = project_root .. "/node_modules/typescript/lib"
      if vim.fn.isdirectory(local_tsdk) == 1 then
        return local_tsdk
      end
      return vim.fn.exepath("typescript-language-server")
    end
    
    if config.init_options and config.init_options.typescript and not config.init_options.typescript.tsdk then
      config.init_options.typescript.tsdk = get_typescript_server_path(config.root_dir)
    end
  end,
}
