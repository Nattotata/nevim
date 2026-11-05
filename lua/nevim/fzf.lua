-- Fuzzy finder. The fzf binary and fd/ripgrep are provided by the wrapper PATH.
local ok, fzf = pcall(require, "fzf-lua")
if ok then
    fzf.setup({ "fzf-native" })
    fzf.register_ui_select()
end
