# A standalone nix shell file to setup Rust cross-compilation toolchain.
#
# This file does not have any additional dependencies and is completely self-sufficient.
# You can use the `nix-shell` command and get the working cross-compilation toolchain.
# By default, it produces completely static binaries, which can be placed into the 
# Alpine Linux container as is.
# 
# # Usage:
#
# `nix-shell ./shell-rust-cross.nix`
#
# # Tips:
#
# - You can attach a binary cache by running the command `nix-shell -p cachix --run "cachix use nixpkgs-cross-overlay"`
# - If you have compilation issues, try to add `--pure` argument to the `nix-shell`.
{ localSystem ? builtins.currentSystem
  # Default cross-compilation configuration, you may override it by passing the 
  # `--arg crossSystem '<our-own-config>'` to `nix-shell`.
, crossSystem ? { config = "x86_64-unknown-linux-musl"; isStatic = true; useLLVM = true; }
  # Override nixpkgs-cross-overlay branch.
, branch ? "main"
}:
let
  # Fetch the nixpkgs-cross-overlay sources.
  src = builtins.fetchTarball "http://github.com/alekseysidorov/nixpkgs-cross-overlay/tarball/${branch}";
  # Use the nixpkgs revision provided by the overlay. 
  # This is the best way, as they are the most proven and compatible.
  nixpkgs = "${src}/utils/nixpkgs.nix";
  # Make cross system packages.
  pkgs = import nixpkgs {
    inherit localSystem crossSystem;
    overlays = [
      # Overlay also provides the `rust-overlay`, so it is easy to override the default Rust toolchain setup.
      (final: prev: rec {
        rustToolchain = prev.rust-bin.stable.latest.default;
        rustc = rustToolchain;
        cargo = rustToolchain;
        clippy = rustToolchain;
        rustfmt = rustToolchain;
      })
      # <- You may add your extra overlays here.
    ];
  };
in
# And now, with the resulting packages, we can describe the cross-compilation shell.
pkgs.mkShell {
  # Native project dependencies like build utilities and additional routines 
  # like container building, linters, etc.
  nativeBuildInputs = with pkgs.pkgsBuildHost; [
    pkg-config
    git
    cmake
    perl

    # Uncomment this line if you want to use the Rust toolchain provided by this shell.
    rustToolchain

    # Will add some dependencies like libiconv.
    rustBuildHostDependencies
  ];
  # Libraries essential to build the service binaries.
  buildInputs = with pkgs; [
    # Enable cross-compilation mode in Rust.
    rustCrossHook
    # Add crate dependencies.
    cargoDeps.rocksdb-sys
    cargoDeps.rdkafka-sys
    # Some native libraries.
    openssl.dev
  ];
  # Prettify shell prompt.
  shellHook = "${pkgs.crossBashPrompt}";
}
