{
  description = "Rust x86_64-unknown-linux-musl target crossmpilatin utils";

  inputs = {
    nixpkgs.url = "nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }: {
    overlays.default = import ./.;
  } // flake-utils.lib.eachDefaultSystem
    (system:
      let
        crossOverlay = import ./.;
        pkgsNative = import nixpkgs {
          inherit system;
          overlays = [ crossOverlay ];
        };

        pkgsMusl64 = pkgsNative.mkCrossPkgs {
          inherit system;
          src = nixpkgs;
          crossSystem = { config = "x86_64-unknown-linux-musl"; };
        };

        pkgsGnu64 = pkgsNative.mkCrossPkgs {
          inherit system;
          src = nixpkgs;
          crossSystem = { config = "x86_64-unknown-linux-gnu"; };
        };
      in
      {
        devShells.x86_64-unknown-linux-musl = pkgsMusl64.callPackage ./shell.nix { };
        devShells.x86_64-unknown-linux-gnu = pkgsGnu64.callPackage ./shell.nix { };
        devShells.default = pkgsNative.callPackage ./shell.nix { };

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
