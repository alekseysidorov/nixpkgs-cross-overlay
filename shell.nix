# Example Linux musl64 shell
{ pkgs }:

pkgs.mkShell {
  nativeBuildInputs = with pkgs.pkgsBuildHost; [
    pkg-config
    protobuf
    rustPlatform.bindgenHook
    rustup
    git
  ];
  buildInputs = with pkgs; [
    rdkafka
    rocksdb
    libopus
    openssl.dev
  ];

  shellHook = ''
    unset CC; unset CXX; unset LDFLAGS;
    export TARGET_OS=Linux

    echo "Welcome to the 'x86_64-unknown-linux-musl' Rust cross-compilation shell"
  '';

  # Extra flags for Rust
  CARGO_TARGET_X86_64_UNKNOWN_LINUX_MUSL_LINKER = "${pkgs.stdenv.cc.targetPrefix}cc";
  CARGO_BUILD_TARGET = "x86_64-unknown-linux-musl";
  # Fix segfaults in the Rust code, see this issue:
  # https://github.com/rust-lang/rust/issues/93084
  RUSTFLAGS = "-Ctarget-feature=-crt-static";

  HOST_CC = "${pkgs.stdenv.cc.nativePrefix}cc";
  HOST_CXX = "${pkgs.stdenv.cc.nativePrefix}cpp";
  TARGET_CC = "${pkgs.stdenv.cc.targetPrefix}cc";
  TARGET_CXX = "${pkgs.stdenv.cc.targetPrefix}cpp";

  # Env variables for the rocksdb crate
  ROCKSDB_LIB_DIR = "${pkgs.rocksdb}/lib";
  SNAPPY_LIB_DIR = "${pkgs.snappy}/lib";
}
