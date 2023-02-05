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
  # Override nixpkgs source.
, channel ? "channel:nixpkgs-unstable"
}:
let
  # Fetch the latest nixpkgs snapshot.
  src = builtins.fetchTarball channel;
  # Setup local Nix packages to get the `mkCrossPkgs` function.
  localPkgs = (import src {
    config = {
      inherit localSystem;
    };
    overlays = [
      # Fetch the latest nixpkgs-cross-overlay snapshot.
      (import
        (builtins.fetchTarball "http://github.com/alekseysidorov/nixpkgs-cross-overlay/tarball/${branch}")
      )
    ];
  });
  # Make cross system packages.
  pkgs = localPkgs.mkCrossPkgs {
    inherit src localSystem crossSystem;

    overlays = [
      # Fetch the latest rust-overlay snapshot.
      (import
        (builtins.fetchTarball "http://github.com/oxalica/rust-overlay/tarball/master")
      )
      # Setup Rust toolchain.
      (final: prev:
        {
          rustToolchain = prev.rust-bin.stable.latest.default;
        }
      )
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
    # rustToolchain

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
