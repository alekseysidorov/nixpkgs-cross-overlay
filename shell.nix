# Example Linux musl64 shell

{ pkgs ? import <nixpkgs> {
    overlays = [
      (import ./overlay.nix)
    ];

    localSystem = builtins.currentSystem;
    crossSystem = {
      config = "x86_64-unknown-linux-musl";
    };
  }
}:

pkgs.mkShell {
  nativeBuildInputs = with pkgs.pkgsBuildHost; [
    pkg-config
    protobuf
    rustPlatform.bindgenHook
  ];
  buildInputs = with pkgs; [
    rdkafka
    rocksdb
    libopus
    openssl.dev
    zlib
  ];

  # Extra flags for Rust
  CARGO_TARGET_X86_64_UNKNOWN_LINUX_MUSL_LINKER = "${pkgs.stdenv.cc.targetPrefix}cc";
  CARGO_BUILD_TARGET = "x86_64-unknown-linux-musl";
  # Fix segfaults in the Rust code, see this issue:
  # https://github.com/rust-lang/rust/issues/93084
  RUSTFLAGS = "-Ctarget-feature=-crt-static";
  CARGO_INCREMENTAL = "0";

  # Env variables for the rocksdb crate
  ROCKSDB_LIB_DIR = "${pkgs.rocksdb}/lib";
  SNAPPY_LIB_DIR = "${pkgs.snappy}/lib";

  # Unset host compilation flags
  shellHook = ''
    export CFLAGS=""
  '';
}
