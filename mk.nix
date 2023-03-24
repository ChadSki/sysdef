rec {
  # Home-Manager for my user for the target system
  mkHome = { inputs, system, ... }: inputs.home-manager.lib.homeManagerConfiguration
    {
      pkgs = inputs.nixpkgs.legacyPackages.${system};
      modules = [ ./users/chad.nix ];
    };

  # NixOS config for the target machine (hostname) and system
  mkNixosConfig = hostname: { inputs, system, ... }:
    inputs.nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        ./hosts/${hostname}
        inputs.sops-nix.nixosModules.sops
        # Register the system nixpkgs for fast local search
        ({ ... }: {
          nix.registry.sys = {
            from = { type = "indirect"; id = "sys"; };
            flake = inputs.nixpkgs;
          };
        })
      ];
    };

  # Define a deploy-rs deployment target: system name and my user
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
