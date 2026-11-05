-- Svelte needs a filetype + parser registration.
vim.filetype.add({ extension = { svelte = "svelte" } })
vim.treesitter.language.register("svelte", "svelte")

-- nvim-treesitter packaged by nixpkgs may be either the master or main branch.
-- Try the legacy config API first, then the new module, and never hard-fail.
local ok_configs, configs = pcall(require, "nvim-treesitter.configs")
if ok_configs then
    configs.setup({
        highlight = { enable = true },
        indent = { enable = true },
    })
else
    local ok_ts, ts = pcall(require, "nvim-treesitter")
    if ok_ts and type(ts.setup) == "function" then
        ts.setup({
            highlight = { enable = true },
            indent = { enable = true },
        })
    end
end

-- Attach treesitter highlighting whenever a parser is available. Parsers are
-- bundled via nvim-treesitter.withPlugins in the Nix package.
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile", "FileType" }, {
    callback = function()
        local buf = vim.api.nvim_get_current_buf()
        local lang = vim.treesitter.language.get_lang(vim.bo.filetype)
        if lang then
            pcall(vim.treesitter.start, buf, lang)
        end
    end,
})
