{
  description = "Nix cross compilation shell example";

  inputs = {
    nixpkgs.url = "nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    nixpkgs-cross-overlay = {
      url = "github:alekseysidorov/nixpkgs-cross-overlay";
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
            nixpkgs-cross-overlay.overlays.${system}.default
          ];
        };
      in
      {
        devShells = {
          default = with pkgs; mkShell {
            nativeBuildInputs = [ rustCrossHook ];
          };

          x86_64-unknown-linux-musl = with pkgs.pkgsCross.musl64; mkShell {
            nativeBuildInputs = [ rustCrossHook ];
          };

          x86_64-unknown-linux-gnu = with pkgs.pkgsCross.gnu64; mkShell {
            nativeBuildInputs = [ rustCrossHook ];
          };
        };
      }
    );
}
