-- Core editor options and small quality-of-life autocommands.

vim.opt.clipboard = "unnamedplus"

vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

vim.opt.number = true
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.softtabstop = 4
vim.opt.termguicolors = true
vim.opt.hidden = true
vim.opt.wrap = false

-- Persistent undo
local undodir = vim.fn.expand("~/.local/share/nvim/undo")
if vim.fn.isdirectory(undodir) == 0 then
    vim.fn.mkdir(undodir, "p")
end
vim.opt.undodir = undodir
vim.opt.undofile = true

vim.g.undotree_WindowLayout = 2
vim.g.undotree_SetFocusWhenToggle = 1

-- Autosave on leaving insert mode / losing focus
vim.g.autosave_enabled = true
vim.api.nvim_create_autocmd({ "InsertLeave", "FocusLost" }, {
    group = vim.api.nvim_create_augroup("AutosaveGroup", { clear = true }),
    callback = function()
        if vim.g.autosave_enabled and vim.bo.modified and vim.bo.buftype == "" then
            if vim.fn.expand("%:t") ~= "" then
                vim.cmd("silent! write")
            end
        end
    end,
})

-- Don't continue comments on new lines
vim.api.nvim_create_autocmd("FileType", {
    pattern = "*",
    callback = function()
        vim.opt_local.formatoptions:remove({ "r", "o" })
    end,
})

-- Highlight yanked text
vim.api.nvim_create_autocmd("TextYankPost", {
    desc = "Highlight text on yank",
    group = vim.api.nvim_create_augroup("YankHighlight", { clear = true }),
    callback = function()
        vim.highlight.on_yank({ higroup = "IncSearch", timeout = 150 })
    end,
})
