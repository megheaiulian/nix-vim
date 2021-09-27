let
  mkNeovimCfg = { customRC, plugins, ... }: {
    packages.myVimPackage = {
      start = map (item: item.start) (builtins.filter (check: check ? "start") plugins);
      opt = map (item: item.opt) (builtins.filter (check: check ? "opt") plugins);
    };
    customRC = customRC + "\n" + builtins.concatStringsSep "\n" (map (i: i.config or "") plugins);
  };
  mkNeovim' = neovim: cfg: neovim.override { configure = mkNeovimCfg cfg; };
  mkNeovim = { neovim, lib, symlinkJoin, makeWrapper }: { customRC, plugins }: symlinkJoin {
    name = "nvim";
    paths = [ (mkNeovim' neovim { inherit customRC plugins; }) ];
    buildInputs = [ makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/nvim --prefix PATH : ${lib.makeBinPath (builtins.concatLists ( map (i: i.path) (builtins.filter (i: i ? "path") plugins)))}
    '';
  };
in
{
  inherit
    mkNeovimCfg
    mkNeovim;
}
