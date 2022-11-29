# An example of a local cross-compilation without `flakes`.
{ config, isStatic }:

let
  localSystem = builtins.currentSystem;
  crossSystem = { inherit config isStatic; };

  lockFile = import ./../../utils/flake-lock.nix { src = ./.; };

  mkCrossPkgs = (import lockFile.nixpkgs {
    inherit localSystem;
    overlays = [
      (import lockFile.nixpkgs-cross-overlay)
    ];
  }).mkCrossPkgs;

in
mkCrossPkgs {
  inherit localSystem crossSystem;
  src = lockFile.nixpkgs;
}
