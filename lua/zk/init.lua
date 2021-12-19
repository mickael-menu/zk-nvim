local zk = {}

local function lsp_execute_command(path, cmd, args, cb)
  zk.lsp_start()
  zk.lsp_client().request("workspace/executeCommand", {
    command = "zk." .. cmd,
    arguments = {
      path or vim.api.nvim_buf_get_name(0),
      args,
    },
  }, function(err, res)
    assert(not err, tostring(err))
    if res then
      cb(res)
    end
  end, 0)
end

function zk.list(path, args, cb)
  lsp_execute_command(path, "list", args, cb)
end

zk.tag = {}

function zk.tag.list(path, args, cb)
  lsp_execute_command(path, "tag.list", args, cb)
end

local config = {
  lsp = {
    auto_attach = {
      enabled = true,
      filetypes = { "markdown" },
      root_dir = require("lspconfig.util").root_pattern(".zk"),
    },
    config = {
      cmd = { "zk", "lsp" },
      name = "zk",
    },
  },
}
local client_id = nil

local function setup_lsp_auto_attach()
  --- NOTE: modified version of code in nvim-lspconfig
  local trigger
  local filetypes = config.lsp.auto_attach.filetypes
  if filetypes then
    trigger = "FileType " .. table.concat(filetypes, ",")
  else
    trigger = "BufReadPost *"
  end
  vim.api.nvim_command(string.format("autocmd %s lua require'zk'._lsp_buf_auto_add(0)", trigger))
end

function zk.setup(user_config)
  config = vim.tbl_deep_extend("force", config, user_config or {})
  if config.lsp.auto_attach.enabled then
    setup_lsp_auto_attach()
  end
end

--- NOTE: No need to manually call this. Automatically called via an |autocmd| if config.lsp.auto_attach is enabled.
function zk._lsp_buf_auto_add(bufnr)
  -- check that the buffer is a file
  if vim.api.nvim_buf_get_option(bufnr, "buftype") == "nofile" then
    return
  end

  -- check that we got a match on the root directory
  local get_root_dir = config.lsp.auto_attach.root_dir
  if get_root_dir then
    if not get_root_dir(vim.api.nvim_buf_get_name(bufnr), bufnr) then
      return
    end
  end

  zk.lsp_buf_add(bufnr)
end

--- Starts an LSP client if necessary
function zk.lsp_start()
  if not client_id then
    client_id = vim.lsp.start_client(config.lsp.config)
  end
end

--- Starts an LSP client if necessary, and attaches the given buffer.
function zk.lsp_buf_add(bufnr)
  bufnr = bufnr or 0
  zk.lsp_start()
  vim.lsp.buf_attach_client(bufnr, client_id)
end

--- Stops the LSP client managed by this plugin
function zk.lsp_stop()
  local client = zk.lsp_client()
  if client then
    client.stop()
  end
  client_id = nil
end

--- Gets the LSP client managed by this plugin, might be nil
function zk.lsp_client()
  return vim.lsp.get_client_by_id(client_id)
end

return zk
