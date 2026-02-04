
-- Mock vim API for testing if needed, or just run with nvim --headless
local bufnr1 = vim.api.nvim_create_buf(false, true)
local bufnr2 = vim.api.nvim_create_buf(false, true)

-- We can't easily mock LSP clients in a headless run without much boilerplate
-- But we can see how autocmds are registered.

-- Load the autocmds
vim.cmd('source .config/nvim/lua/autocmds.lua')

-- Simulate LspAttach for a client that supports signatureHelp on bufnr1
-- Note: we need to mock vim.lsp.get_client_by_id and client:supports_method

local mock_client = {
  id = 1,
  supports_method = function(self, method)
    return method == "textDocument/signatureHelp"
  end
}

local original_get_client = vim.lsp.get_client_by_id
vim.lsp.get_client_by_id = function(id)
  if id == 1 then return mock_client end
  return original_get_client(id)
end

-- Trigger LspAttach
vim.api.nvim_exec_autocmds("LspAttach", {
  data = { client_id = 1 },
  buffer = bufnr1,
})

-- Check autocmds for CursorMovedI
local autocmds = vim.api.nvim_get_autocmds({ event = "CursorMovedI" })
print("Number of CursorMovedI autocmds: " .. #autocmds)
for i, au in ipairs(autocmds) do
  print(string.format("Autocmd %d: buffer=%s", i, tostring(au.buffer)))
end

-- Now switch to bufnr2 (which has no LSP)
vim.api.nvim_set_current_buf(bufnr2)

-- If we were to trigger CursorMovedI here, it would fire the global autocmd
-- And call vim.lsp.buf.signature_help()
-- Since there are no clients for bufnr2, it should error (or at least try to call it)
