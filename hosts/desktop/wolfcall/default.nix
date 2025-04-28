{ inputs, ... }: {
  deployment = {
    # Allow local deployment with `colmena apply-local`
    allowLocalDeployment = true;

    # Disable SSH deployment. This node will be skipped in a
    # normal`colmena apply`.
    targetHost = null;
    tags = [ "desktop" ];
  };
  imports = [
    inputs.disko.nixosModules.disko
    inputs.home-manager.nixosModules.home-manager

    ../../default.nix # Common config for all hosts
    ../default.nix # Common config for all desktops
    ./disk-config.nix
    ./configuration.nix
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs; };
    users = { defaultmodel = import ./home.nix; };
  };
}
