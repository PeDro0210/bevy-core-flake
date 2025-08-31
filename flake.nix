{

  description = "Slash Maze flake nix";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    naersk.url = "github:nix-community/naersk";
  };

  outputs =
    {
      self,
      nixpkgs,
      naersk,
    }:
    let
      pkgs = nixpkgs.legacyPackages."x86_64-linux";
      naerskLib = pkgs.callPackages naersk { };

      libs = with pkgs; [
        libGL
        udev
        alsa-lib
        vulkan-loader
        xorg.libX11
        xorg.libXcursor
        xorg.libXi
        xorg.libXrandr # To use the x11 feature
        libxkbcommon
        wayland # To use the wayland feature
        xorg.libXinerama
        dbus
      ];

      packages =
        with pkgs;
        [
          glfw
          cmake
          clang
          pkg-config
          cargo
          rustc
          rust-analyzer
          clippy
          rustfmt
        ]
        ++ libs;

    in
    {

      packages."x86_64-linux".default = naerskLib.buildPackage {
        src = ./.;
        buildInputs = libs;
        nativeBuildInputs = packages;

        LD_LIBRARY_PATH = libs;

        LIBCLANG_PATH = "${pkgs.llvmPackages_15.libclang.lib}/lib";
      };

      templates.default.path = ./.;
    };
}
