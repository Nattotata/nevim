{ pkgs, profile ? "desktop" }:

let
  lib = pkgs.lib;

  # Lua sources, exposed on the runtimepath so that runtime errors report real
  # file:line locations instead of an anonymous pack file.
  luaDir = pkgs.runCommandLocal "nevim-lua" { } ''
    mkdir -p $out
    cp -r ${./lua} $out/lua
  '';

  # Language servers / formatters (desktop only).
  fullPackages = with pkgs; lib.optionals (profile == "desktop") [
    typescript-language-server
    svelte-language-server
    pyright
    ruff
    lua-language-server
    nil # Nix LSP
    vscode-langservers-extracted # CSS/HTML/JSON/... LSPs
    tailwindcss-language-server
  ];

  # Tools made available to nvim (and to its child processes) via PATH.
  runtimeTools = with pkgs; [
    curl
    direnv
    fd
    fzf
    git
    ripgrep
  ];

  nevim = pkgs.neovim.override {
    configure = {
      customRC = ''
        lua vim.opt.rtp:prepend("${luaDir}")
        lua require("base")
        ${lib.optionalString (profile == "desktop") ''lua require("full")''}
      '';
      packages.myVimPackage.start = with pkgs.vimPlugins; [
        # Enhanced syntax highlighting; parsers are bundled here.
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
          python
        ]))
        which-key-nvim # keybinding hints
        # themes
        gruvbox-nvim
        tokyonight-nvim
        catppuccin-nvim
        kanagawa-nvim
        vague-nvim
        melange-nvim
        # status line and top bar
        lualine-nvim
        bufferline-nvim
        # fuzzy finder
        fzf-lua
        # file tree + its ui library
        neo-tree-nvim
        nui-nvim
        mini-icons
        # command line ui
        dressing-nvim
        # lua helper functions
        plenary-nvim
        # just file support
        vim-just
        # language servers
        nvim-lspconfig
        # visual hints, surround, git signs
        flash-nvim
        nvim-surround
        gitsigns-nvim
        # markdown / focus
        render-markdown-nvim
        twilight-nvim
        # formatting
        conform-nvim
        # git tui
        lazygit-nvim
        # dashboard / filesystem / diagnostics / undo / cursor / env
        alpha-nvim
        oil-nvim
        trouble-nvim
        undotree
        smear-cursor-nvim
        direnv-vim
        # search and replace
        grug-far-nvim
      ];
    };
    extraMakeWrapperArgs = "--prefix PATH : ${lib.makeBinPath (runtimeTools ++ fullPackages)}";
  };
in
{
  # The wrapped nvim together with all of its support tools.
  binaries = [
    nevim
    pkgs.curl
    pkgs.ripgrep
    pkgs.fd
    pkgs.fzf
    pkgs.git
    pkgs.xclip
    pkgs.wl-clipboard
    pkgs.lazygit
    pkgs.stylua
    pkgs.prettier
    pkgs.prettierd
    pkgs.nixpkgs-fmt
    pkgs.just
  ] ++ fullPackages;

  # The actual nvim binary used by the shell scripts.
  nvimPkg = nevim;
}
