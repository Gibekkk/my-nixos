{
  description = "Gibekkk's NixOS";

  inputs = {

    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    nur ={
     url = "https://github.com/nix-community/NUR/archive/refs/heads/main.tar.gz";
     inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    nix-flatpak = {
      url = "github:gmodena/nix-flatpak";
    };

    zapfast = {
      url = "github:crmne/zapfast";
    };

    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
    };

    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
};

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, nix-flatpak, disko, nur, ... }@inputs:

    let
      system = "x86_64-linux";
      homeManagerConfig = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.${system};
      extraSpecialArgs = {
        pkgs-unstable = import nixpkgs-unstable {
            inherit system;
            config.allowUnfree = true;
        };
        inherit inputs system;
      };
      modules = [
      inputs.plasma-manager.homeModules.plasma-manager
      nix-flatpak.homeManagerModules.nix-flatpak
      ./home-manager/home.nix
      nur.modules.homeManager.default
      ];
    };
    in {

    # Gibekkk - system hostname
    nixosConfigurations.Gibekkk = nixpkgs.lib.nixosSystem {
      specialArgs = {
        pkgs-unstable = import nixpkgs-unstable {
          inherit system;
          config.allowUnfree = true;
        };
        inherit inputs system;
      };
      modules = [
        nix-flatpak.nixosModules.nix-flatpak
        ./nixos/configuration.nix
        nur.modules.nixos.default
      ];
    };

    # gibekkk - username
    homeConfigurations.gibekkk = homeManagerConfig;

    # gibets - username
    homeConfigurations.gibets = homeManagerConfig;
  };
}
