-- All non-leader keymaps plus the leader mapping specs. Leader mappings are
-- registered through which-key when available so descriptions show up in the
-- popup; otherwise they fall back to plain vim.keymap.set.

local fzf = require("fzf-lua")
local ui = require("nevim.ui")

local ok_wk, wk = pcall(require, "which-key")

local function add(specs)
    if ok_wk then
        wk.add(specs)
        return
    end
    for _, spec in ipairs(specs) do
        local lhs, rhs = spec[1], spec[2]
        if type(lhs) == "string" and (type(rhs) == "string" or type(rhs) == "function") then
            vim.keymap.set(spec.mode or "n", lhs, rhs, { desc = spec.desc })
        end
    end
end

-- Motion / window navigation
vim.keymap.set("n", "H", "<cmd>bprevious<cr>")
vim.keymap.set("n", "L", "<cmd>bnext<cr>")
vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-j>", "<C-w>j")
vim.keymap.set("n", "<C-k>", "<C-w>k")
vim.keymap.set("n", "<C-l>", "<C-w>l")
vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], { desc = "Exit Terminal Mode" })

add({
    -- flash
    {
        "s",
        function()
            require("flash").jump()
        end,
        desc = "Flash Jump",
        mode = { "n", "x", "o" },
    },
    {
        "S",
        function()
            require("flash").treesitter()
        end,
        desc = "Flash Treesitter",
        mode = { "n", "x", "o" },
    },

    -- git
    { "<leader>g", group = "Git" },
    {
        "<leader>gg",
        function()
            vim.cmd("enew | term lazygit")
        end,
        desc = "LazyGit (full buffer)",
    },
    { "<leader>gf", "<cmd>LazyGit<cr>", desc = "LazyGit (Floating)" },
    { "<leader>gl", "<cmd>LazyGitFilterCurrentFile<cr>", desc = "LazyGit Current File Log" },
    { "<leader>gs", "<cmd>FzfLua git_status<cr>", desc = "Git Status (FZF)" },
    { "<leader>gb", "<cmd>FzfLua git_branches<cr>", desc = "Git Branches" },
    { "<leader>gc", "<cmd>FzfLua git_commits<cr>", desc = "Git Commits" },
    { "<leader>gL", "<cmd>Gitsigns blame_line<cr>", desc = "Git Blame Line" },
    { "<leader>gd", "<cmd>Gitsigns diffthis<cr>", desc = "Git Diff" },
    { "<leader>e", "<cmd>Neotree toggle<cr>", desc = "Toggle Explorer" },

    -- find / search
    { "<leader>f", group = "Files" },
    { "<leader>fc", "<cmd>FzfLua commands<cr>", desc = "Search Command" },
    { "<leader>fk", "<cmd>FzfLua keymaps<cr>", desc = "Search Keymaps" },
    { "<leader>fr", "<cmd>GrugFar<cr>", desc = "Grug Far (search & replace)" },
    {
        "<leader>fR",
        function()
            local buf = vim.api.nvim_get_current_buf()
            local start_line = vim.fn.line("v")
            local end_line = vim.fn.line(".")
            if start_line > end_line then
                start_line, end_line = end_line, start_line
            end
            local lines = vim.api.nvim_buf_get_lines(buf, start_line - 1, end_line, false)
            require("grug-far").open({ vimgrep = table.concat(lines, "\n") })
        end,
        mode = "x",
        desc = "Grug Far (replace selection)",
    },
    { "<leader>fg", "<cmd>FzfLua live_grep<cr>", desc = "Live Grep" },
    { "<leader>fb", "<cmd>FzfLua buffers<cr>", desc = "Search Buffers" },
    {
        "<leader>ff",
        function()
            fzf.files({ fd_opts = "--type f --hidden --exclude .git" })
        end,
        desc = "Find Files",
    },
    { "<leader>fa", "<cmd>FzfLua global<cr>", desc = "FzfLua global command" },
    { "<leader>/", fzf.live_grep, desc = "Grep in Project" },
    { "<leader>b", group = "Buffers" },
    { "<leader>bb", fzf.buffers, desc = "Switch Buffer" },
    { "<leader>bd", "<cmd>bdelete<cr>", desc = "Delete Buffer" },
    { "<leader>p", '"0p', desc = "Paste Last Yank" },
    { "<leader>R", "<cmd>registers<cr>", desc = "Registers" },
    { "<leader>q", group = "Quit" },
    { "<leader>qq", "<cmd>qa<cr>", desc = "Quit All" },

    -- windows
    { "<leader>w", group = "Windows" },
    { "<leader>wv", "<cmd>vsplit<cr>", desc = "Split Vertical" },
    { "<leader>wh", "<cmd>split<cr>", desc = "Split Horizontal" },
    { "<leader>wc", "<cmd>close<cr>", desc = "Close Window" },
    { "<leader>wd", "<cmd>close<cr>", desc = "Close Window" },
    { "<leader>wo", "<cmd>only<cr>", desc = "Close Others" },
    { "<leader>w<Up>", "<cmd>resize +2<cr>", desc = "Increase Height" },
    { "<leader>w<Down>", "<cmd>resize -2<cr>", desc = "Decrease Height" },
    { "<leader>w<Left>", "<cmd>vertical resize -2<cr>", desc = "Decrease Width" },
    { "<leader>w<Right>", "<cmd>vertical resize +2<cr>", desc = "Increase Width" },

    -- diagnostics
    { "<leader>x", group = "Errors and Diagnostics" },
    {
        "<leader>xx",
        function()
            vim.diagnostic.setqflist()
        end,
        desc = "Open Errors in Quickfix",
    },
    { "<leader>xm", "<cmd>tab messages<cr>", desc = "View Message Log (Full Page)" },
    {
        "<leader>xi",
        function()
            print(vim.inspect(vim.inspect_pos()))
        end,
        desc = "Inspect under cursor",
    },
    {
        "<leader>xl",
        function()
            fzf.diagnostics_workspace()
        end,
        desc = "Search All Workspace Errors (FZF)",
    },
    {
        "<leader>xM",
        function()
            local messages = vim.fn.execute("messages")
            vim.cmd("vsplit | enew")
            local buf = vim.api.nvim_get_current_buf()
            vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(messages, "\n"))
            vim.bo[buf].modified = false
            vim.bo[buf].buftype = "nofile"
            vim.cmd("normal! G")
        end,
        desc = "Messages in Split",
    },
    { "<leader>xc", "<cmd>cclose<cr>", desc = "Close Quickfix Window" },
    { "<leader>xt", "<cmd>Trouble diagnostics toggle<cr>", desc = "Trouble (Project)" },
    { "<leader>xT", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Trouble (Buffer)" },
    {
        "<leader>xC",
        function()
            vim.cmd("vsplit " .. vim.fn.stdpath("state") .. "/conform.log")
            vim.bo.filetype = "log"
            vim.cmd("normal! G")
        end,
        desc = "Open Conform Log",
    },
    { "<leader>xI", "<cmd>ConformInfo<cr>", desc = "Conform System Info" },
    {
        "<leader>xX",
        function()
            os.remove(vim.fn.stdpath("state") .. "/conform.log")
            print("Conform log cleared!")
        end,
        desc = "Clear Conform Log",
    },

    -- code
    { "<leader>c", group = "Code" },
    { "<leader>co", "<CMD>Oil<CR>", desc = "Oil (Edit Filesystem)" },
    { "<leader>cu", vim.cmd.UndotreeToggle, desc = "UndoTree (Time Travel)" },
    { "<leader>cc", "<cmd>vsplit | Oil<cr>", desc = "Commander (Dual-Pane Oil)" },

    -- path operations
    { "<leader>cp", group = "path" },
    {
        "<leader>cpp",
        function()
            print(vim.fn.expand("%:p"))
        end,
        desc = "Print Path (Full)",
    },
    {
        "<leader>cpa",
        function()
            local path = vim.fn.expand("%:p")
            vim.fn.setreg("+", path)
            print("Copied: " .. path)
        end,
        desc = "Copy Absolute Path",
    },
    {
        "<leader>cpr",
        function()
            local path = vim.fn.expand("%:.")
            vim.fn.setreg("+", path)
            print("Copied relative: " .. path)
        end,
        desc = "Copy Relative Path",
    },
    { "<leader>cpw", "<cmd>pwd<cr>", desc = "Print Working Directory" },
    {
        "<leader>cf",
        function()
            require("conform").format({ async = true, lsp_fallback = true })
        end,
        desc = "Format Document",
    },
    {
        "<leader>cs",
        function()
            vim.g.autosave_enabled = not vim.g.autosave_enabled
            print("Autosave: " .. (vim.g.autosave_enabled and "ON" or "OFF"))
        end,
        desc = "Toggle Autosave",
    },

    -- ui
    { "<leader>u", group = "UI" },
    { "<leader>uT", ui.theme_picker, desc = "Pick a colorscheme" },
    {
        "<leader>ua",
        function()
            local smear = require("smear_cursor")
            smear.toggle()
            vim.notify("Smear Cursor turned " .. (smear.enabled and "ON" or "OFF"), vim.log.levels.INFO, {
                title = "Smear Cursor",
            })
        end,
        desc = "Toggle Smear Cursor",
    },
    {
        "<leader>uw",
        function()
            vim.opt.wrap = not vim.opt.wrap:get()
            print("Line wrap " .. (vim.opt.wrap:get() and "enabled" or "disabled"))
        end,
        desc = "Toggle Line Wrap",
    },
    {
        "<leader>us",
        function()
            vim.opt.spell = not vim.opt.spell:get()
            print("Spelling: " .. (vim.opt.spell:get() and "ON" or "OFF"))
        end,
        desc = "Toggle Spelling",
    },
    {
        "<leader>un",
        function()
            vim.wo.relativenumber = not vim.wo.relativenumber
            print("Relative Number: " .. (vim.wo.relativenumber and "ON" or "OFF"))
        end,
        desc = "Toggle Relative Numbers",
    },
    {
        "<leader>ud",
        function()
            local enabled = not vim.diagnostic.is_enabled()
            vim.diagnostic.enable(enabled)
            print("Diagnostics: " .. (enabled and "ON" or "OFF"))
        end,
        desc = "Toggle Diagnostics",
    },
    {
        "<leader>ug",
        function()
            require("gitsigns").toggle_signs()
            print("Toggle Git Signs executed")
        end,
        desc = "Toggle Git Signs",
    },
    {
        "<leader>um",
        function()
            vim.cmd("RenderMarkdown toggle")
            print("Markdown Render Toggled")
        end,
        desc = "Toggle Markdown Render",
    },
    {
        "<leader>ut",
        function()
            vim.cmd("Twilight")
            print("Twilight Toggled")
        end,
        desc = "Toggle Twilight",
    },
    {
        "<leader>uf",
        function()
            vim.g.disable_autoformat = not vim.g.disable_autoformat
            print("Autoformat on Save: " .. (vim.g.disable_autoformat and "OFF" or "ON"))
        end,
        desc = "Toggle Format on Save",
    },

    -- terminal
    { "<leader>t", group = "terminal" },
    { "<leader>tt", "<cmd>terminal<cr>i", desc = "Terminal (Full Buffer)" },
    { "<leader>ts", "<cmd>split | terminal<cr>i", desc = "Terminal (Horizontal Split)" },
    { "<leader>tv", "<cmd>vsplit | terminal<cr>i", desc = "Terminal (Vertical Split)" },
})
