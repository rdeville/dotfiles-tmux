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
        callPackage modules/package.nix {};
      default = tmuxrc;
    });

    # HOME MANAGER MODULES
    # ========================================================================
    homeManagerModules = {
      tmuxrc = import ./modules/home-manager.nix self;
    };
    homeManagerModule = self.homeManagerModules.tmuxrc;

  };
}
