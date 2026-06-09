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
vim.api.nvim_create_autocmd({ "InsertLeave", "FocusLost" }, {
    group = autosave_group,
    callback = function()
        if vim.g.autosave_enabled and vim.bo.modified and vim.fn.empty(vim.fn.expand("%:t")) ~= 1 then
            -- We check if we're in a regular file to avoid saving terminal/special buffers
            if vim.bo.buftype == "" then
                vim.cmd("silent! write")
            end
        end
    end,
})

-- Redirect terminal output to a scratch buffer
vim.api.nvim_create_user_command("Redir", function(ctx)
    local lines = vim.split(vim.api.nvim_exec2(ctx.args, { output = true }).output, "\n")
    local buf = vim.api.nvim_get_current_buf()
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.opt_local.buftype = "nofile"
    vim.opt_local.bufhidden = "wipe"
end, { nargs = "+", complete = "command" })

-- This might help with syntax highlighting
vim.filetype.add({
    extension = {
        svelte = "svelte",
    },
})
vim.treesitter.language.register("svelte", "svelte")

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
    lualine.setup({
        options = { theme = "gruvbox" },
        sections = {
            lualine_c = {
                {
                    "filename",
                    path = 1, -- 0 = just filename, 1 = relative path, 2 = absolute path
                },
            },
        },
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
if status_fzf then
    fzf.setup({ "fzf-native" })
    fzf.register_ui_select()
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

-- Save undo history to a file so it persists across restarts
local undodir = vim.fn.expand("~/.local/share/nvim/undo")

if vim.fn.isdirectory(undodir) == 0 then
    vim.fn.mkdir(undodir, "p")
end

vim.opt.undodir = undodir
vim.opt.undofile = true

-- Configure UndoTree UI
vim.g.undotree_WindowLayout = 2 -- Shows the tree on the left, diff on bottom
vim.g.undotree_SetFocusWhenToggle = 1 -- Jump to the tree automatically

-- Highlight yanked text
vim.api.nvim_create_autocmd("TextYankPost", {
    desc = "Highlight text on yank",
    group = vim.api.nvim_create_augroup("YankHighlight", { clear = true }),
    callback = function()
        vim.highlight.on_yank({
            higroup = "IncSearch", -- The highlight color group
            timeout = 150, -- Animation duration in milliseconds
        })
    end,
})

-- treesitter is syntax highlighting
local status_ts, configs = pcall(require, "nvim-treesitter.configs")
if status_ts then
    configs.setup({
        ensure_installed = {},
        auto_install = false,
        highlight = {
            enable = true,
            additional_vim_regex_highlighting = false,
        },
        indent = { enable = true },
    })
    -- Global attachment fallback for Nix
    vim.api.nvim_create_autocmd("FileType", {
        callback = function()
            local buf = vim.api.nvim_get_current_buf()
            local lang = vim.treesitter.language.get_lang(vim.bo.filetype)
            if lang and pcall(vim.treesitter.get_parser, buf, lang) then
                vim.treesitter.start(buf, lang)
            end
        end,
    })
end
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile", "FileType" }, {
    callback = function()
        local buf = vim.api.nvim_get_current_buf()
        -- Check if we have a parser for this filetype
        local lang = vim.treesitter.language.get_lang(vim.bo.filetype)
        if lang then
            pcall(vim.treesitter.start, buf, lang)
        end
    end,
})
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

local function theme_picker()
    local themes = { "gruvbox", "catppuccin", "tokyonight", "vague", "melange" }
    require("fzf-lua").fzf_exec(themes, {
        prompt = "Theme> ",
        actions = {
            ["default"] = function(selected)
                vim.cmd.colorscheme(selected[1])
                vim.notify("Theme: " .. selected[1], vim.log.levels.INFO)
            end,
        },
    })
end

-- grug-far (search and replace)
local status_grug, grug = pcall(require, "grug-far")
if status_grug then
    grug.setup({
        openTarget = "tab",
        -- feel free to override defaults, e.g.:
        -- engine = "rg",
        -- openTarget = "vsplit",
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
                local selection = table.concat(lines, "\n")
                require("grug-far").open({ vimgrep = selection })
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
            "<leader>xi",
            function()
                print(vim.inspect(vim.inspect_pos()))
            end,
            { desc = "Inspect under cursor" },
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
        { "<leader>cu", vim.cmd.UndotreeToggle, desc = "UndoTree (Time Travel)" },
        { "<leader>cc", "<cmd>vsplit | Oil<cr>", desc = "Commander (Dual-Pane Oil)" },

        -- Path Operations
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

        -- UI group
        { "<leader>u", group = "UI" },

        {
            "<leader>uT",
            theme_picker,
            desc = "Pick a colorscheme",
        },
        {
            "<leader>ua",
            function()
                require("smear_cursor").toggle()
                local is_enabled = require("smear_cursor").enabled
                local status = is_enabled and "ON" or "OFF"
                vim.notify("Smear Cursor turned " .. status, vim.log.levels.INFO, {
                    title = "Smear Cursor",
                })
            end,
            desc = "Toggle Smear Cursor",
        },
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
                -- GitSigns doesn't return state easily, but we can notify the trigger
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
                -- Check if global variable or buffer variable exists for Twilight state
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
end

local status_dressing, dressing = pcall(require, "dressing")
if status_dressing then
    dressing.setup({
        input = {
            enabled = true,
            title_pos = "left",
            insert_only = false,
            start_in_insert = true,
            border = "rounded",
            relative = "editor",
            prefer_width = 80,
            max_width = { 140, 0.9 },
            min_width = { 40, 0.3 },
            buf_options = {
                filetype = "markdown",
            },
            win_options = {
                wrap = true,
                linebreak = true,
                list = false,
                breakindent = true,
                breakindentopt = "shift:2",
                winhighlight = "NormalFloat:Normal",
            },
            height = 14,
            min_height = { 5, 0.1 },
            max_height = { 40, 0.5 },
            mappings = {
                n = {
                    ["<Esc>"] = "Close",
                    ["q"] = "Close",
                    ["<CR>"] = "Confirm",
                },
                i = {
                    ["<CR>"] = { "<C-\\><C-n>", false },
                    ["<C-CR>"] = "Confirm",
                    ["<M-CR>"] = "Confirm",
                    ["<Esc>"] = false,
                    ["<Up>"] = "HistoryPrev",
                    ["<Down>"] = "HistoryNext",
                },
            },
        },
    })
end

vim.api.nvim_create_user_command("SllmScratch", function()
    local buf = vim.api.nvim_create_buf(false, true)
    vim.bo[buf].buftype = "nofile"
    vim.bo[buf].bufhidden = "wipe"
    vim.api.nvim_buf_set_name(buf, "sllm-prompt")
    vim.bo[buf].filetype = "markdown" -- Fixed target buffer reference

    -- Dynamic Centering Math
    local width = math.floor(vim.o.columns * 0.6)
    local height = math.floor(vim.o.lines * 0.6)
    local row = math.floor((vim.o.lines - height) / 2)
    local col = math.floor((vim.o.columns - width) / 2)

    -- Open floating window and capture its ID
    local win = vim.api.nvim_open_win(buf, true, {
        relative = "editor",
        width = width,
        height = height,
        row = row,
        col = col,
        style = "minimal",
        border = "rounded",
    })

    -- Explicit UI cleanup helper
    local function close_scratch()
        if vim.api.nvim_win_is_valid(win) then
            vim.api.nvim_win_close(win, true)
        end
        if vim.api.nvim_buf_is_valid(buf) then
            vim.api.nvim_buf_delete(buf, { force = true })
        end
    end

    -- Explicit data extraction helper
    local function send_scratch()
        -- Must extract text BEFORE destroying the buffer context
        local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
        local text = table.concat(lines, "\n")

        close_scratch()

        if text ~= "" then
            require("sllm").send_prompt(text)
        end
    end

    -- Normal mode mappings
    vim.keymap.set("n", "<Esc>", close_scratch, { buffer = buf, desc = "Close without sending" })
    vim.keymap.set("n", "q", close_scratch, { buffer = buf, desc = "Close without sending" })
    vim.keymap.set("n", "<CR>", send_scratch, { buffer = buf, desc = "Send prompt and close" })

    -- Insert mode mappings
    vim.keymap.set("i", "<C-CR>", send_scratch, { buffer = buf, desc = "Send prompt (Ctrl+Enter)" })
    vim.keymap.set("i", "<M-CR>", send_scratch, { buffer = buf, desc = "Send prompt (Alt+Enter)" })

    -- Start in insert mode
    vim.cmd("startinsert")
end, {})

-- Keymap to trigger scratch prompt
vim.keymap.set("n", "<leader>sb", ":SllmScratch<CR>", { desc = "Open scratch prompt for sllm" })

-- ==================================
-- Flat Keymap Launcher (fzf + tags)
-- ==================================

-- Populate with your 100+ shortcuts
-- Copy from the which‑key `wk.add` entries above
local key_shortcuts = {
    -- Git
    {
        key = "<leader>gg",
        desc = "LazyGit",
        tags = { "git", "status" },
        action = function()
            vim.cmd("LazyGit")
        end,
    },
    {
        key = "<leader>gl",
        desc = "Git log current file",
        tags = { "git", "log" },
        action = function()
            vim.cmd("LazyGitFilterCurrentFile")
        end,
    },
    {
        key = "<leader>gs",
        desc = "Git status (fzf)",
        tags = { "git", "status", "fzf" },
        action = function()
            vim.cmd("FzfLua git_status")
        end,
    },
    {
        key = "<leader>gb",
        desc = "Git branches",
        tags = { "git", "branch" },
        action = function()
            vim.cmd("FzfLua git_branches")
        end,
    },
    {
        key = "<leader>gc",
        desc = "Git commits",
        tags = { "git", "commit" },
        action = function()
            vim.cmd("FzfLua git_commits")
        end,
    },
    {
        key = "<leader>gl",
        desc = "Git blame line",
        tags = { "git", "blame" },
        action = function()
            vim.cmd("Gitsigns blame_line")
        end,
    },
    {
        key = "<leader>gd",
        desc = "Git diff",
        tags = { "git", "diff" },
        action = function()
            vim.cmd("Gitsigns diffthis")
        end,
    },
    -- FZF / Files
    {
        key = "<leader>ff",
        desc = "Find files (fzf)",
        tags = { "file", "search" },
        action = function()
            fzf.files({ fd_opts = "--type f --hidden --exclude .git" })
        end,
    },
    { key = "<leader>fg", desc = "Live grep (fzf)", tags = { "grep", "search" }, action = fzf.live_grep },
    { key = "<leader>fb", desc = "Switch buffer (fzf)", tags = { "buffer" }, action = fzf.buffers },
    {
        key = "<leader>fc",
        desc = "Search commands (fzf)",
        tags = { "command" },
        action = function()
            vim.cmd("FzfLua commands")
        end,
    },
    {
        key = "<leader>fk",
        desc = "Search keymaps (fzf)",
        tags = { "keymap" },
        action = function()
            vim.cmd("FzfLua keymaps")
        end,
    },
    {
        key = "<leader>fa",
        desc = "Fzf global",
        tags = { "fzf", "all" },
        action = function()
            vim.cmd("FzfLua global")
        end,
    },
    { key = "<leader>/", desc = "Grep project", tags = { "grep", "search" }, action = fzf.live_grep },
    -- Grug Far
    {
        key = "<leader>fr",
        desc = "Grug Far (S&R)",
        tags = { "search", "replace", "find" },
        action = function()
            vim.cmd("GrugFar")
        end,
    },
    {
        key = "<leader>fR",
        desc = "Grug Far (selection)",
        tags = { "search", "replace", "selection" },
        action = function()
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
    },
    -- Buffers / Quit
    { key = "<leader>bb", desc = "Switch buffer", tags = { "buffer" }, action = fzf.buffers },
    {
        key = "<leader>bd",
        desc = "Delete buffer",
        tags = { "buffer", "close" },
        action = function()
            vim.cmd("bdelete")
        end,
    },
    {
        key = "<leader>p",
        desc = "Paste last yank",
        tags = { "paste", "register" },
        action = function()
            vim.fn.feedkeys('"0p')
        end,
    },
    {
        key = "<leader>R",
        desc = "Registers",
        tags = { "register" },
        action = function()
            vim.cmd("registers")
        end,
    },
    {
        key = "<leader>qq",
        desc = "Quit all",
        tags = { "quit", "exit" },
        action = function()
            vim.cmd("qa")
        end,
    },
    -- Windows
    {
        key = "<leader>wv",
        desc = "Split vertical",
        tags = { "window", "split" },
        action = function()
            vim.cmd("vsplit")
        end,
    },
    {
        key = "<leader>wh",
        desc = "Split horizontal",
        tags = { "window", "split" },
        action = function()
            vim.cmd("split")
        end,
    },
    {
        key = "<leader>wc",
        desc = "Close window",
        tags = { "window", "close" },
        action = function()
            vim.cmd("close")
        end,
    },
    {
        key = "<leader>wo",
        desc = "Close other windows",
        tags = { "window", "only" },
        action = function()
            vim.cmd("only")
        end,
    },
    -- Diagnostics / Errors
    {
        key = "<leader>xx",
        desc = "Open errors in QFL",
        tags = { "error", "diagnostic", "qf" },
        action = function()
            vim.diagnostic.setqflist()
        end,
    },
    {
        key = "<leader>xt",
        desc = "Trouble diagnostics (project)",
        tags = { "error", "diagnostic", "trouble" },
        action = function()
            vim.cmd("Trouble diagnostics toggle")
        end,
    },
    {
        key = "<leader>xT",
        desc = "Trouble diagnostics (buffer)",
        tags = { "error", "diagnostic", "trouble" },
        action = function()
            vim.cmd("Trouble diagnostics toggle filter.buf=0")
        end,
    },
    {
        key = "<leader>xl",
        desc = "Search workspace errors (fzf)",
        tags = { "error", "fzf" },
        action = function()
            fzf.diagnostics_workspace()
        end,
    },
    {
        key = "<leader>xi",
        desc = "Inspect under cursor",
        tags = { "inspect" },
        action = function()
            print(vim.inspect(vim.inspect_pos()))
        end,
    },
    -- Code
    {
        key = "<leader>co",
        desc = "Oil file explorer",
        tags = { "file", "explorer", "oil" },
        action = function()
            vim.cmd("Oil")
        end,
    },
    { key = "<leader>cu", desc = "Undo tree", tags = { "undo", "history" }, action = vim.cmd.UndotreeToggle },
    {
        key = "<leader>cc",
        desc = "Commander (Oil split)",
        tags = { "file", "oil", "split" },
        action = function()
            vim.cmd("vsplit | Oil")
        end,
    },
    {
        key = "<leader>cf",
        desc = "Format document",
        tags = { "format", "lint" },
        action = function()
            require("conform").format({ async = true, lsp_fallback = true })
        end,
    },
    {
        key = "<leader>cs",
        desc = "Toggle autosave",
        tags = { "save", "auto" },
        action = function()
            vim.g.autosave_enabled = not vim.g.autosave_enabled
            print("Autosave: " .. (vim.g.autosave_enabled and "ON" or "OFF"))
        end,
    },
    -- Path
    {
        key = "<leader>cpp",
        desc = "Print full path",
        tags = { "path" },
        action = function()
            print(vim.fn.expand("%:p"))
        end,
    },
    {
        key = "<leader>cpa",
        desc = "Copy absolute path",
        tags = { "path", "copy" },
        action = function()
            local p = vim.fn.expand("%:p")
            vim.fn.setreg("+", p)
            print("Copied: " .. p)
        end,
    },
    {
        key = "<leader>cpr",
        desc = "Copy relative path",
        tags = { "path", "copy" },
        action = function()
            local p = vim.fn.expand("%:.")
            vim.fn.setreg("+", p)
            print("Copied: " .. p)
        end,
    },
    {
        key = "<leader>cpw",
        desc = "Print working dir",
        tags = { "path", "pwd" },
        action = function()
            vim.cmd("pwd")
        end,
    },
    -- UI
    {
        key = "<leader>uT",
        desc = "Pick theme",
        tags = { "theme", "colorscheme" },
        action = function()
            require("fzf-lua").fzf_exec({ "gruvbox", "catppuccin", "tokyonight", "vague", "melange" }, {
                prompt = "Theme> ",
                actions = {
                    ["default"] = function(s)
                        vim.cmd.colorscheme(s[1])
                        vim.notify("Theme: " .. s[1])
                    end,
                },
            })
        end,
    },
    {
        key = "<leader>ua",
        desc = "Toggle smear cursor",
        tags = { "cursor", "anim" },
        action = function()
            require("smear_cursor").toggle()
            vim.notify("Smear cursor: " .. (require("smear_cursor").enabled and "ON" or "OFF"))
        end,
    },
    {
        key = "<leader>uw",
        desc = "Toggle line wrap",
        tags = { "wrap" },
        action = function()
            vim.opt.wrap = not vim.opt.wrap:get()
            print("Wrap: " .. (vim.opt.wrap:get() and "ON" or "OFF"))
        end,
    },
    {
        key = "<leader>us",
        desc = "Toggle spelling",
        tags = { "spell" },
        action = function()
            vim.opt.spell = not vim.opt.spell:get()
            print("Spell: " .. (vim.opt.spell:get() and "ON" or "OFF"))
        end,
    },
    {
        key = "<leader>un",
        desc = "Toggle relative numbers",
        tags = { "number", "rnu" },
        action = function()
            vim.wo.relativenumber = not vim.wo.relativenumber
            print("Rnu: " .. (vim.wo.relativenumber and "ON" or "OFF"))
        end,
    },
    {
        key = "<leader>ud",
        desc = "Toggle diagnostics",
        tags = { "diagnostic" },
        action = function()
            local e = not vim.diagnostic.is_enabled()
            vim.diagnostic.enable(e)
            print("Diag: " .. (e and "ON" or "OFF"))
        end,
    },
    {
        key = "<leader>uf",
        desc = "Toggle format on save",
        tags = { "format", "save" },
        action = function()
            vim.g.disable_autoformat = not vim.g.disable_autoformat
            print("Autoformat: " .. (vim.g.disable_autoformat and "OFF" or "ON"))
        end,
    },
    {
        key = "<leader>ut",
        desc = "Toggle twilight",
        tags = { "focus", "dark" },
        action = function()
            vim.cmd("Twilight")
        end,
    },
    {
        key = "<leader>um",
        desc = "Toggle markdown render",
        tags = { "md", "render" },
        action = function()
            vim.cmd("RenderMarkdown toggle")
        end,
    },
    -- Terminal
    {
        key = "<leader>tt",
        desc = "Terminal (full)",
        tags = { "term", "shell" },
        action = function()
            vim.cmd("terminal")
            vim.cmd("startinsert")
        end,
    },
    {
        key = "<leader>ts",
        desc = "Terminal (hsplit)",
        tags = { "term", "split" },
        action = function()
            vim.cmd("split | terminal")
            vim.cmd("startinsert")
        end,
    },
    {
        key = "<leader>tv",
        desc = "Terminal (vsplit)",
        tags = { "term", "split" },
        action = function()
            vim.cmd("vsplit | terminal")
            vim.cmd("startinsert")
        end,
    },
    -- Misc
    {
        key = "<leader>sb",
        desc = "Send to LLM",
        tags = { "sllm", "prompt" },
        action = function()
            vim.cmd("SllmScratch")
        end,
    },
    {
        key = "<leader>e",
        desc = "Toggle Neo-tree",
        tags = { "file", "tree", "explorer" },
        action = function()
            vim.cmd("Neotree toggle")
        end,
    },
}

-- Build items: visible part + hidden tags separated by "||"
local function show_shortcuts()
    local items = {}
    for _, s in ipairs(key_shortcuts) do
        local tags_str = s.tags and table.concat(s.tags, ", ") or ""
        table.insert(items, string.format("%s  %s||%s", s.key, s.desc, tags_str))
    end

    require("fzf-lua").fzf_exec(items, {
        prompt = "Shortcuts> ",
        fzf_opts = {
            ["--delimiter"] = "\\|\\|",
            ["--with-nth"] = "1",
            ["--preview-window"] = "hidden",
        },
        actions = {
            ["default"] = function(selected)
                local line = selected[1]
                local key = line:match("^(%S+)")
                if not key then
                    return
                end
                for _, s in ipairs(key_shortcuts) do
                    if s.key == key then
                        s.action()
                        return
                    end
                end
                vim.notify("Unknown key: " .. key, vim.log.levels.WARN)
            end,
        },
    })
end

-- Bind to <leader>? (or change to <leader>sk if ? conflicts)
vim.keymap.set("n", "<leader>?", show_shortcuts, { desc = "Search shortcuts (flat fzf)" })
