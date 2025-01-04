return {
    "neovim/nvim-lspconfig",
    lazy = false,
    dependencies = {
        { "ms-jpq/coq_nvim", branch = "coq" },
        { "ms-jpq/coq.artifacts", branch = "artifacts" }
    },
    init = function()
        vim.g.coq_settings = {
            auto_start = "shut-up"
        }
    end
}
