{
  description = "Home-manager";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs, home-manager, ... }:
    let
      system = "x86_64-linux";
      importPkgs =
        system:
        import nixpkgs {
          system = system;
          config = {
            allowUnfree = true;
          };
        };
      pkgs = importPkgs system;
      user="$USER";

    in
    {
      homeConfigurations."${user}"= home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [ ./home.nix ];
         extraSpecialArgs = {
          homeUser = user;
        };
      };
    };
}
