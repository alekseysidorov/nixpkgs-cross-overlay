self: super:
let
  lib = super.lib;
  stdenv = super.stdenv;

  targetIsLinux = stdenv.targetPlatform.isLinux;
  isCross = stdenv.hostPlatform != stdenv.buildPlatform;

  # Fix 'x86_64-unknown-linux-musl-gcc: error: unrecognized command-line option' error
  gccCrossCompileWorkaround = (self: super: {
    #ToDo more precise
    UNAME = ''echo "Linux"'';
    TARGET_OS = "Linux";
  });
in
{
  inherit gccCrossCompileWorkaround;
  mkEnvHook = super.callPackage ./hooks/mkEnvHook.nix { };
  rustCrossHook = null;
  # Rust crates system deps
  cargoDeps = {
    rust-rocksdb-sys = super.callPackage ./pkgs/rust-rocksdb-sys.nix { };
  };
} // lib.optionalAttrs isCross {
  # Cross-compilation specific patches

  rustCrossHook = super.callPackage ./hooks/rustCrossHook.nix { };

  lz4 = super.lz4.overrideAttrs self.gccCrossCompileWorkaround;
  rdkafka = super.callPackage ./pkgs/rdkafka.nix { };
  # GCC 12 more strict than the old one
  rocksdb = super.rocksdb.overrideAttrs (old: rec {
    NIX_CFLAGS_COMPILE = old.NIX_CFLAGS_COMPILE
    + super.lib.optionalString super.stdenv.cc.isGNU
      " -Wno-error=format-truncation= -Wno-error=maybe-uninitialized";
  });
}
