-- Language servers. Binaries are provided by the wrapper PATH, so nvim-lspconfig
-- only needs to know how to configure/attach each one.

local M = {}

local default_root_markers = {
    "package.json",
    "tsconfig.json",
    "jsconfig.json",
    ".git",
    "svelte.config.js",
    "flake.nix",
}

local function setup_server(name, opts)
    opts = opts or {}

    -- Let the native config discover a project root unless one is given.
    if not opts.root_dir and not opts.root_markers then
        opts.root_markers = default_root_markers
    end

    if vim.lsp.config then
        vim.lsp.config(name, opts)
        vim.lsp.enable(name)
    else
        -- Fallback for older Neovim without the built-in config API.
        local ok, lspconfig = pcall(require, "lspconfig")
        if ok then
            lspconfig[name].setup(opts)
        end
    end
end

function M.setup()
    setup_server("ts_ls")
    setup_server("svelte")
    setup_server("pyright")
    setup_server("ruff")
    setup_server("tailwindcss", {
        root_dir = function(fname)
            return vim.fs.root(fname, { "tailwind.config.js", "tailwind.config.cjs", "package.json" })
        end,
        settings = {
            tailwindcss = {
                files = {
                    exclude = { "**/.git/**", "**/node_modules/**", "**/result/**", "**/dist/**" },
                },
            },
        },
    })
    setup_server("cssls", {
        settings = {
            css = {
                validate = true,
                lint = {
                    unknownAtRules = "ignore", -- keeps Tailwind directives quiet
                },
            },
        },
    })
    setup_server("lua_ls", {
        settings = {
            Lua = {
                diagnostics = { globals = { "vim" } },
                workspace = {
                    library = vim.api.nvim_get_runtime_file("", true),
                    checkThirdParty = false,
                },
            },
        },
    })
    setup_server("nil_ls")
end

return M
