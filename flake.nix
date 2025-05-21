{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix.url = "github:ryantm/agenix";
    vpn-confinement.url = "github:Maroka-chan/VPN-Confinement";
  };
  outputs =
    { nixpkgs, home-manager, disko, agenix, vpn-confinement, ... }@inputs: {
      colmena = {
        meta = {
          # It helps prevent accidental deployments to the entire cluster when tags are used (e.g., @production and @staging).
          allowApplyAll = false;
          nixpkgs = import nixpkgs {
            system = "x86_64-linux";
            # overlays = [ (import ./overlays/caddy.nix) ];
            config.allowUnfree = true;
          };
          specialArgs = { inherit inputs; };
        };

        wolfcall = hosts/desktop/wolfcall/deployment.nix;
        lemnos = hosts/server/remote/lemnos/deployment.nix;
        agios = hosts/server/remote/agios/deployment.nix;
        rhodes = hosts/server/local/rhodes/deployment.nix;
      };

      # Only used for initial deployments
      nixosConfigurations = {
        lemnos = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            hosts/server/remote/lemnos/configuration.nix
            agenix.nixosModules.default
            disko.nixosModules.disko
            vpn-confinement.nixosModules.default
          ];
        };
        agios = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            hosts/server/remote/agios/configuration.nix
            agenix.nixosModules.default
            disko.nixosModules.disko
            vpn-confinement.nixosModules.default
          ];
        };
        rhodes = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            hosts/server/local/rhodes/configuration.nix
            agenix.nixosModules.default
            disko.nixosModules.disko
            vpn-confinement.nixosModules.default
          ];
        };
      };
    };
}

