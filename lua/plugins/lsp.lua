-- LSP stack: mason + mason-lspconfig (v2 API) + lspconfig + fidget + outline.
-- Phase 3a -- servers only. Completion (blink.cmp), formatting (conform),
-- linting (nvim-lint) ship in 3b. Per-language plugins (metals, rustaceanvim)
-- ship in Phase 4.
--
-- Big-file invariant: lua/config/autocmds.lua already detaches LSP via
-- vim.lsp.stop_client(client_id, true) for vim.b.big_file == true buffers.
-- No additional guard needed here.
--
-- Server set is documented in docs/DESIGN.md (cheeky-bubbling-hamming.md) §4.
local SERVERS = {
  lua_ls = {
    settings = {
      Lua = {
        runtime = { version = "LuaJIT" },
        diagnostics = { globals = { "vim" } },
        workspace = {
          library = vim.api.nvim_get_runtime_file("", true),
          checkThirdParty = false,
        },
        telemetry = { enable = false },
        format = { enable = false },
      },
    },
  },
  gopls = {
    settings = {
      gopls = {
        hints = {
          assignVariableTypes = true,
          compositeLiteralFields = true,
          compositeLiteralTypes = true,
          constantValues = true,
          functionTypeParameters = true,
          parameterNames = true,
          rangeVariableTypes = true,
        },
        analyses = { unusedparams = true, shadow = true },
        staticcheck = true,
      },
    },
  },
  yamlls = {
    -- Excludes helm filetype (Phase 4 ftplugin will set bo.filetype = "helm").
    -- Punch-list #8 forward-compat.
    filetypes = { "yaml" },
    settings = {
      yaml = {
        keyOrdering = false,
        format = { enable = false },
      },
    },
  },
  jsonls = {
    -- TODO 3b: wire b0o/schemastore.nvim for live schema catalog.
  },
  bashls = {},
  terraformls = {},
  dockerls = {},
  taplo = {},
}

local INLAY_HINT_FILETYPES = {
  go = true,
  lua = true,
  rust = true,
  scala = true,
}

local function on_attach(client, bufnr)
  -- Punch-list #5: conform.nvim is the single formatter (3b). Disable LSP
  -- formatting now so users do not get LSP-formatted writes between 3a and 3b.
  client.server_capabilities.documentFormattingProvider = false
  client.server_capabilities.documentRangeFormattingProvider = false

  if INLAY_HINT_FILETYPES[vim.bo[bufnr].filetype]
    and client:supports_method("textDocument/inlayHint") then
    pcall(vim.lsp.inlay_hint.enable, true, { bufnr = bufnr })
  end

  if client:supports_method("textDocument/documentHighlight") then
    local hl_group = vim.api.nvim_create_augroup("LspDocHl_" .. bufnr, { clear = true })
    vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
      group = hl_group,
      buffer = bufnr,
      callback = function() pcall(vim.lsp.buf.document_highlight) end,
    })
    vim.api.nvim_create_autocmd("CursorMoved", {
      group = hl_group,
      buffer = bufnr,
      callback = function() pcall(vim.lsp.buf.clear_references) end,
    })
  end

  local map = function(mode, lhs, rhs, desc)
    vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc, silent = true })
  end
  map("n", "gd", vim.lsp.buf.definition, "LSP: definition")
  map("n", "gD", vim.lsp.buf.declaration, "LSP: declaration")
  map("n", "gr", vim.lsp.buf.references, "LSP: references")
  map("n", "gi", vim.lsp.buf.implementation, "LSP: implementation")
  map("n", "K", vim.lsp.buf.hover, "LSP: hover")
  map({ "n", "v" }, "<leader>la", vim.lsp.buf.code_action, "LSP: code action")
  map("n", "<leader>lR", vim.lsp.buf.rename, "LSP: rename")
  map("n", "<leader>ld", vim.lsp.buf.definition, "LSP: definition")
  map("n", "<leader>lr", vim.lsp.buf.references, "LSP: references")
  map("n", "<leader>lh", function()
    local enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr })
    vim.lsp.inlay_hint.enable(not enabled, { bufnr = bufnr })
  end, "LSP: toggle inlay hints")
end

return {
  {
    "mason-org/mason.nvim",
    cmd = { "Mason", "MasonInstall", "MasonUpdate", "MasonLog", "MasonUninstall" },
    build = ":MasonUpdate",
    opts = {
      ui = { border = "rounded", icons = { package_installed = "v", package_pending = "*", package_uninstalled = "x" } },
    },
  },
  {
    "mason-org/mason-lspconfig.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "mason-org/mason.nvim",
      "neovim/nvim-lspconfig",
    },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = vim.tbl_keys(SERVERS),
        automatic_installation = false,
      })

      local lsp_attach_group = vim.api.nvim_create_augroup("UserLspAttach", { clear = true })
      vim.api.nvim_create_autocmd("LspAttach", {
        group = lsp_attach_group,
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if client then on_attach(client, args.buf) end
        end,
      })

      -- v2 API: vim.lsp.config + vim.lsp.enable. Not setup_handlers (legacy).
      for name, cfg in pairs(SERVERS) do
        vim.lsp.config(name, cfg)
        vim.lsp.enable(name)
      end
    end,
  },
  {
    "neovim/nvim-lspconfig",
    lazy = true,
  },
  {
    "j-hui/fidget.nvim",
    event = "LspAttach",
    opts = {
      progress = {
        display = { progress_icon = { pattern = "dots", period = 1 } },
      },
      notification = {
        window = { winblend = 0, border = "rounded" },
      },
    },
  },
  {
    "hedyhli/outline.nvim",
    cmd = { "Outline", "OutlineOpen" },
    keys = {
      { "<leader>o", "<cmd>Outline<CR>", desc = "Toggle outline" },
    },
    opts = {
      outline_window = { width = 25, relative_width = false },
      symbol_folding = { autofold_depth = 2 },
    },
  },
}
