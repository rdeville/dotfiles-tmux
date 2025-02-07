self: {
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.tmuxrc;
in {
  options = {
    tmuxrc = {
      enable = lib.mkEnableOption "Whether or not install package";
      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.tmux;
        description = "Tmux package to use.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    xdg = {
      configFile = {
        tmux = {
          source = pkgs.callPackage ../package.nix {inherit pkgs;};
        };
      };
    };

    home = {
      packages = [
        cfg.package
      ];
    };
  };
}
