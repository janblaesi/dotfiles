require("config.lazy")

vim.cmd[[colorscheme tokyonight]]

-- Set global options
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = true
vim.opt.number = true
vim.opt.cursorline = true
vim.opt.smarttab = true
vim.opt.guicursor = "a:ver50"

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
lsp.lua_ls.setup(coq.lsp_ensure_capabilities())
lsp.pylsp.setup(coq.lsp_ensure_capabilities())
lsp.sqlls.setup(coq.lsp_ensure_capabilities())
lsp.angularls.setup(coq.lsp_ensure_capabilities())
lsp.ansiblels.setup(coq.lsp_ensure_capabilities())
lsp.cmake.setup(coq.lsp_ensure_capabilities())

