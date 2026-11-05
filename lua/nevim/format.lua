-- Formatting via conform.nvim. Formatters are provided by the wrapper PATH.
local ok, conform = pcall(require, "conform")
if not ok then
    return
end

conform.setup({
    formatters_by_ft = {
        lua = { "stylua" },
        json = { "prettier" },
        javascript = { "prettier", stop_after_first = true },
        typescript = { "prettier", stop_after_first = true },
        svelte = { "prettierd", "prettier", stop_after_first = true },
        nix = { "nixpkgs_fmt" },
    },
    formatters = {
        stylua = {
            args = { "--indent-type", "Spaces", "--indent-width", "4", "-" },
        },
    },
    format_on_save = function()
        if vim.g.disable_autoformat then
            return
        end
        return { timeout_ms = 500, lsp_fallback = true }
    end,
})
