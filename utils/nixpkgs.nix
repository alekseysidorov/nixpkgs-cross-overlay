# Definition of Nix packages compatible with flakes and traditional workflow.
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
  inherit src localSystem crossSystem;
  # Setup extra overlays.
  overlays = [
    # Setup Rust toolchain via rustup.
    (import lockFile.rust-overlay)
    (final: prev:
      let
        rustToolchain = prev.rust-bin.fromRustupToolchainFile ./../rust-toolchain.toml;
      in
      {
        inherit rustToolchain;
        rustc = rustToolchain;
        cargo = rustToolchain;
        clippy = rustToolchain;
        rustfmt = rustToolchain;
      })
  ] ++ overlays;
}
