{
  description = "nevim: nix extensible vim";

  inputs =
    {
      nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
      sllm-src = {
        url = "github:mozanunal/sllm.nvim";
        flake = false;
      };
    };

  outputs = { self, nixpkgs, sllm-src }:
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
              cfg = import ./nevim.nix { inherit pkgs sllm-src profile; };
            in
            pkgs.symlinkJoin {
              name = "nevim-${profile}";
              paths = cfg.binaries ++ [
                (pkgs.writeShellScriptBin "nevim" ''
                  export PATH="${pkgs.lib.makeBinPath cfg.binaries}:$PATH"
                  exec ${cfg.nvimPkg}/bin/nvim "$@"
                '')
                (pkgs.writeShellScriptBin "nv" ''
                  exec ${cfg.nvimPkg}/bin/nvim "$@"
                '')
              ];
              nativeBuildInputs = [ pkgs.makeWrapper ];
              postBuild = ''
                wrapProgram $out/bin/nevim \
                  --set NEVIM_VARIANT "${profile}"
              '';
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
