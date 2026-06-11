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
setup_server("ts_ls")
setup_server("svelte")
setup_server("pyright")
setup_server("ruff")
setup_server("tailwindcss", {
    capabilities = capabilities,
    root_dir = function(fname)
        -- Strictly anchor the server to the root of your project
        return vim.fs.root(fname, { "tailwind.config.js", "tailwind.config.cjs", "package.json" })
    end,
    settings = {
        tailwindcss = {
            -- Explicitly limit directory scanning to prevent the server from escaping your repository
            files = {
                exclude = { "**/.git/**", "**/node_modules/**", "**/result/**", "**/dist/**" },
            },
        },
    },
})
setup_server("cssls", {
    capabilities = capabilities,
    settings = {
        css = {
            validate = true,
            lint = {
                unknownAtRules = "ignore", -- Keeps Tailwind directives from triggering false syntax errors
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
local model = os.getenv("LLM_MODEL") or "gemini-2.5-flash"
local endpoint = os.getenv("OPENAI_API_BASE")

-- - model_id: ds-flash
--   model_name: deepseek-v4-flash
--   api_base: "https://api.deepseek.com/v1"
--   api_key_name: deepseek
local sllm_status, sllm = pcall(require, "sllm")
if sllm_status then
    sllm.setup({
        -- Target the custom block below as your starting mode
        llm_cmd = "/etc/profiles/per-user/xof/bin/llm",
        default_model = "gemini-3.5-flash",
        default_mode = "engineer",
        pick_func = require("fzf-lua").ui_select,
        scroll_to_bottom = false,
        reset_ctx_each_prompt = false,
        on_start_new_chat = false,
        chain_limit = 200,
        keymaps = {
            complete = false,
        },
        ui = {
            show_usage = true,
        },
        modes = {
            ["inline-gemini-flash"] = {
                model = "gemini-2.5-flash",
                window_type = "vertical",
                system_prompt = "You are an expert software engineer. Provide exact code corrections and precise technical documentation. Do not include conversational pleasantries, introductory fluff, or meta-commentary. Prioritize conciseness.",
                model_options = {
                    google_search = "1",
                },
            },
            ["inline-gemini-pro"] = {
                model = "gemini-2.5-pro",
                window_type = "vertical",
                system_prompt = "You are an elite software architect and logic engineer. Analyze architectural tradeoffs, fix deep bugs, and optimize logic layers cleanly.",
                model_options = {
                    google_search = "1",
                },
            },
        },
        -- Prompt parameters must reside within defined modes
        -- modes = {
        --     engineer = {
        --         model = "gemini-2.5-flash",
        --         window_type = "vertical",
        --         system_prompt = "You are an expert software engineer. Provide exact code corrections and precise technical documentation. Do not include conversational pleasantries, introductory fluff, or meta-commentary. Prioritize conciseness.",
        --         model_options = {
        --             google_search = "1",
        --         },
        --     },
        -- },
    })
    vim.keymap.set("n", "<leader>sd", "<cmd>LLMAddDiagnostics<cr>", { desc = "Append LSP diagnostics" })
    vim.keymap.set("n", "<leader>sr", "<cmd>LLMReset<cr>", { desc = "Clear history" })
end
