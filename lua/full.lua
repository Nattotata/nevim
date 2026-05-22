local function setup_server(server_name, opts)
    opts = opts or {}

    -- Ensure root_markers exist so the native LSP knows when to attach
    -- Using a standard set of project indicators
    if not opts.root_markers then
        opts.root_markers =
            { "package.json", "tsconfig.json", "jsconfig.json", ".git", "svelte.config.js", "flake.nix" }
    end

    if vim.lsp.config then
        -- 1. Register the config
        vim.lsp.config(server_name, opts)
        -- 2. Enable the server (This replaces lspconfig's .setup() auto-start)
        vim.lsp.enable(server_name)
    else
        -- Fallback for lspconfig plugin if 0.11 features aren't present
        local status, lspconfig = pcall(require, "lspconfig")
        if status then
            lspconfig[server_name].setup(opts)
        end
    end
end
-- 1. TYPESCRIPT & JAVASCRIPT
setup_server("ts_ls")

-- 2. SVELTE
setup_server("svelte")

-- 3. PYTHON
setup_server("pyright")
setup_server("ruff")

-- 4. LUA
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

-- 5. NIX
setup_server("nil_ls")

-- 6. IMAGE PREVIEWS (Optional/Experimental)
-- Since you mentioned image previews, we can initialize image.nvim here.
-- Note: This requires the 'image-nvim' plugin in your nixvim.nix fullPlugins.
local status_image, image = pcall(require, "image")
if status_image then
    image.setup({
        backend = "kitty",
        integrations = {
            markdown = {
                enabled = true,
                clear_in_insert_mode = false,
                download_remote_images = true,
                only_render_image_at_cursor = false,
                filetypes = { "markdown", "vimwiki" },
            },
        },
        max_width = 100,
        max_height = 12,
        window_overlap_clear_enabled = true,
    })
end

-- llm integration
local provider = os.getenv("LLM_PROVIDER") or "google"
local model = os.getenv("LLM_MODEL") or "gemini-2.0-flash"
local endpoint = os.getenv("OPENAI_API_BASE")

-- - model_id: ds-flash
--   model_name: deepseek-v4-flash
--   api_base: "https://api.deepseek.com/v1"
--   api_key_name: deepseek
require("sllm").setup({
    default_model = "ds-flash",
    default_mode = "engineer", -- template
    pick_func = require("fzf-lua").ui_select,
    online_enabled = false,
    window_type = "vertical",
    reset_ctx_each_prompt = false,
    on_start_new_chat = false,
    chain_limit = 200,
    keymaps = {
        complete = false,
    },
    ui = {
        show_usage = true,
    },
})
