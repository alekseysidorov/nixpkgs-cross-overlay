# Definition of Nix packages compatible with flakes and traditional workflow.
let
  lockFile = import ./flake-lock.nix { src = ./..; };
in
{ localSystem ? builtins.currentSystem
, crossSystem ? null
, src ? lockFile.nixpkgs
, config ? { }
, overlays ? [ ]
, useVanilla ? false
}:
let
  # Import local packages.
  pkgs = import src {
    inherit localSystem config;

    overlays = [
      # Setup cross overlay.
      (import ./..)
    ];
  };
in
# Make cross system packages.
pkgs.mkCrossPkgs {
  inherit src localSystem crossSystem useVanilla;
  # Setup extra overlays.
  overlays = [
    (import lockFile.rust-overlay)
  ] ++ overlays;
}
