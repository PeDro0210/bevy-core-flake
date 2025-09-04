# Bevy and Raylib Core flake

A nix flake for developing with Bevy / Raylib (or both) on the Rust programming language.


## How to use it

### Cloning the repo

- Clone the repo:
  ```fish
  git clone https://github.com/PeDro0210/Bevy-and-raylib-core-flake
  ```

### Initializing the template

- Use the 'nix init flake' command
  ```fish
  nix flake init -t github:PeDro0210/bevy_and_raylib_core_flake#default
  ```

- Generate cargo lock file
  ```fish
  nix-shell -p cargo\
  cargo generate-lockfile\
  exit
  ```


