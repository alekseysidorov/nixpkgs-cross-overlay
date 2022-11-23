{ pkgs }:

pkgs.stdenv.mkDerivation {
  name = "rust-cross-env";

  shellHook = ''
    unset CC; unset CXX; unset LDFLAGS;
    export TARGET_OS=Linux

    echo "Setting up the `x86_64-unknown-linux-musl` Rust cross-compilation shell"
  '';

  # Extra flags for Rust
  CARGO_TARGET_X86_64_UNKNOWN_LINUX_MUSL_LINKER = "${pkgs.stdenv.cc.targetPrefix}cc";
  CARGO_BUILD_TARGET = "x86_64-unknown-linux-musl";
  # Fix segfaults in the Rust code, see this issue:
  # https://github.com/rust-lang/rust/issues/93084
  RUSTFLAGS = "-Ctarget-feature=-crt-static";
}
