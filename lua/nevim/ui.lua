-- Colorscheme, statusline, icons and which-key look & feel.

local M = {}

pcall(vim.cmd, "colorscheme gruvbox")

local ok_lualine, lualine = pcall(require, "lualine")
if ok_lualine then
    lualine.setup({
        options = { theme = "gruvbox" },
        sections = {
            lualine_c = {
                { "filename", path = 1 },
            },
        },
    })
end

local ok_icons, icons = pcall(require, "mini.icons")
if ok_icons then
    icons.setup()
    icons.mock_nvim_web_devicons()
end

local ok_bufferline, bufferline = pcall(require, "bufferline")
if ok_bufferline then
    bufferline.setup({
        options = {
            separator_style = "slant",
            offsets = { { filetype = "neo-tree", text = "File Explorer", text_align = "left" } },
        },
    })
end

local ok_surround, surround = pcall(require, "nvim-surround")
if ok_surround then
    surround.setup({ aliases = { ["b"] = "**" } })
end

local ok_dressing, dressing = pcall(require, "dressing")
if ok_dressing then
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
            buf_options = { filetype = "markdown" },
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

local ok_wk, wk = pcall(require, "which-key")
if ok_wk then
    wk.setup({
        preset = "modern",
        win = {
            border = "rounded",
            width = 0.9,
            height = { min = 4, max = 25 },
            wo = { winblend = 15 },
        },
        layout = { spacing = 6, align = "center" },
    })
end

-- Disable italics everywhere, now and after every colorscheme change.
local function disable_italics()
    for name, hl in pairs(vim.api.nvim_get_hl(0, {})) do
        if hl.italic then
            hl.italic = false
            vim.api.nvim_set_hl(0, name, hl)
        end
    end
end

disable_italics()
vim.api.nvim_create_autocmd("ColorScheme", { callback = disable_italics })

M.themes = { "gruvbox", "catppuccin", "tokyonight", "vague", "melange", "kanagawa" }

function M.theme_picker()
    local ok_fzf, fzf = pcall(require, "fzf-lua")
    if not ok_fzf then
        return
    end
    fzf.fzf_exec(M.themes, {
        prompt = "Theme> ",
        actions = {
            ["default"] = function(selected)
                vim.cmd.colorscheme(selected[1])
                vim.notify("Theme: " .. selected[1], vim.log.levels.INFO)
            end,
        },
    })
end

return M
