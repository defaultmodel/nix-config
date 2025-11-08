{ inputs, ... }: {
  deployment = {
    # Allow local deployment with `colmena apply-local`
    allowLocalDeployment = true;
    tags = [ "desktop" "local" ];
  };
  imports = [
    inputs.disko.nixosModules.disko
    inputs.home-manager.nixosModules.home-manager
    # inputs.vpn-confinement.nixosModules.default

    ./configuration.nix
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs; };
    users = { defaultmodel = import ./home.nix; };
  };
}
