-- Minimal, self-contained OpenRouter client.
--
-- Design goals:
--   * No third-party Neovim plugin, only the `curl` binary.
--   * Read-only: responses are rendered in a non-modifiable scratch buffer and
--     nothing in your files is ever modified.
--   * The model only sees context you explicitly attach (a file or a visual
--     selection) plus your prompt.
--
-- Configuration via environment variables:
--   OPENROUTER_API_KEY   (required)
--   NEVIM_LLM_MODEL      (default: deepseek/deepseek-v4.1-flash)
--   OPENROUTER_API_BASE  (default: https://openrouter.ai/api/v1)

local M = {}

local function env(name, default)
    local v = os.getenv(name)
    if v == nil or v == "" then
        return default
    end
    return v
end

M.config = {
    api_base = env("OPENROUTER_API_BASE", "https://openrouter.ai/api/v1"),
    model = env("NEVIM_LLM_MODEL", "deepseek/deepseek-v4.1-flash"),
    max_history = 40,
    system_prompt = table.concat({
        "You are a concise, expert software engineer embedded in Neovim.",
        "Only use the context explicitly provided to you.",
        "If you need information that was not provided, ask for it instead of guessing.",
        "Reply with precise, minimal, correct code and explanations.",
    }, " "),
}

M.history = {}
M.context = {}

local function api_key()
    local key = env("OPENROUTER_API_KEY", nil)
    if not key then
        vim.notify("nevim-llm: OPENROUTER_API_KEY is not set", vim.log.levels.ERROR)
    end
    return key
end

local function count_lines(text)
    local n = 1
    for _ in text:gmatch("\n") do
        n = n + 1
    end
    return n
end

local function http_chat(payload, on_done)
    local key = api_key()
    if not key then
        return
    end

    -- Keep both the API key and the body out of the process argument list.
    local body_path = vim.fn.tempname()
    local header_path = vim.fn.tempname()
    vim.fn.writefile({ vim.json.encode(payload) }, body_path)
    vim.fn.writefile({ "Authorization: Bearer " .. key }, header_path)
    vim.fn.setfperm(header_path, "rw-------")

    local cmd = {
        "curl",
        "-sS",
        "-X",
        "POST",
        M.config.api_base .. "/chat/completions",
        "-H",
        "@" .. header_path,
        "-H",
        "Content-Type: application/json",
        "-H",
        "HTTP-Referer: https://github.com/nevim",
        "-H",
        "X-Title: nevim",
        "--data-binary",
        "@" .. body_path,
    }

    vim.system(cmd, { text = true }, function(out)
        vim.schedule(function()
            vim.fn.delete(body_path)
            vim.fn.delete(header_path)
            on_done(out)
        end)
    end)
end

local function parse_response(out)
    if out.code ~= 0 then
        return nil, "curl exited " .. out.code .. ": " .. (out.stderr or "")
    end
    local ok, data = pcall(vim.json.decode, out.stdout or "")
    if not ok or type(data) ~= "table" then
        return nil, "could not decode response"
    end
    if data.error then
        return nil, data.error.message or vim.inspect(data.error)
    end
    local choice = data.choices and data.choices[1]
    if not choice or not choice.message then
        return nil, "empty completion"
    end
    return choice.message.content
end

local function build_messages(prompt)
    local system = M.config.system_prompt
    if #M.context > 0 then
        local blocks = {}
        for _, item in ipairs(M.context) do
            blocks[#blocks + 1] = string.format("## %s\n```%s\n%s\n```", item.label, item.filetype or "", item.text)
        end
        system = system .. "\n\n# Provided context\n\n" .. table.concat(blocks, "\n\n")
    end

    local messages = { { role = "system", content = system } }
    for _, msg in ipairs(M.history) do
        messages[#messages + 1] = msg
    end
    messages[#messages + 1] = { role = "user", content = prompt }
    return messages
end

-- Render arbitrary text read-only in a vertical split.
function M.show(content)
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(content, "\n", { plain = true }))
    vim.bo[buf].buftype = "nofile"
    vim.bo[buf].bufhidden = "wipe"
    vim.bo[buf].swapfile = false
    vim.bo[buf].filetype = "markdown"
    vim.bo[buf].modifiable = false
    vim.bo[buf].readonly = true
    pcall(vim.api.nvim_buf_set_name, buf, "nevim-llm://response")

    vim.cmd("botright vsplit")
    vim.api.nvim_win_set_buf(0, buf)
end

function M.ask(prompt)
    if prompt == nil or prompt == "" then
        return
    end

    vim.notify("nevim-llm: thinking…", vim.log.levels.INFO)

    http_chat({
        model = M.config.model,
        messages = build_messages(prompt),
        stream = false,
    }, function(out)
        local content, err = parse_response(out)
        if not content then
            vim.notify("nevim-llm: " .. tostring(err), vim.log.levels.ERROR)
            return
        end

        M.history[#M.history + 1] = { role = "user", content = prompt }
        M.history[#M.history + 1] = { role = "assistant", content = content }
        while #M.history > M.config.max_history do
            table.remove(M.history, 1)
        end

        M.show(content)
    end)
end

function M.add_context(text, label, filetype)
    if not text or text == "" then
        return
    end
    M.context[#M.context + 1] = {
        text = text,
        label = label or "context",
        filetype = filetype or "",
    }
    vim.notify(string.format("nevim-llm: attached '%s' (%d lines)", label or "context", count_lines(text)))
end

function M.add_file(path)
    path = path or vim.api.nvim_buf_get_name(0)
    if path == "" or vim.fn.filereadable(path) == 0 then
        vim.notify("nevim-llm: no readable file to attach", vim.log.levels.WARN)
        return
    end
    local fh = io.open(path, "r")
    if not fh then
        vim.notify("nevim-llm: could not read " .. path, vim.log.levels.ERROR)
        return
    end
    local text = fh:read("*a")
    fh:close()
    local ft = vim.filetype.match({ filename = path }) or ""
    M.add_context(text, vim.fn.fnamemodify(path, ":."), ft)
end

function M.add_diagnostics(bufnr)
    bufnr = bufnr or 0
    local diags = vim.diagnostic.get(bufnr)
    if #diags == 0 then
        vim.notify("nevim-llm: no diagnostics in buffer", vim.log.levels.INFO)
        return
    end
    local lines = {}
    for _, d in ipairs(diags) do
        local sev = vim.diagnostic.severity[d.severity] or tostring(d.severity)
        lines[#lines + 1] = string.format("L%d:%d [%s] %s", d.lnum + 1, d.col + 1, sev, d.message)
    end
    local name = vim.fn.expand("%:.")
    if name == "" then
        name = "buffer"
    end
    M.add_context(table.concat(lines, "\n"), "diagnostics: " .. name)
end

function M.show_context()
    local lines = {}
    if #M.context == 0 then
        lines[1] = "(no context attached)"
    else
        for i, item in ipairs(M.context) do
            lines[#lines + 1] = string.format(
                "%d. %s [%s] - %d lines",
                i,
                item.label,
                item.filetype ~= "" and item.filetype or "text",
                count_lines(item.text)
            )
        end
    end
    M.show(table.concat(lines, "\n"))
end

function M.clear_context()
    M.context = {}
    vim.notify("nevim-llm: context cleared", vim.log.levels.INFO)
end

function M.reset()
    M.history = {}
    M.context = {}
    vim.notify("nevim-llm: history and context cleared", vim.log.levels.INFO)
end

-- Floating prompt buffer. Type a prompt and send with <CR> (normal) or
-- <C-CR>/<M-CR> (insert).
function M.open_prompt()
    local buf = vim.api.nvim_create_buf(false, true)
    vim.bo[buf].buftype = "nofile"
    vim.bo[buf].bufhidden = "wipe"
    vim.bo[buf].filetype = "markdown"
    pcall(vim.api.nvim_buf_set_name, buf, "nevim-llm://prompt")

    local width = math.floor(vim.o.columns * 0.6)
    local height = math.floor(vim.o.lines * 0.6)
    local row = math.floor((vim.o.lines - height) / 2)
    local col = math.floor((vim.o.columns - width) / 2)

    local win = vim.api.nvim_open_win(buf, true, {
        relative = "editor",
        width = width,
        height = height,
        row = row,
        col = col,
        style = "minimal",
        border = "rounded",
        title = " nevim-llm ",
        title_pos = "center",
    })

    local function close()
        if vim.api.nvim_win_is_valid(win) then
            vim.api.nvim_win_close(win, true)
        end
        if vim.api.nvim_buf_is_valid(buf) then
            vim.api.nvim_buf_delete(buf, { force = true })
        end
    end

    local function send()
        local text = table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), "\n")
        close()
        if text ~= "" then
            M.ask(text)
        end
    end

    vim.keymap.set("n", "<Esc>", close, { buffer = buf, desc = "Close without sending" })
    vim.keymap.set("n", "q", close, { buffer = buf, desc = "Close without sending" })
    vim.keymap.set("n", "<CR>", send, { buffer = buf, desc = "Send prompt" })
    vim.keymap.set("i", "<C-CR>", send, { buffer = buf, desc = "Send prompt" })
    vim.keymap.set("i", "<M-CR>", send, { buffer = buf, desc = "Send prompt" })

    vim.cmd("startinsert")
end

local function selection_range()
    local start_line = vim.fn.line("v")
    local end_line = vim.fn.line(".")
    if start_line > end_line then
        start_line, end_line = end_line, start_line
    end
    return start_line, end_line
end

function M.setup(opts)
    if opts then
        M.config = vim.tbl_deep_extend("force", M.config, opts)
    end

    vim.api.nvim_create_user_command("LlmPrompt", M.open_prompt, { desc = "Open the LLM prompt" })
    vim.api.nvim_create_user_command("LlmAsk", function(ctx)
        M.ask(ctx.args)
    end, { nargs = "+", desc = "Ask the LLM" })
    vim.api.nvim_create_user_command("LlmAdd", function(ctx)
        if ctx.args ~= "" then
            M.add_file(ctx.args)
        else
            M.add_file()
        end
    end, { nargs = "?", complete = "file", desc = "Attach a file to the LLM context" })
    vim.api.nvim_create_user_command("LlmAddDiagnostics", function()
        M.add_diagnostics(0)
    end, { desc = "Attach current diagnostics to the LLM context" })
    vim.api.nvim_create_user_command("LlmContext", M.show_context, { desc = "Show the LLM context" })
    vim.api.nvim_create_user_command("LlmClearContext", M.clear_context, { desc = "Clear the LLM context" })
    vim.api.nvim_create_user_command("LlmReset", M.reset, { desc = "Clear the LLM history and context" })

    vim.keymap.set("n", "<leader>sb", M.open_prompt, { desc = "LLM prompt" })
    vim.keymap.set("x", "<leader>sb", function()
        local first, last = selection_range()
        local lines = vim.api.nvim_buf_get_lines(0, first - 1, last, false)
        local name = vim.fn.expand("%:.")
        if name == "" then
            name = "[No Name]"
        end
        M.add_context(table.concat(lines, "\n"), string.format("%s:%d-%d", name, first, last), vim.bo.filetype)
        vim.cmd("normal! \27")
        M.open_prompt()
    end, { desc = "LLM: send selection" })
    vim.keymap.set("n", "<leader>sa", M.add_file, { desc = "LLM: attach current file" })
    vim.keymap.set("n", "<leader>sd", function()
        M.add_diagnostics(0)
    end, { desc = "LLM: attach diagnostics" })
    vim.keymap.set("n", "<leader>sC", M.clear_context, { desc = "LLM: clear context" })
    vim.keymap.set("n", "<leader>sr", M.reset, { desc = "LLM: reset chat" })
end

return M
