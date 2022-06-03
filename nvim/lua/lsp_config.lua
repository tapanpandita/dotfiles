local lspconfig = require 'lspconfig'
local monzo_lsp = require 'monzo.lsp'
local trouble = require 'trouble'

-- Setup lspconfig.
local opts = { noremap = true, silent = true }

-- Setup trouble for prettier diagnostics
trouble.setup {
    auto_open = true,
    auto_close = true,
    mode = "document_diagnostics",
}
vim.api.nvim_set_keymap("n", "<space>xw", "<cmd>TroubleToggle workspace_diagnostics<CR>", opts)
vim.api.nvim_set_keymap("n", "<space>xd", "<cmd>TroubleToggle document_diagnostics<CR>", opts)
vim.api.nvim_set_keymap("n", "<space>xl", "<cmd>TroubleToggle loclist<CR>", opts)
vim.api.nvim_set_keymap("n", "<space>xq", "<cmd>TroubleToggle quickfix<CR>", opts)
vim.api.nvim_set_keymap("n", "<space>gr", "<cmd>Trouble lsp_references<CR>", opts)

-- autocompletion
local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())

-- Mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
vim.api.nvim_set_keymap('n', '<space>e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
vim.api.nvim_set_keymap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
vim.api.nvim_set_keymap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
--vim.api.nvim_set_keymap('n', '<space>q', '<cmd>lua vim.diagnostic.setloclist()<CR>', opts)
vim.api.nvim_set_keymap('n', '<space>q', '<cmd>lua vim.diagnostic.setloclist()<CR>', opts)

-- function to automatically organize imports
local function org_imports()
    local clients = vim.lsp.buf_get_clients()
    for _, client in pairs(clients) do

        local params = vim.lsp.util.make_range_params(nil, client.offset_encoding)
        params.context = { only = { "source.organizeImports" } }

        local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, 10000)
        for _, res in pairs(result or {}) do
            for _, r in pairs(res.result or {}) do
                if r.edit then
                    vim.lsp.util.apply_workspace_edit(r.edit, client.offset_encoding)
                else
                    vim.lsp.buf.execute_command(r.command)
                end
            end
        end
    end
end

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(_, bufnr)
    -- Mappings.
    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<C-]>', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
    --vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>gr', '<cmd>Trouble lsp_references<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>f', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)
    -- autoformat on save
    vim.api.nvim_create_autocmd("BufWritePre", {
        callback = vim.lsp.buf.formatting_sync,
    })
    -- auto imports on save
    vim.api.nvim_create_autocmd("BufWritePre", {
        callback = org_imports,
    })
    -- show diagnostics loclist post save
    --vim.api.nvim_create_autocmd("BufWritePost", {
    --callback = function ()
    --vim.cmd("Trouble document_diagnostics")
    --end
    --})
end

lspconfig.gopls.setup(monzo_lsp.go_config({ on_attach = on_attach, capabilities = capabilities }))
lspconfig.pyright.setup({ on_attach = on_attach, capabilities = capabilities })
lspconfig.sumneko_lua.setup {
    cmd = { "lua-language-server" };
    on_attach = on_attach,
    capabilities = capabilities,
    settings = {
        Lua = {
            runtime = {
                -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
                version = 'LuaJIT',
                -- Setup your lua path
                path = vim.split(package.path, ';'),
            },
            diagnostics = {
                -- Get the language server to recognize the `vim` global
                globals = { 'vim' },
            },
            workspace = {
                -- Make the server aware of Neovim runtime files
                library = vim.api.nvim_get_runtime_file("", true),
            },
            -- Do not send telemetry data containing a randomized but unique identifier
            telemetry = {
                enable = false,
            },
        },
    },
}

-- suppress error messages from lang servers
vim.notify = function(msg, log_level, _)
    if msg:match("exit code") then
        return
    end
    if log_level == vim.log.levels.ERROR then
        vim.api.nvim_err_writeln(msg)
    else
        vim.api.nvim_echo({ { msg } }, true, {})
    end
end
