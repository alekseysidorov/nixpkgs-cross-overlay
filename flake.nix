{
  description = "Rust cross-compilatilon utils";

  inputs = {
    nixpkgs.url = "nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }: {
    overlays.default = import ./.;
  } // flake-utils.lib.eachDefaultSystem
    (localSystem:
      let
        crossOverlay = import ./.;

        pkgsNative = import nixpkgs {
          inherit localSystem;
          overlays = [ crossOverlay ];
        };
        pkgsMusl64 = pkgsNative.mkCrossPkgs {
          inherit localSystem;
          src = nixpkgs;
          crossSystem = { config = "x86_64-unknown-linux-musl"; };
        };
        pkgsGnu64 = pkgsNative.mkCrossPkgs {
          inherit localSystem;
          src = nixpkgs;
          crossSystem = { config = "x86_64-unknown-linux-gnu"; };
        };
      in
      {
        packages = {
          x86_64-unknown-linux-musl = pkgsMusl64.callPackage ./examples/build-all.nix { };
          x86_64-unknown-linux-musl-static = pkgsMusl64.pkgsStatic.callPackage ./examples/build-all.nix { };
          x86_64-unknown-linux-gnu = pkgsGnu64.callPackage ./examples/build-all.nix { };
          x86_64-unknown-linux-gnu-static = pkgsGnu64.pkgsStatic.callPackage ./examples/build-all.nix { };
        };

        devShells = {
          default = pkgsNative.callPackage ./examples/shell-rust.nix { };
          x86_64-unknown-linux-musl = pkgsMusl64.callPackage ./examples/shell-rust.nix { };
          x86_64-unknown-linux-gnu = pkgsGnu64.callPackage ./examples/shell-rust.nix { };
        };

        overlays = {
          default = crossOverlay;
        };
      }
    );
}
