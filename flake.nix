{
  description = "Hantro H1 video encoder driver for Parrot P7";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils
  }: flake-utils.lib.eachSystem
    (flake-utils.lib.defaultSystems ++ [ "armv7l-linux" ])
  (system: let
    lib = nixpkgs.lib;
    pkgs = import nixpkgs {
      inherit system;
      crossSystem = if system != "armv7l-linux" then {
        config = "armv7l-unknown-linux-musleabihf";
        isStatic = true;
      } else null;
    };
  in {
    packages.default = pkgs.callPackage ./default.nix { };
    devShells.default = pkgs.callPackage ./default.nix { dev = true; };
  }) // {
    overlays.default = final: prev: {
      h1enc-parrot-p7 = final.callPackage ./default.nix { };
    };
  };
}
