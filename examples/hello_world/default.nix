# An example of a local cross-compilation without `flakes`.
{ ... } @crossSystem:

let
  localSystem = builtins.currentSystem;

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
