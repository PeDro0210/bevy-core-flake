{
  description = "A nix flake for working with Bevy and Raylib ";
  inputs = {
    naersk.url = "github:nix-community/naersk/master";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      nixpkgs,
      utils,
      naersk,
    }@inputs:

    utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
        naersk-lib = pkgs.callPackage naersk { };
      in
      {
        defaultPackage = naersk-lib.buildPackage { src = ./.; };

        devShell =
          with pkgs;
          mkShell {
            buildInputs = [
              cargo
              rustc
              rustfmt
              pre-commit
              rustPackages.clippy
            ];

            RUST_SRC_PATH = rustPlatform.rustLibSrc;
          };

        # creating each package for the crates

        bevyPackages = naersk-lib.buildPackage {
          src = ./nix/bevy.nix;

          specialArgs = { inherit inputs pkgs naersk-lib; };
        };

        rayLibPackages = naersk-lib.buildPackage {
          src = ./nix/raylib.nix;

          specialArgs = { inherit inputs pkgs naersk-lib; };
        };
      }
    );
}
