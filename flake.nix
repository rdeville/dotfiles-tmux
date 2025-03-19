{
  description = ''
    Flake for Private per host Tmux Config
  '';

  inputs = {
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixos-unstable";
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
      tmuxdata = with (pkgsForSystem system);
        callPackage ./package.nix {};
      default = tmuxdata;
    });

    # HOME MANAGER MODULES
    # ========================================================================
    homeManagerModules = {
      tmuxdata = {
        inputs,
        pkgs,
        ...
      }: {
        xdg = {
          dataFile = {
            tmux = {
              source = pkgs.callPackage ./package.nix {inherit pkgs;};
            };
          };
        };
      };
    };
    homeManagerModule = self.homeManagerModules.tmuxdata;
  };
}
