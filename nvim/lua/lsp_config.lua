local trouble = require 'trouble'
local schemastore = require 'schemastore'

local opts = { noremap = true, silent = true }

-- Trouble: prettier diagnostics
trouble.setup {
    auto_close = true,
    mode = "workspace_diagnostics",
}
vim.keymap.set("n", "<space>xw", "<cmd>TroubleToggle workspace_diagnostics<CR>", opts)
vim.keymap.set("n", "<space>xd", "<cmd>TroubleToggle document_diagnostics<CR>", opts)
vim.keymap.set("n", "<space>xl", "<cmd>TroubleToggle loclist<CR>", opts)
vim.keymap.set("n", "<space>xq", "<cmd>TroubleToggle quickfix<CR>", opts)
vim.keymap.set("n", "<space>gr", "<cmd>Trouble lsp_references<CR>", opts)

-- Treesitter
require 'nvim-treesitter.configs'.setup {
    ensure_installed = { "go", "gomod", "python", "lua", "bash", "css", "dockerfile", "graphql",
        "html", "javascript", "typescript", "tsx", "json", "jsonc", "yaml", "proto",
        "markdown", "markdown_inline", "vim" },
    highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
    },
    incremental_selection = {
        enable = true,
        keymaps = {
            init_selection = "gnn",
            node_incremental = "grn",
            scope_incremental = "grc",
            node_decremental = "grm",
        },
    },
    indent = {
        enable = true
    }
}

-- Mason (prepends installed servers/tools to PATH)
require("mason").setup()

-- Diagnostics UI
vim.diagnostic.config({
    severity_sort = true,
    underline = true,
    update_in_insert = false,
    virtual_text = { spacing = 2, prefix = "●" },
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = "",
            [vim.diagnostic.severity.WARN]  = "",
            [vim.diagnostic.severity.INFO]  = "",
            [vim.diagnostic.severity.HINT]  = "",
        },
    },
    float = { border = "rounded", source = true },
})

-- Rounded borders on all floating windows (hover, signature help, etc.)
vim.o.winborder = "rounded"

-- Diagnostic navigation (global)
vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, opts)
vim.keymap.set('n', '[d', function() vim.diagnostic.jump({ count = -1, float = true }) end, opts)
vim.keymap.set('n', ']d', function() vim.diagnostic.jump({ count = 1, float = true }) end, opts)
vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist, opts)

-- Completion capabilities shared by all servers
local capabilities = require('cmp_nvim_lsp').default_capabilities()

-- Go: organize imports on save (kept from previous config, modernised)
local function go_org_imports(bufnr)
    local clients = vim.lsp.get_clients({ bufnr = bufnr, name = "gopls" })
    if #clients == 0 then return end
    local enc = clients[1].offset_encoding or "utf-16"
    local params = vim.lsp.util.make_range_params(0, enc)
    params.context = { only = { "source.organizeImports" } }
    local result = vim.lsp.buf_request_sync(bufnr, "textDocument/codeAction", params, 3000)
    for _, res in pairs(result or {}) do
        for _, r in pairs(res.result or {}) do
            if r.edit then
                vim.lsp.util.apply_workspace_edit(r.edit, enc)
            end
        end
    end
end

vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = "*.go",
    callback = function(args) go_org_imports(args.buf) end,
})

-- ESLint: apply autofixes (import order, unused vars, etc.) on save. Runs
-- alongside conform/Prettier below; with eslint-config-prettier the two don't
-- overlap (ESLint owns lint fixes, Prettier owns formatting).
local function eslint_fix_all(bufnr)
    local clients = vim.lsp.get_clients({ bufnr = bufnr, name = "eslint" })
    if #clients == 0 then return end
    local enc = clients[1].offset_encoding or "utf-16"
    local params = vim.lsp.util.make_range_params(0, enc)
    params.context = { only = { "source.fixAll.eslint" }, diagnostics = {} }
    local result = vim.lsp.buf_request_sync(bufnr, "textDocument/codeAction", params, 3000)
    for _, res in pairs(result or {}) do
        for _, r in pairs(res.result or {}) do
            if r.edit then
                vim.lsp.util.apply_workspace_edit(r.edit, enc)
            end
        end
    end
end

-- Show diagnostics list after save if there are any
vim.api.nvim_create_autocmd("BufWritePost", {
    callback = function()
        if #vim.diagnostic.get(0) > 0 then
            pcall(vim.cmd, "Trouble document_diagnostics")
        end
    end,
})

-- Per-buffer keymaps and tweaks when a server attaches
vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
        local bufnr = args.buf
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        local bopts = { noremap = true, silent = true, buffer = bufnr }

        vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bopts)
        vim.keymap.set('n', '<C-]>', vim.lsp.buf.definition, bopts)
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, bopts)
        vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bopts)
        vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bopts)
        vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, bopts)
        vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, bopts)
        vim.keymap.set('n', '<space>wl', function()
            print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
        end, bopts)
        vim.keymap.set('n', '<C-\\>', vim.lsp.buf.type_definition, bopts)
        vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, bopts)
        vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, bopts)
        vim.keymap.set('n', '<leader>gr', '<cmd>Telescope lsp_references<CR>', bopts)
        vim.keymap.set('n', '<space>f', function()
            require('conform').format({ lsp_format = 'fallback', async = false })
        end, bopts)

        -- Inlay hints: on by default where supported, toggle with <space>ih
        if client and client:supports_method('textDocument/inlayHint') then
            pcall(vim.lsp.inlay_hint.enable, true, { bufnr = bufnr })
        end
        vim.keymap.set('n', '<space>ih', function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr }), { bufnr = bufnr })
        end, bopts)

        -- Let basedpyright own hover; ruff is just for lint/diagnostics
        if client and client.name == 'ruff' then
            client.server_capabilities.hoverProvider = false
        end

        -- ESLint: fix-all on save for this buffer
        if client and client.name == 'eslint' then
            vim.api.nvim_create_autocmd("BufWritePre", {
                buffer = bufnr,
                callback = function() eslint_fix_all(bufnr) end,
            })
        end
    end,
})

-- Formatting: conform runs Prettier / ruff where configured, falls back to the
-- LSP formatter (e.g. gopls, lua_ls) otherwise. Format on save.
-- Prettier picks up each project's own .prettierrc / .editorconfig; there's no
-- global config, so formatting always matches whatever the repo defines.
require('conform').setup({
    format_on_save = { lsp_format = 'fallback', timeout_ms = 2000 },
    formatters_by_ft = {
        python = { "ruff_organize_imports", "ruff_format" },
        javascript = { "prettier" },
        javascriptreact = { "prettier" },
        typescript = { "prettier" },
        typescriptreact = { "prettier" },
        json = { "prettier" },
        jsonc = { "prettier" },
        css = { "prettier" },
        scss = { "prettier" },
        html = { "prettier" },
        yaml = { "prettier" },
        markdown = { "prettier" },
        -- go, lua, sh, etc. fall back to their LSP formatter
    },
})

-- ---------------------------------------------------------------------------
-- Language servers (native vim.lsp.config / vim.lsp.enable, Neovim 0.11+).
-- nvim-lspconfig still provides each server's sane defaults; we only override.
-- ---------------------------------------------------------------------------

-- Shared defaults for every server
vim.lsp.config('*', { capabilities = capabilities })

-- Go
vim.lsp.config('gopls', {
    cmd = { "gopls", "-remote=auto" },
    -- Root at the nearest service/module rather than the monorepo top, which
    -- would try to ingest far too much code.
    root_markers = { "go.mod", "main.go", "README.md", "LICENSE" },
    settings = {
        gopls = {
            analyses = {
                fieldalignment = true,
                nilness = true,
                shadow = true,
                unusedparams = true,
                unusedwrite = true,
            },
            staticcheck = true,
            expandWorkspaceToModule = false,
            hints = {
                assignVariableTypes = true,
                compositeLiteralFields = true,
                compositeLiteralTypes = true,
                constantValues = true,
                functionTypeParameters = true,
                parameterNames = true,
                rangeVariableTypes = true,
            },
        },
    },
    flags = {
        debounce_text_changes = 150,
    },
})

-- Python: basedpyright for types, ruff for linting
vim.lsp.config('basedpyright', {
    settings = {
        basedpyright = {
            analysis = {
                autoSearchPaths = true,
                useLibraryCodeForTypes = true,
                diagnosticMode = "openFilesOnly",
            },
        },
    },
})
vim.lsp.config('ruff', {})

-- Lua (for editing this config)
vim.lsp.config('lua_ls', {
    settings = {
        Lua = {
            runtime = { version = 'LuaJIT' },
            diagnostics = { globals = { 'vim' } },
            workspace = {
                library = vim.api.nvim_get_runtime_file("", true),
                checkThirdParty = false,
            },
            hint = { enable = true },
            telemetry = { enable = false },
        },
    },
})

-- JSON with SchemaStore schemas (package.json, tsconfig, etc.)
vim.lsp.config('jsonls', {
    settings = {
        json = {
            schemas = schemastore.json.schemas(),
            validate = { enable = true },
        },
    },
})

-- YAML with SchemaStore schemas (GitHub Actions, k8s, etc.)
vim.lsp.config('yamlls', {
    settings = {
        yaml = {
            schemaStore = { enable = false, url = "" },
            schemas = schemastore.yaml.schemas(),
        },
    },
})

vim.lsp.enable({
    "gopls",
    "basedpyright",
    "ruff",
    "vtsls",
    "html",
    "cssls",
    "jsonls",
    "eslint",
    "yamlls",
    "lua_ls",
    "bashls",
})

-- Suppress noisy "exit code" notifications from language servers
vim.notify = function(msg, log_level, _)
    if type(msg) == "string" and msg:match("exit code") then
        return
    end
    if log_level == vim.log.levels.ERROR then
        vim.api.nvim_err_writeln(msg)
    else
        vim.api.nvim_echo({ { msg } }, true, {})
    end
end
