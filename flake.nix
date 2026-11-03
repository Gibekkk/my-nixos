{
  description = "Gibekkk's NixOS";

  inputs = {

    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    nix-flatpak = {
      url = "github:gmodena/nix-flatpak";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, nix-flatpak, ... }@inputs:

    let
      system = "x86_64-linux";
    in {

    # Gibekkk - system hostname
    nixosConfigurations.Gibekkk = nixpkgs.lib.nixosSystem {
      specialArgs = {
        pkgs-stable = import nixpkgs-stable {
          inherit system;
        };
        inherit inputs system;
      };
      modules = [
        nix-flatpak.nixosModules.nix-flatpak
        ./nixos/configuration.nix
      ];
    };

    # gibekkk - username
    homeConfigurations.gibekkk = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.${system};
      modules = [ ./home-manager/home.nix ];
    };
  };
}
