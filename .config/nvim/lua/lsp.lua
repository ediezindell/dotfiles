vim.lsp.enable({
  "astro",
  "biome",
  "cssls",
  "denols",
  "gopls",
  "html",
  "intelephense",
  "jsonls",
  "lua_ls",
  "pug",
  "remark_ls",
  "rust-analyzer",
  "stylelint",
  "tailwindcss",
  "tsgo",
  "twiggy_language_server",
  "typos_lsp",
  "vtsls",
})

vim.api.nvim_create_user_command("TSLspSelect", function()
  require("toolchain").reselect_ts()
end, { desc = "TypeScript の LSP を選び直す" })

--- client が止まりきるのを待つ上限
local STOP_TIMEOUT = 3000

--- 引数なしなら現在の buffer に attach 済みの client
---@param names string[]
---@return vim.lsp.Client[]
local function restart_targets(names)
  if #names == 0 then
    return vim.lsp.get_clients({ bufnr = vim.api.nvim_get_current_buf() })
  end
  local clients, seen = {}, {}
  for _, name in ipairs(names) do
    for _, client in ipairs(vim.lsp.get_clients({ name = name })) do
      if not seen[client.id] then
        seen[client.id] = true
        table.insert(clients, client)
      end
    end
  end
  return clients
end

--- client を止め、止まりきってから attach していた buffer で
--- enable の FileType autocmd を再実行する。
--- 止めた直後に起動すると死にかけの client を掴んでしまうので必ず待つ
---@param clients vim.lsp.Client[]
local function restart(clients)
  local bufs, names = {}, {}
  for _, client in ipairs(clients) do
    for bufnr in pairs(client.attached_buffers) do
      bufs[bufnr] = true
    end
    table.insert(names, client.name)
    client:stop(true)
  end

  local timer = assert(vim.uv.new_timer())
  local waited = 0
  timer:start(
    50,
    50,
    vim.schedule_wrap(function()
      waited = waited + 50
      local stopped = vim.iter(clients):all(function(client)
        return client:is_stopped()
      end)
      if not stopped and waited < STOP_TIMEOUT then
        return
      end
      timer:stop()
      timer:close()
      if not stopped then
        vim.notify(("停止を待てなかった: %s"):format(table.concat(names, ", ")), vim.log.levels.WARN)
        return
      end
      for bufnr in pairs(bufs) do
        if vim.api.nvim_buf_is_loaded(bufnr) then
          vim.api.nvim_buf_call(bufnr, function()
            vim.cmd("doautocmd nvim.lsp.enable FileType")
          end)
        end
      end
      vim.notify(("restarted: %s"):format(table.concat(names, ", ")))
    end)
  )
end

vim.api.nvim_create_user_command("LspRestart", function(opts)
  local clients = restart_targets(opts.fargs)
  if #clients == 0 then
    vim.notify("再起動できる LSP client がありません", vim.log.levels.WARN)
    return
  end
  restart(clients)
end, {
  nargs = "*",
  desc = "LSP client を再起動する（引数なしなら現在の buffer のもの）",
  complete = function(arg)
    local names, seen = {}, {}
    for _, client in ipairs(vim.lsp.get_clients()) do
      if not seen[client.name] and client.name:find(arg, 1, true) == 1 then
        seen[client.name] = true
        table.insert(names, client.name)
      end
    end
    table.sort(names)
    return names
  end,
})
