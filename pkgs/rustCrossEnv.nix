{ pkgs }:

{
  # Extra flags for Rust
  CARGO_TARGET_X86_64_UNKNOWN_LINUX_MUSL_LINKER = "${pkgs.stdenv.cc.targetPrefix}cc";
  CARGO_BUILD_TARGET = "x86_64-unknown-linux-musl";
  # Fix segfaults in the Rust code, see this issue:
  # https://github.com/rust-lang/rust/issues/93084
  RUSTFLAGS = "-Ctarget-feature=-crt-static";
  # Setup compilers
  HOST_CC = "${pkgs.stdenv.cc.nativePrefix}cc";
  HOST_CXX = "${pkgs.stdenv.cc.nativePrefix}cpp";
  TARGET_CC = "${pkgs.stdenv.cc.targetPrefix}cc";
  TARGET_CXX = "${pkgs.stdenv.cc.targetPrefix}cpp";
}
