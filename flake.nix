{
  description = "A nix flake for working with Bevy/Raylib on Rust.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    crane.url = "github:ipetkov/crane";
  };

  outputs =
    {
      nixpkgs,
      crane,
      ...
    }:
    # the foldl is for adding each of the packages declarations in to a set
    builtins.foldl' (acc: elem: nixpkgs.lib.recursiveUpdate acc elem) { } (
      map
        (
          { system, nativeSpecificBuildInputs }:
          let

            pkgs = nixpkgs.legacyPackages.${system};
            craneLib = crane.mkLib pkgs;

            buildInputs =
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
              ++ nativeSpecificBuildInputs;

            nativeBuildInputs =
              with pkgs;
              [
                glfw
                cmake
                clang
                pkg-config
                rustc
              ]
              ++ nativeSpecificBuildInputs;

            packages = with pkgs; [
              rust-analyzer
              taplo
              clippy
              cargo
              rustfmt
            ];

            LD_LIBRARY_PATH = "${pkgs.lib.makeLibraryPath buildInputs}";

          in
          {

            # declaring the build with the naerskLib flake
            packages.${system}.default = craneLib.buildPackage {
              inherit
                nativeBuildInputs
                buildInputs
                LD_LIBRARY_PATH
                packages
                ;
              src = ./.;

              LIBCLANG_PATH = "${pkgs.llvmPackages_15.libclang.lib}/lib";
            };

            templates.default.path = ./.;

          }
        )
        [
          {
            system = "aarch64-darwin";
            nativeSpecificBuildInputs = [
              # macos doesn't need
            ];
          }
          {
            system = "x86_64-linux";
            nativeSpecificBuildInputs = with nixpkgs.legacyPackages."x86_64-linux"; [
              alsa-lib
              xorg.libX11
              wayland # To use the wayland feature
            ];
          }
        ]
    );
}
