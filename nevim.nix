{ pkgs, profile ? "desktop" }:

let
  baseLua = builtins.readFile ./lua/base.lua;
  fullLua = if profile == "desktop" then builtins.readFile ./lua/full.lua else "";

  fullPackages = with pkgs; if profile == "desktop" then [
    typescript-language-server
    svelte-language-server
    pyright
    ruff
    lua-language-server
    nil # Nix LSP
  ] else [ ];

  fullPlugins = with pkgs.vimPlugins; if profile == "desktop" then [
  ] else [ ];

  nevim = pkgs.neovim.override {
    configure = {
      customRC = ''
        lua << takovydlefousy
        ${baseLua}
        ${fullLua}
        takovydlefousy
      '';
      packages.myVimPackage.start = with pkgs.vimPlugins; [
        # Babysitter for highlighting abstract syntax trees
        (nvim-treesitter.withPlugins (p: with p; [
          lua
          nix
          vim
          vimdoc
          query
          typescript
          javascript
          tsx
          svelte
          html
          css
          json
          bash
          markdown
          markdown_inline
          just
          mermaid
          yaml
        ]))
        # Which key does what, allows custom mapping for hints
        which-key-nvim
        # Theme
        gruvbox-nvim
        lualine-nvim
        # fuzzy finder
        fzf-lua
        # file system tree
        neo-tree-nvim
        # library for ui, dependency of neo tree
        nui-nvim
        mini-icons
        # collection of lua helper functions
        plenary-nvim
        # formatting and checking just files
        vim-just
        # handles language servers
        nvim-lspconfig
        # top bar with tabs and filenames
        bufferline-nvim
        # visual hints like links in vimium browser extension
        flash-nvim
        # surround a word with a quote or brackets
        nvim-surround
        # + and - signs
        gitsigns-nvim
        render-markdown-nvim
        # dimms everything expect current block
        twilight-nvim
        # formatting
        conform-nvim
        # git tui
        lazygit-nvim
        # intro screen
        alpha-nvim
      ] ++ fullPlugins;
    };
  };
in
{
  # This combines the wrapped nvim with its support tools
  binaries = [
    nevim
    pkgs.ripgrep
    pkgs.fd
    pkgs.fzf
    pkgs.git
    pkgs.xclip
    pkgs.wl-clipboard
    pkgs.lazygit
    pkgs.stylua
    pkgs.prettier
    pkgs.nixpkgs-fmt
  ] ++ fullPackages;

  # Reference to the actual nvim binary for the shell script
  nvimPkg = nevim;
}
