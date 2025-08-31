{

  # this is mostly just use for dev
  description = "A nix flake for working with Bevy and Raylib ";

  inputs = {
    naersk.url = "github:nix-community/naersk/master";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      utils,
      naersk,
    }:

    utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
        naersk-lib = pkgs.callPackage naersk { };

        libs = with pkgs; [
          libGL
          udev
          alsa-lib # audio for bevy
          vulkan-loader # fuck you vulkan shaders
          xorg.libX11 # To use the x11 feature
          xorg.libXcursor # To use the x11 feature
          xorg.libXi # To use the x11 feature
          xorg.libXrandr # To use the x11 feature
          libxkbcommon
          wayland # To use the wayland feature
          xorg.libXinerama
          dbus
        ];

        packages =
          with pkgs;
          [
            glfw # for multi plataform
            cmake # cause of raylib binding
            clang # cause of raylib binding
            pkg-config # cause of raylib binding
          ]
          ++ libs;

      in
      {
        defaultPackage = naersk-lib.buildPackage {
          src = ./.;
          buildInputs = libs;
          nativeBuildInputs = packages;
        };

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

        defaultTemplate = {
          src = ./.;
        };

      }
    );

}
