{
  description = "nevim: nix extensible vim";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    in
    {
      packages = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          mkNevim = profile:
            let
              cfg = import ./nevim.nix { inherit pkgs profile; };
              wrapper = name: pkgs.writeShellScriptBin name ''
                export PATH="${pkgs.lib.makeBinPath cfg.binaries}:$PATH"
                export NEVIM_VARIANT="${profile}"
                exec ${cfg.nvimPkg}/bin/nvim "$@"
              '';
            in
            pkgs.symlinkJoin {
              name = "nevim-${profile}";
              paths = cfg.binaries ++ [
                (wrapper "nevim")
                (wrapper "nv")
              ];
            };
        in
        {
          pi = mkNevim "pi";
          desktop = mkNevim "desktop";
          default = mkNevim "desktop";
        }
      );
    };
}
