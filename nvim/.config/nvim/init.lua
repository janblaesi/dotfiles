-- Set leader key to ' '
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Load Lazy.nvim
require("config.lazy")
require("config.lazy_autoupdate")

vim.cmd [[colorscheme tokyonight]]

-- Set global options
vim.opt.number = true
vim.opt.mouse = 'a'

-- Hide mode because it is already shown in the status line
vim.opt.showmode = false

-- Tab settings: 4 spaces wide, use spaces instead of tabs
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = true
vim.opt.smarttab = true

-- Enable cursor line, set cursor to vertical bar, keep 10 lines above and below the cursor
vim.opt.cursorline = true
vim.opt.guicursor = "a:ver50"
vim.opt.scrolloff = 10

-- Ignore case when searching Unless one or more capital letters are in the search term.
vim.opt.ignorecase = true
vim.opt.smartcase = true

-----------------
-- Keybindings --
-----------------

-- When in normal mode, clear highlights when pressing <Esc>
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- A more sane keymap to exit the terminal
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-------------
-- Plugins --
-------------

require("lualine").setup({
    options = {
        globalstatus = true,
        theme = "tokyonight-storm"
    }
})

require("barbecue").setup({
    options = {
        theme = "tokyonight-storm"
    }
})

require("neo-tree").setup({})

require("mason").setup()
require("mason-lspconfig").setup()

local lsp = require "lspconfig"
local coq = require "coq"
lsp.clangd.setup(coq.lsp_ensure_capabilities())
lsp.gopls.setup(coq.lsp_ensure_capabilities())
lsp.lua_ls.setup(coq.lsp_ensure_capabilities({
    on_init = function(client)
        if client.workspace_folders then
            local path = client.workspace_folders[1].name
            if vim.loop.fs_stat(path..'/.luarc.json') or vim.loop.fs_stat(path..'/.luarc.jsonc') then
                return
            end
        end

        client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
            runtime = {
                version = 'LuaJIT'
            },
            workspace = {
                checkThirdParty = false,
                library = {
                    vim.env.VIMRUNTIME
                }
            }
        })
    end,
    settings = {
        Lua = {}
    }
}))
lsp.pylsp.setup(coq.lsp_ensure_capabilities())
lsp.sqlls.setup(coq.lsp_ensure_capabilities())
lsp.angularls.setup(coq.lsp_ensure_capabilities())
lsp.ansiblels.setup(coq.lsp_ensure_capabilities())
lsp.cmake.setup(coq.lsp_ensure_capabilities())

