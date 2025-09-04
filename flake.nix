{
  # this is mostly just use for dev
  description = "A nix flake for working with Bevy and Raylib ";

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
    # the foldl is for adding each of the packages declarations in to a set
    builtins.foldl' (acc: elem: nixpkgs.lib.recursiveUpdate acc elem) { } (
      builtins.map
        (
          system:
          let

            pkgs = nixpkgs.legacyPackages.${system};
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

            packages.${system}.default = naerskLib.buildPackage {
              src = ./.;
              buildInputs = libs;
              nativeBuildInputs = packages;

              LD_LIBRARY_PATH = libs;

              LIBCLANG_PATH = "${pkgs.llvmPackages_15.libclang.lib}/lib";
            };

            templates.default.path = ./.;

          }
        )
        [
          "aarch64-darwin"
          "x86_64-linux"
        ]
    );
}
