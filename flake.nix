{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
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
  outputs = { nixpkgs, nixpkgs-unstable, home-manager, disko, agenix
    , vpn-confinement, ... }@inputs: {
      colmena = {
        meta = {
          # It helps prevent accidental deployments to the entire cluster when tags are used (e.g., @production and @staging).
          allowApplyAll = false;
          nixpkgs = import nixpkgs {
            system = "x86_64-linux";
            config.allowUnfree = true;
          };
          specialArgs = {
            inherit inputs;
            pkgs-unstable = import nixpkgs-unstable {
              system = "x86_64-linux";
              config.allowUnfree = true;
            };
          };
        };

        wolfcall = hosts/desktop/wolfcall/deployment.nix;
        rhodes = hosts/server/rhodes/deployment.nix;
        lemnos = hosts/server/lemnos/deployment.nix;
        agios = hosts/server/agios/deployment.nix;
      };
    };
}

