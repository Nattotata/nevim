-- Plugin configuration that has no better home.

local ok_oil, oil = pcall(require, "oil")
if ok_oil then
    oil.setup()
end

local ok_trouble, trouble = pcall(require, "trouble")
if ok_trouble then
    trouble.setup()
end

local ok_grug, grug = pcall(require, "grug-far")
if ok_grug then
    grug.setup({
        openTarget = "current",
        keymaps = {
            -- Disable default split/tab behaviors
            gotoLocation = { n = "" },
            gotoLocationSplit = { n = "" },
            gotoLocationTab = { n = "" },
        },
        -- Open the result under the cursor in the current buffer.
        on_attach = function(bufnr)
            vim.keymap.set("n", "<CR>", function()
                local results = require("grug-far/results")
                if not results then
                    return
                end
                local loc = results.get_location_at_cursor(bufnr)
                if loc and loc.filepath then
                    vim.cmd("edit " .. vim.fn.fnameescape(loc.filepath))
                    if loc.lnum then
                        vim.api.nvim_win_set_cursor(0, { loc.lnum, (loc.col or 1) - 1 })
                    end
                end
            end, { buffer = bufnr, silent = true, desc = "Open file in active buffer" })
        end,
    })
end
