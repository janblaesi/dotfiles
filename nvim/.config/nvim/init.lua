require("config.lazy")

-- Set global options
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = true
vim.opt.number = true
vim.opt.cursorline = true
vim.opt.smarttab = true
vim.opt.guicursor = "a:ver50"

local lualine = require "lualine"
local neo_tree = require "neo-tree"
local lsp = require "lspconfig"
local coq = require "coq"

lualine.setup({
    options = {
        globalstatus = true
    }
})

neo_tree.setup({})

lsp.clangd.setup(coq.lsp_ensure_capabilities())
lsp.lua_ls.setup(coq.lsp_ensure_capabilities())
lsp.gopls.setup(coq.lsp_ensure_capabilities())

