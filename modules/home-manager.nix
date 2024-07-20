# BEGIN DOTGIT-SYNC BLOCK MANAGED
{
  pkgs,
  lib,
  config,
  # BEGIN DOTGIT-SYNC BLOCK EXCLUDED NIX_HOME_MANAGER_MODULE_CUSTOM
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
  # END DOTGIT-SYNC BLOCK EXCLUDED NIX_HOME_MANAGER_MODULE_CUSTOM
}
# END DOTGIT-SYNC BLOCK MANAGED
