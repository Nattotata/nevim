-- Flat, taggable shortcut launcher bound to <leader>? (fzf).

local ok_fzf, fzf = pcall(require, "fzf-lua")
if not ok_fzf then
    return
end

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
        key = "<leader>gL",
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
            require("nevim.ui").theme_picker()
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
    -- LLM
    {
        key = "<leader>sb",
        desc = "LLM prompt",
        tags = { "llm", "prompt" },
        action = function()
            vim.cmd("LlmPrompt")
        end,
    },
    {
        key = "<leader>sa",
        desc = "LLM: attach file",
        tags = { "llm", "context", "file" },
        action = function()
            vim.cmd("LlmAdd")
        end,
    },
    {
        key = "<leader>sr",
        desc = "LLM: reset chat",
        tags = { "llm", "reset" },
        action = function()
            vim.cmd("LlmReset")
        end,
    },
    -- Misc
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

    fzf.fzf_exec(items, {
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

vim.keymap.set("n", "<leader>?", show_shortcuts, { desc = "Search shortcuts (flat fzf)" })
