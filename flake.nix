{
  description = "Rust x86_64-unknown-linux-musl target crossmpilatin utils";

  inputs = {
    nixpkgs.url = "nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }: {
    overlays.default = import ./overlay.nix;
  } // flake-utils.lib.eachDefaultSystem
    (system:
      let
        localPkgs = import nixpkgs { inherit system; };

        patchedPkgs = localPkgs.applyPatches {
          name = "patched-pkgs";
          src = nixpkgs;
          # Pathces gcc to be buildable on M1 mac
          # See https://github.com/NixOS/nixpkgs/issues/137877#issuecomment-1282126233
          patches = [
            ./patches/gcc-darwin-fix.patch
          ];
        };

        crossOverlay = import ./overlay.nix;

        pkgsNative = import nixpkgs {
          inherit system;
          overlays = [ crossOverlay ];
        };

        pkgsMusl64 = import patchedPkgs {
          inherit system;
          overlays = [ crossOverlay ];
          crossSystem = {
            config = "x86_64-unknown-linux-musl";
          };
        };

        pkgsGnu64 = import patchedPkgs {
          inherit system;
          overlays = [ crossOverlay ];
          crossSystem = {
            config = "x86_64-unknown-linux-gnu";
          };
        };

        pkgs-aarch64-multiplatform-musl = import nixpkgs {
          inherit system;
          overlays = [ crossOverlay ];
          crossSystem = {
            config = "aarch64-unknown-linux-musl";
          };
        };
      in
      {
        devShells.default = pkgsMusl64.callPackage ./shell.nix { };
        devShells.gnu = pkgsGnu64.callPackage ./shell.nix { };
        devShells.aarch64 = pkgs-aarch64-multiplatform-musl.callPackage ./shell.nix { };
        devShells.native = pkgsNative.callPackage ./shell.nix { };

        overlays = {
          targets = self: super: {
            pkgsCross.musl64 = pkgsMusl64;
            pkgsCross.gnu64 = pkgsGnu64;
          };
          default = crossOverlay;
        };
      }
    );
}
