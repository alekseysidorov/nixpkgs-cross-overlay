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

        pkgsMuslAarch64 = pkgsNative.pkgsCross.aarch64-multiplatform-musl;
      in
      {
        packages = {
          native = pkgsNative.callPackage ./tests/build-all.nix { };
          x86_64-unknown-linux-musl = pkgsMusl64.callPackage ./tests/build-all.nix { };
          x86_64-unknown-linux-musl-static = pkgsMusl64.pkgsStatic.callPackage ./tests/build-all.nix { };
          x86_64-unknown-linux-gnu = pkgsGnu64.callPackage ./tests/build-all.nix { };
          x86_64-unknown-linux-gnu-static = pkgsGnu64.pkgsStatic.callPackage ./tests/build-all.nix { };

          aarch64-unknown-linux-musl = pkgsMuslAarch64.callPackage ./tests/build-all.nix { };
        };

        devShells = {
          native = pkgsNative.callPackage ./examples/shell-rust.nix { };
          x86_64-unknown-linux-musl = pkgsMusl64.callPackage ./examples/shell-rust.nix { };
          x86_64-unknown-linux-musl-static = pkgsMusl64.pkgsStatic.callPackage ./examples/shell-rust.nix { };
          x86_64-unknown-linux-gnu = pkgsGnu64.callPackage ./examples/shell-rust.nix { };

          aarch64-unknown-linux-musl = pkgsMuslAarch64.callPackage ./examples/shell-rust.nix { };
          aarch64-unknown-linux-musl-static = pkgsMuslAarch64.pkgsStatic.callPackage ./examples/shell-rust.nix { };
        };

        overlays = {
          default = crossOverlay;
        };
      }
    );
}
