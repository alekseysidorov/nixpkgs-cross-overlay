{
  description = "Rust cross-compilatilon utils";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };
  };

  outputs = { flake-utils, rust-overlay, ... }:
    {
      overlays =
        let
          nixpkgs-cross-overlay = import ./.;
          rust-overlay' = import rust-overlay.overlays.default;
        in
        {
          inherit nixpkgs-cross-overlay;
          rust-overlay = rust-overlay';
          # Export as a flake overlay including all dependent overlays.
          default = final: prev:
            (rust-overlay' final prev)
            // (nixpkgs-cross-overlay final prev);
        };
    } // flake-utils.lib.eachDefaultSystem
      (localSystem:
        {
          devShells = {
            default = import ./shell.nix { inherit localSystem; };
            cross = import ./shell.nix {
              inherit localSystem;
              crossSystem = { config = "x86_64-unknown-linux-musl"; useLLVM = true; };
            };
          };
        }
      );
}
