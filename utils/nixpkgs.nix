let
  lockFile = import ./flake-lock.nix { src = ./..; };
in
{ localSystem ? builtins.currentSystem
, crossSystem ? null
, src ? lockFile.nixpkgs
, config ? { }
, overlays ? [ ]
}:
let
  # Import local packages 
  pkgs = import src {
    inherit localSystem config;

    overlays = [
      (import ./..)
    ] ++ overlays;
  };
in
# Make cross system packages.
pkgs.mkCrossPkgs {
  inherit src localSystem crossSystem;
}
