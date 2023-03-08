rec {
  # Home-Manager for `chad` for the target system
  mkHome = { inputs, system, ... }: inputs.home-manager.lib.homeManagerConfiguration
    {
      pkgs = inputs.nixpkgs.legacyPackages.${system};
      modules = [ ./users/chad.nix ];
    };

  # NixOS config for the target machine (hostname) and system
  mkNixosConfig = hostname: { inputs, system, ... }:
    inputs.nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [ ./hosts/${hostname} ];
    };

  # Deploy-rs deployment targets
  mkDeployNode = hostname: { self, inputs, system }: {
    inherit hostname;
    profiles = {
      system = {
        user = "root";
        path = inputs.deploy-rs.lib.${system}.activate.nixos
          self.nixosConfigurations.${hostname};
      };
      chad = {
        user = "chad";
        sshUser = "chad";
        path = inputs.deploy-rs.lib.${system}.activate.home-manager
          (mkHome { inherit inputs system; });
      };
    };
  };
}
