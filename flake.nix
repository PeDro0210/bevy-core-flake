{
  description = "A nix flake for working with Bevy and Raylib bindings on Rust.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    naersk.url = "github:nix-community/naersk";
  };

  outputs =
    {
      nixpkgs,
      naersk,
      ...
    }:
    # the foldl is for adding each of the packages declarations in to a set
    builtins.foldl' (acc: elem: nixpkgs.lib.recursiveUpdate acc elem) { } (
      builtins.map
        (
          { system, libs }:
          let

            pkgs = nixpkgs.legacyPackages.${system};
            naerskLib = pkgs.callPackages naersk { };

            base_lib =
              with pkgs;
              [
                libGL
                udev
                vulkan-loader
                dbus
                libxkbcommon
                xorg.libXinerama
                xorg.libXcursor
                xorg.libXi
                xorg.libXrandr

              ]
              ++ libs;

            std_bin =
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

            # declaring the build with the naerskLib flake
            packages.${system}.default = naerskLib.buildPackage {
              src = ./.;
              buildInputs = base_lib;
              nativeBuildInputs = std_bin;

              LD_LIBRARY_PATH = base_lib;

              LIBCLANG_PATH = "${pkgs.llvmPackages_15.libclang.lib}/lib";
            };

            templates.default.path = ./.;

          }
        )
        [
          {
            system = "aarch64-darwin";
            libs = [
              # macos doesn't need
            ];
          }
          {
            system = "x86_64-linux";
            libs = with nixpkgs.legacyPackages."x86_64-linux"; [
              alsa-lib
              xorg.libX11
              wayland # To use the wayland feature
            ];
          }
        ]
    );
}
