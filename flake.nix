{
  description = "My factorized multi-system NixOS definitions";

  inputs = {
    deploy-rs = { url = "github:serokell/deploy-rs"; }; # Don't bother following the target system nixpkgs input
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "flake:nixpkgs";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, ... }@inputs:
    let
      inherit (import ./mk.nix) mkNixosConfig mkDeployNode;
      nodes = {
        kgpe = { inherit self inputs; system = "x86_64-linux"; };
        #nix-apu = { inherit self inputs; system = "x86_64-linux"; };
        tulkas = { inherit self inputs; system = "x86_64-linux"; };
      };
    in
    {
      # define defaultApp so `nix run` will invoke a flake-tracked `deploy-rs` for us.
      # `nix run . -- .#kgpe` will invoke `deploy` for the `kgpe` machine.
      # `nixos-rebuild build --flake .#kgpe` if you're just building and want `--show-trace` support.
      apps = inputs.deploy-rs.apps;

      # deploy-rs sanity checking
      checks = builtins.mapAttrs
        (system: deployLib: deployLib.deployChecks self.deploy)
        inputs.deploy-rs.lib;

      # deploy-rs targets for each node
      deploy.nodes = builtins.mapAttrs mkDeployNode nodes;

      # expected flake schema for NixOSes
      nixosConfigurations = builtins.mapAttrs mkNixosConfig nodes;
    };
}
