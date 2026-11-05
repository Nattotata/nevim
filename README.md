# Nix Extensible V IMproved: nevim

A self-contained Neovim configuration packaged with Nix. Everything the editor
needs at runtime (language servers, formatters, `fzf`, `ripgrep`, `fd`, `git`,
`curl`, ...) is bundled into the package and exposed on its `PATH`; there is no
Mason and nothing is downloaded at runtime.

## Dependencies

* Nix with flakes
* kitty terminal (for image rendering)

## Variants

There are two variants of nevim:

* `pi`: lightweight, no language servers. Intended for a Raspberry Pi.
* `desktop`: adds language servers for web dev and Python. One-size-fits-all.

```sh
nix run .#desktop   # or: just run_full
nix run .#pi        # or: just run_minimal
```

Both provide `nevim` and `nv` (and plain `nvim`) on the resulting `PATH`.

## Layout

```
flake.nix          # package outputs (pi / desktop)
nevim.nix          # neovim + plugins + bundled tools
lua/base.lua       # entrypoint, loads lua/nevim/*
lua/full.lua       # desktop-only entrypoint (LSP)
lua/nevim/         # split configuration modules
```

## LLM

nevim ships a tiny, self-contained OpenRouter client (`lua/nevim/llm.lua`). It
has no plugin dependencies (only `curl`), is strictly read-only, and only ever
sends the context you explicitly attach.

Set your key (e.g. in `~/.zshrc`):

```sh
export OPENROUTER_API_KEY="sk-or-..."
export NEVIM_LLM_MODEL="deepseek/deepseek-v4.1-flash"   # optional
```

| Command / keymap        | Action                                      |
| ----------------------- | ------------------------------------------- |
| `<leader>sb`            | Open prompt (visual mode: attach selection) |
| `<leader>sa`            | Attach the current file to the context      |
| `<leader>sd`            | Attach current diagnostics to the context   |
| `<leader>sC`            | Clear attached context                      |
| `<leader>sr`            | Reset chat history and context              |
| `:LlmAsk <question>`    | One-shot question                           |
| `:LlmContext`           | Show what is currently attached             |

Responses open in a non-modifiable buffer; your files are never edited by the
model.
