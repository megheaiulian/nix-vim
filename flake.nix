{
  description = "vim/neovim nix configuration";

  outputs = { self, nixpkgs }:
    let
      call = f: args: f (builtins.intersectAttrs (builtins.functionArgs f) args);
      lib = import ./lib.nix;
      config = import ./config.nix;
    in
    {
      inherit config lib call;
      defaultPackage."x86_64-linux" =
        let pkgs = nixpkgs.legacyPackages."x86_64-linux";
        in call lib.mkNeovim pkgs (call config pkgs);
    };
}
