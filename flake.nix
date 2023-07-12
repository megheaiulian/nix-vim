{
  description = "vim/neovim nix configuration";
  inputs.nixpkgs.url = github:nixos/nixpkgs/nixos-unstable;
  outputs = { self, nixpkgs }:
    let
      supportedSystems = [ "x86_64-linux" ];
      forAllSystems = f: nixpkgs.lib.genAttrs supportedSystems (system: f system);
      call = f: args: f (builtins.intersectAttrs (builtins.functionArgs f) args);
      lib = import ./lib.nix;
      config = import ./config.nix;
      mkPackage = pkgs: call lib.mkNeovim pkgs (call config pkgs);
    in
    {
      inherit config lib call;
      defaultPackage = forAllSystems (system: mkPackage (import nixpkgs { inherit system; }));
      home = { pkgs, ... }: {
        home.sessionVariables = rec {
          VISUAL = "nvim";
          EDITOR = VISUAL;
        };
        home.packages = [ (mkPackage pkgs) ];
      };
    };
}
