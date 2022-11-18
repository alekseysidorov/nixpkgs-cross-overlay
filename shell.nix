# Example Linux musl64 shell

{ pkgs ? import <nixpkgs> {
    overlays = [
      (import ./overlay.nix)
    ];

    crossSystem = {
      config = "x86_64-unknown-linux-musl";
    };
  }
}:

pkgs.mkShell {
  strictDeps = true;
  nativeBuildInputs = with pkgs; [
    pkgsBuildHost.pkg-config
    pkgsBuildHost.protobuf
  ];
  buildInputs = with pkgs; [
    hello
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
}
