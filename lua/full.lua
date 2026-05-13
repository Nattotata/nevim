local function setup_server(server_name, opts)
	-- Check for the new 0.11+ Core API first
	if vim.lsp.config then
		vim.lsp.config(server_name, opts or {})
	else
		-- Fallback for the old nvim-lspconfig plugin
		require("lspconfig")[server_name].setup(opts or {})
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

-- treesitter is syntax highlighting

-- local status_ts, _ = pcall(require, "nvim-treesitter")
-- if status_ts then
-- 	-- Recent nvim-treesitter doesn't need .setup() for basic highlighting
-- 	-- if the parsers are managed by Nix. But if you want to be sure:
-- 	local configs = require("nvim-treesitter.configs")
-- 	if type(configs.setup) == "function" then
-- 		configs.setup({
-- 			highlight = { enable = true, additional_vim_regex_highlighting = false },
-- 			indent = { enable = true },
-- 		})
-- 	end
-- end
