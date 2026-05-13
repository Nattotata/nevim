-- SET LEADER KEY
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- VISUALIZE WHITESPACE
vim.opt.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

-- CLIPBOARD & YANK
vim.opt.clipboard = "unnamedplus"
vim.keymap.set("x", "p", [["_dP]])
vim.keymap.set({ "n", "v" }, "y", '"+y')

-- BASIC SETTINGS
vim.opt.number = true
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.termguicolors = true
vim.opt.hidden = true
vim.opt.wrap = false

-- AUTO-SAVE LOGIC
vim.g.autosave_enabled = true

local autosave_group = vim.api.nvim_create_augroup("AutosaveGroup", { clear = true })

vim.api.nvim_create_autocmd({ "InsertLeave", "TextChanged" }, {
    group = autosave_group,
    callback = function()
        if vim.g.autosave_enabled and vim.bo.modified and vim.fn.empty(vim.fn.expand("%:t")) ~= 1 then
            vim.cmd("silent! write")
        end
    end,
})

-- WINDOW MANAGEMENT (Standard Neovim)
vim.keymap.set("n", "<leader>wv", "<cmd>vsplit<cr>", { desc = "Split Vertical" })
vim.keymap.set("n", "<leader>wh", "<cmd>split<cr>", { desc = "Split Horizontal" })
vim.keymap.set("n", "<leader>wd", "<C-w>c", { desc = "Close Window" })

-- THEME
-- Wrap in pcall in case gruvbox isn't loaded yet
pcall(vim.cmd, "colorscheme gruvbox")

-- LUALINE (Missing from your previous file)
local status_lualine, lualine = pcall(require, "lualine")
if status_lualine then
    lualine.setup({ options = { theme = "gruvbox" } })
end

-- NEO-TREE
local status_nt, nt = pcall(require, "neo-tree")
if status_nt then
    nt.setup({
        close_if_last_window = true,
        filesystem = { filtered_items = { visible = true, hide_dotfiles = false } },
    })
end

-- NAVIGATION
vim.keymap.set("n", "H", "<cmd>bprevious<cr>")
vim.keymap.set("n", "L", "<cmd>bnext<cr>")
vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-j>", "<C-w>j")
vim.keymap.set("n", "<C-k>", "<C-w>k")
vim.keymap.set("n", "<C-l>", "<C-w>l")

-- Open all errors in a persistent, scrollable bottom window
vim.keymap.set("n", "<leader>xx", function()
    vim.diagnostic.setqflist()
end, { desc = "Open Errors in Quickfix List" })
-- WHICH-KEY & FZF
local status_wk, wk = pcall(require, "which-key")
local status_fzf, fzf = pcall(require, "fzf-lua")

if status_wk then
    wk.setup({
        preset = "modern",
        win = {
            border = "rounded",
            -- We'll use col/row or simply let it default to bottom
            -- width can be a decimal (0.9 = 90%)
            width = 0.9,
            height = { min = 4, max = 25 },
            -- This is the crucial part for your transparency
            wo = {
                winblend = 15,
            },
        },
        layout = {
            spacing = 6,
            align = "center",
        },
    })
end

if status_wk and status_fzf then
    wk.add({
        -- git
        { "<leader>g", group = "Git" },
        { "<leader>gg", "<cmd>LazyGit<cr>", desc = "LazyGit (Floating)" },
        { "<leader>gl", "<cmd>LazyGitFilterCurrentFile<cr>", desc = "LazyGit Current File Log" },
        { "<leader>gs", "<cmd>FzfLua git_status<cr>", desc = "Git Status (FZF)" },
        { "<leader>gb", "<cmd>FzfLua git_branches<cr>", desc = "Git Branches" },
        { "<leader>gc", "<cmd>FzfLua git_commits<cr>", desc = "Git Commits" },
        { "<leader>gl", "<cmd>Gitsigns blame_line<cr>", desc = "Git Blame Line" },
        { "<leader>gd", "<cmd>Gitsigns diffthis<cr>", desc = "Git Diff" },
        { "<leader>e", "<cmd>Neotree toggle<cr>", desc = "Toggle Explorer" },
        -- Find/Search Group (FZF)
        { "<leader>f", group = "Files" },
        { "<leader>fk", "<cmd>FzfLua keymaps<cr>", desc = "Search Keymaps" },
        { "<leader>fg", "<cmd>FzfLua live_grep<cr>", desc = "Live Grep" },
        { "<leader>fb", "<cmd>FzfLua buffers<cr>", desc = "Search Buffers" },
        {
            "<leader>ff",
            function()
                fzf.files({ fd_opts = "--type f --hidden --exclude .git" })
            end,
            desc = "Find Files",
        },
        { "<leader>/", fzf.live_grep, desc = "Grep in Project" },
        { "<leader>b", group = "Buffers" },
        { "<leader>bb", fzf.buffers, desc = "Switch Buffer" },
        { "<leader>bd", "<cmd>bdelete<cr>", desc = "Delete Buffer" },
        { "<leader>p", '"0p', desc = "Paste Last Yank" },
        { "<leader>R", "<cmd>registers<cr>", desc = "Registers" },
        { "<leader>q", group = "Quit" },
        { "<leader>qq", "<cmd>qa<cr>", desc = "Quit All" },
        -- Window Management Group
        { "<leader>w", group = "Windows" },
        { "<leader>wv", "<cmd>vsplit<cr>", desc = "Split Vertical" },
        { "<leader>wh", "<cmd>split<cr>", desc = "Split Horizontal" },
        { "<leader>wc", "<cmd>close<cr>", desc = "Close Window" },
        { "<leader>wo", "<cmd>only<cr>", desc = "Close Others" },
        -- Resizing (using arrows or hjkl)
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
            "<leader>xl",
            function()
                fzf.diagnostics_workspace()
            end,
            desc = "Search All Workspace Errors (FZF)",
        },
        {
            "<leader>xM",
            function()
                -- This captures the output of :messages and puts it in a new buffer
                local messages = vim.fn.execute("messages")
                vim.cmd("vsplit | enew")
                local buf = vim.api.nvim_get_current_buf()
                vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(messages, "\n"))
                vim.bo[buf].modified = false
                vim.bo[buf].buftype = "nofile"
                vim.cmd("normal! G") -- Scroll to the latest messages
            end,
            desc = "Messages in Split",
        },
        { "<leader>xc", "<cmd>cclose<cr>", desc = "Close Quickfix Window" },
        { "<leader>xt", "<cmd>Trouble diagnostics toggle<cr>", desc = "Trouble (Project)" },
        { "<leader>xT", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Trouble (Buffer)" },
        {
            "<leader>xc",
            function()
                -- This opens the conform log in a new vertical split
                vim.cmd("vsplit " .. vim.fn.stdpath("state") .. "/conform.log")
                -- Set the filetype to 'log' for basic highlighting if available
                vim.bo.filetype = "log"
                -- Scroll to the bottom of the log immediately
                vim.cmd("normal! G")
            end,
            desc = "Open Conform Log",
        },
        -- Adding a shortcut for the UI info window too
        { "<leader>xi", "<cmd>ConformInfo<cr>", desc = "Conform System Info" },
        {
            "<leader>xX",
            function()
                local log_path = vim.fn.stdpath("state") .. "/conform.log"
                os.remove(log_path)
                print("Conform log cleared!")
            end,
            desc = "Clear Conform Log",
        },
        -- code
        { "<leader>c", group = "Code" },
        { "<leader>co", "<CMD>Oil<CR>", desc = "Oil (Edit Filesystem)" },
        {
            "<leader>cf",
            function()
                require("cnform").format({ async = true, lsp_fallback = true })
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
        -- UI group
        { "<leader>u", group = "UI" },
        {
            "<leader>uw",
            function()
                vim.opt.wrap = not vim.opt.wrap:get()
                if vim.opt.wrap:get() then
                    print("Line wrap enabled")
                else
                    print("Line wrap disabled")
                end
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

        -- Relative Numbers
        {
            "<leader>un",
            function()
                vim.wo.relativenumber = not vim.wo.relativenumber
                print("Relative Number: " .. (vim.wo.relativenumber and "ON" or "OFF"))
            end,
            desc = "Toggle Relative Numbers",
        },

        -- Diagnostics
        {
            "<leader>ud",
            function()
                local enabled = not vim.diagnostic.is_enabled()
                vim.diagnostic.enable(enabled)
                print("Diagnostics: " .. (enabled and "ON" or "OFF"))
            end,
            desc = "Toggle Diagnostics",
        },

        -- Git Signs (Using gitsigns internal state)
        {
            "<leader>ug",
            function()
                require("gitsigns").toggle_signs()
                -- GitSigns doesn't return state easily, but we can notify the trigger
                print("Toggle Git Signs executed")
            end,
            desc = "Toggle Git Signs",
        },

        -- Markdown Rendering
        {
            "<leader>um",
            function()
                vim.cmd("RenderMarkdown toggle")
                print("Markdown Render Toggled")
            end,
            desc = "Toggle Markdown Render",
        },

        -- Twilight (Dimming)
        {
            "<leader>ut",
            function()
                vim.cmd("Twilight")
                -- Check if global variable or buffer variable exists for Twilight state
                print("Twilight Toggled")
            end,
            desc = "Toggle Twilight",
        },

        -- Format on Save (Note: logic is inverted based on your variable name)
        {
            "<leader>uf",
            function()
                vim.g.disable_autoformat = not vim.g.disable_autoformat
                print("Autoformat on Save: " .. (vim.g.disable_autoformat and "OFF" or "ON"))
            end,
            desc = "Toggle Format on Save",
        },

        { "<leader>t", group = "terminal" },
        { "<leader>tt", "<cmd>terminal<cr>i", desc = "Terminal (Full Buffer)" },
        { "<leader>ts", "<cmd>split | terminal<cr>i", desc = "Terminal (Horizontal Split)" },
        { "<leader>tv", "<cmd>vsplit | terminal<cr>i", desc = "Terminal (Vertical Split)" },
    })
end

-- AUTO-COMMANDS
-- Don't continue comments on new lines
vim.api.nvim_create_autocmd("FileType", {
    pattern = "*",
    callback = function()
        vim.opt_local.formatoptions:remove({ "r", "o" })
    end,
})

local status_icons, icons = pcall(require, "mini.icons")
if status_icons then
    icons.setup()
    icons.mock_nvim_web_devicons()
end

-- Formatting Setup (Conform)
local status_conform, conform = pcall(require, "conform")
if status_conform then
    conform.setup({
        formatters_by_ft = {
            lua = { "stylua" },
            javascript = { "prettierd", "prettier", stop_after_first = true },
            typescript = { "prettierd", "prettier", stop_after_first = true },
            svelte = { "prettierd", "prettier", stop_after_first = true },
            nix = { "nixpkgs_fmt" },
        },
        formatters = {
            stylua = {
                args = { "--indent-type", "Spaces", "--indent-width", "4", "-" },
            },
        },
        format_on_save = function(bufnr)
            if vim.g.disable_autoformat then
                return
            end
            return { timeout_ms = 500, lsp_fallback = true }
        end,
    })
end

-- BUFFERLINE (The Top Bar)
local status_bl, bl = pcall(require, "bufferline")
if status_bl then
    bl.setup({
        options = {
            separator_style = "slant",
            offsets = { { filetype = "neo-tree", text = "File Explorer", text_align = "left" } },
        },
    })
end

-- SURROUND
pcall(require("nvim-surround").setup, { aliases = { ["b"] = "**" } })

-- FLASH (In your Which-Key block)
wk.add({
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
})

local logos = {
    {
        [[             |       :     . |]],
        [[             | '  :      '   |]],
        [[             |  .  | nevim | |]],
        [[   .--._ _...:.._ _.--. ,  ' |]],
        [[  (  ,  `        `  ,  )   . |]],
        [[   '-/              \-'  |   |]],
        [[     |  o   /\   o  |       :|]],
        [[     \     _\/_     / :  '   |]],
        [[     /'._   ^^   _.;___      |]],
        [[   /`    `""""""`      `\=   |]],
        [[ /`                     /=  .|]],
        [[;             '--,-----'=    |]],
        [[|                 `\  |    . |]],
        [[\                   \___ :   |]],
        [[/'.                     `\=  |]],
        [[\_/`--......_            /=  |]],
        [[            |`-.        /= : |]],
        [[            | : `-.__ /` .   |]],
        [[            |jgs .   ` |    '|]],
        [[            |  .  : `   . |  |]],
    },
    {
        [[\|/    \|/]],
        [[  \    /]],
        [[   \_/  ___   ___]],
        [[   o o-'   '''   ']],
        [[    O -.         |\]],
        [[        | |'''| |]],
        [[  nevim  ||   | |]],
        [[         ||    ||]],
        [[         "     "]],
    },
    {
        [[  _      _]],
        [[ : `.--.' ;              _....,_]],
        [[ .'      `.      _..--'"'       `-._]],
        [[:          :_.-'"                  .`.]],
        [[:  6    6  :                     :  '.;]],
        [[:          :    nevim             `..';]],
        [[`: .----. :'                          ;]],
        [[  `._Y _.'               '           ;]],
        [[    'U'      .'          `.         ;]],
        [[       `:   ;`-..___       `.     .'`.]],
        [[jgs    _:   :  :    ```"''"'``.    `.  `.]],
        [[     .'     ;..'            .'       `.'`]],
        [[    `.......'              `........-'`]],
    },
    {
        [[              ____...---...___]],
        [[___.....---"""        .       ""--..____]],
        [[     .                  .            .]],
        [[ . nevim       _.--._       /|]],
        [[        .    .'()..()`.    / /]],
        [[            ( `-.__.-' )  ( (    .]],
        [[   .         \        /    \ \]],
        [[       .      \      /      ) )        .]],
        [[            .' -.__.- `.-.-'_.']],
        [[ .        .'  /-____-\  `.-'       .]],
        [[          \  /-.____.-\  /-.]],
        [[           \ \`-.__.-'/ /\|\|           .]],
        [[          .'  `.    .'  `.]],
        [[          |/\/\|    |/\/\|]],
        [[jro]],
    },
    {
        [[                 /eeeeeeeeeee\     nevim   ]],
        [[   /RRRRRRRRRR\ /eeeeeeeeeeeee\ /RRRRRRRRRR\ ]],
        [[  /RRRRRRRRRRRR\|eeeeeeeeeeeee|/RRRRRRRRRRRR\ ]],
        [[ /RRRRRRRRRRRRRR +++++++++++++ RRRRRRRRRRRRRR\ ]],
        [[|RRRRRRRRRRRRRR ############### RRRRRRRRRRRRRR| ]],
        [[|RRRRRRRRRRRRR ######### ####### RRRRRRRRRRRRR| ]],
        [[ \RRRRRRRRRRR ######### ######### RRRRRRRRRR/ ]],
        [[   |RRRRRRRRR ########## ######## RRRRRRRR| ]],
        [[  |RRRRRRRRRR ################### RRRRRRRRR| ]],
        [[               ######     ###### ]],
        [[               #####       ##### ]],
        [[               #nnn#       #nnn# ]],
    },
}
math.randomseed(os.clock() * 1000000)
local picked_logo = logos[math.random(#logos)]
local status_alpha, alpha = pcall(require, "alpha")
if status_alpha then
    local dashboard = require("alpha.themes.dashboard")
    local variant = os.getenv("NEVIM_VARIANT") or "desktop"
    local color_variant = variant == "pi" and " [ RASPBERRY PI ] " or " [ DESKTOP ] "
    table.insert(picked_logo, "")
    table.insert(picked_logo, "      " .. color_variant)
    dashboard.section.header.val = picked_logo
    dashboard.section.buttons.val = {
        dashboard.button("f", "  Find file", ":FzfLua files<CR>"),
        dashboard.button("n", "  New file", ":ene <BAR> startinsert <CR>"),
        dashboard.button("g", "󰊢  LazyGit", ":LazyGit<CR>"),
        dashboard.button("q", "󰩈  Quit", ":qa<CR>"),
    }
    alpha.setup(dashboard.opts)
end

-- DISABLE ALL ITALICS
local function disable_italics()
    local highlights = vim.api.nvim_get_hl(0, {})
    for name, hl in pairs(highlights) do
        if hl.italic then
            hl.italic = false
            vim.api.nvim_set_hl(0, name, hl)
        end
    end
end

disable_italics()

-- Also run it whenever a colorscheme is loaded (just in case)
vim.api.nvim_create_autocmd("ColorScheme", {
    callback = disable_italics,
})

-- terminal qol

-- Escape terminal mode easily with Esc (instead of the default Ctrl-\ Ctrl-N)
vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], { desc = "Exit Terminal Mode" })

-- oil and trouble setup
local status_oil, oil = pcall(require, "oil")
if status_oil then
    oil.setup()
end

local status_trouble, trouble = pcall(require, "trouble")
if status_trouble then
    trouble.setup()
end
