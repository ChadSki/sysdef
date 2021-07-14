{
  description = "My factorized multi-system NixOS definitions";

  inputs = {
    nixpkgs.url = "flake:nixpkgs";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    deploy-rs = { url = "github:serokell/deploy-rs"; };
  };

  outputs = { self, nixpkgs, home-manager, deploy-rs }:
    let
      nodes = {
        # name, system
        kgpe = "x86_64-linux";
        nix-apu = "x86_64-linux";
        tulkas = "x86_64-linux";
        contain = "x86_64-linux";
      };
      makeHome = system: home-manager.lib.homeManagerConfiguration
        {
          pkgs = nixpkgs.legacyPackages.${system};
          modules = [ ./users/chad.nix ];
        };
      makeNixosConfig = name: system:
        nixpkgs.lib.nixosSystem {
          system = system;
          modules = [ ./hosts/${name} ];
        };
      makeDeployNode = name: system: {
        hostname = name;
        profiles = {
          system = {
            user = "root";
            path = deploy-rs.lib.${system}.activate.nixos
              self.nixosConfigurations.${name};
          };
          chad = {
            user = "chad";
            sshUser = "chad";
            path = deploy-rs.lib.${system}.activate.home-manager
              (makeHome system);
          };
        };
      };
    in
    {
      # `nix run . -- .#kgpe` will invoke `deploy` for the `kgpe` machine
      apps = deploy-rs.apps;

      # expected flake schema for NixOSes
      nixosConfigurations = builtins.mapAttrs makeNixosConfig nodes;

      # deploy-rs targets for each NixOS
      deploy.nodes = builtins.mapAttrs makeDeployNode nodes;

      # deploy-rs sanity checking
      checks = builtins.mapAttrs
        (system: deployLib: deployLib.deployChecks self.deploy)
        deploy-rs.lib;
    };
}
