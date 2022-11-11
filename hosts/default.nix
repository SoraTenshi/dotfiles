inputs@{ nixpkgs, nixos-hardware, nur, hyprland, kmonad, home-manager, ... }:

let
  inherit (nixpkgs.lib) nixosSystem;
  inherit (import ../user) profile;
  hardware = nixos-hardware.nixosModules;
  sharedModules = [
    home-manager.nixosModules.default
    ../system/base.nix
    ../system/network.nix
    ({ pkgs, ... }:
      let
        args = {
          inherit inputs;
          nur = import nur {
            nurpkgs = pkgs;
            inherit pkgs;
          };
        };
      in {
        _module.args = args;
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          sharedModules = [ { _module.args = args; } ../user/base.nix ];
        };
      })
  ];
  desktopModules = [
    hyprland.nixosModules.default
    kmonad.nixosModules.default
    ../system/desktop.nix
    {
      home-manager.sharedModules =
        [ hyprland.homeManagerModules.default ../user/desktop.nix ];
    }
  ];
in {
  tarvos = nixosSystem {
    system = "x86_64-linux";
    modules = sharedModules ++ desktopModules ++ [
      hardware.lenovo-thinkpad-t490
      ./tarvos
      (profile "kevin" "full" "21.05")
      (profile "root" "minimal" "21.05")
    ];
  };
}
