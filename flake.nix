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

  outputs = { self, ... }@inputs:
    let
      inherit (import ./mk.nix) mkNixosConfig mkDeployNode;

      default = { inherit self inputs; system = "x86_64-linux"; };
      nodes = {
        kgpe = default;
        nix-apu = default;
        tulkas = default;
      };
    in
    {
      # `nix run . -- .#kgpe` will invoke `deploy` for the `kgpe` machine
      apps = inputs.deploy-rs.apps;

      # expected flake schema for NixOSes
      nixosConfigurations = builtins.mapAttrs mkNixosConfig nodes;

      # deploy-rs targets for each NixOS
      deploy.nodes = builtins.mapAttrs mkDeployNode nodes;

      # deploy-rs sanity checking
      checks = builtins.mapAttrs
        (system: deployLib: deployLib.deployChecks self.deploy)
        inputs.deploy-rs.lib;
    };
}
