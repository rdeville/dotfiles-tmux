{
  description = ''
    Flake for Tmux Config

    My generic public tmux configuration which load custom config stored in
    ~/.local/share/tmux (by default) to store configuration per hosts.
  '';

  inputs = {
    nixpkgs = {
      url = "nixpkgs/nixos-24.05";
    };
  };

  outputs = inputs @ {self, ...}: let
    pkgsForSystem = system:
      import inputs.nixpkgs {
        inherit system;
      };
    # This is a function that generates an attribute by calling a function you
    # pass to it, with each system as an argument
    forAllSystems = inputs.nixpkgs.lib.genAttrs allSystems;

    allSystems = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
  in {
    # TOOLING
    # ========================================================================
    formatter = forAllSystems (
      system:
        (pkgsForSystem system).alejandra
    );

    # PACKAGES
    # ========================================================================
    packages = forAllSystems (system: rec {
      tmuxrc = with (pkgsForSystem system);
        callPackage ./package.nix {};
      default = tmuxrc;
    });

    # HOME MANAGER MODULES
    # ========================================================================
    homeManagerModules = {
      tmuxrc = {
        pkgs,
        lib,
        config,
        ...
      }: let
        cfg = config.programs.tmuxrc;
      in {
        options = {
          programs = {
            tmuxrc = {
              enable = lib.mkEnableOption "Whether or not install package";
              package = lib.mkOption {
                type = lib.types.package;
                default = pkgs.tmux;
                description = "Tmux package to use.";
              };
            };
          };
        };

        config = lib.mkIf cfg.enable {
          xdg = {
            configFile = {
              tmux = {
                source = pkgs.callPackage ./package.nix {inherit pkgs;};
              };
            };
          };

          home = {
            packages = [
              cfg.package
            ];
          };
        };
      };
    };
    homeManagerModule = self.homeManagerModules.tmuxrc;
  };
}
