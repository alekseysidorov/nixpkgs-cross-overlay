{
  description = "Nix cross compilation shell example";

  inputs = {
    nixpkgs.url = "nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs-cross-overlay = {
      url = path:./../..;
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils, nixpkgs-cross-overlay }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            nixpkgs-cross-overlay.overlays.${system}.targets
          ];
        };
      in
      {
        devShells.default = with pkgs.pkgsCross.musl64; mkShell {
          nativeBuildInputs = [ rustCrossHook ];
        };

        devShells.gnu64 = with pkgs.pkgsCross.gnu64; mkShell {
          nativeBuildInputs = [ rustCrossHook ];
        };
      }
    );
}
