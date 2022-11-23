{
  description = "Rust x86_64-unknown-linux-musl target crossmpilatin utils";

  inputs = {
    nixpkgs.url = "nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }: flake-utils.lib.eachDefaultSystem
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

        rustShell = pkgsMusl64.callPackage ./shell.nix { };
        rustShellGnu = pkgsGnu64.callPackage ./shell.nix { };
      in
      {
        devShells.default = rustShell;
        devShells.gnu = rustShellGnu;

        overlays.default = self: super: {
          pkgsCross.musl64 = pkgsMusl64;
        };
      }
    );
}
