# An example of a local cross-compilation without `flakes`.
{ config, isStatic }:

let
  system = builtins.currentSystem;
  crossSystem = { inherit config isStatic; };

  lockFile = import ./../../utils/flake-lock.nix { src = ./.; };

  mkCrossPkgs = (import lockFile.nixpkgs {
    system = builtins.currentSystem;
    overlays = [
      (import lockFile.nixpkgs-cross-overlay)
    ];
  }).mkCrossPkgs;

in
mkCrossPkgs {
  inherit system crossSystem;
  src = lockFile.nixpkgs;
}
