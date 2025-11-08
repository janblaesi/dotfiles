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
vim.opt.scrolloff = 15

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

