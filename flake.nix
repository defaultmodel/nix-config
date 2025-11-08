{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    flake-utils.url = "github:numtide/flake-utils";

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

    colmena = {
      url = "github:zhaofengli/colmena";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
  };
  outputs = { self, colmena, nixpkgs, nixpkgs-unstable, home-manager, disko
    , agenix, vpn-confinement, ... }@inputs: {
      colmena = {
        meta = {
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
      colmenaHive = colmena.lib.makeHive self.outputs.colmena;
      nixosConfigurations = self.outputs.colmenaHive.nodes;
    };
}

