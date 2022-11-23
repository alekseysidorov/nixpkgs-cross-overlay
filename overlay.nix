self: super: {
  # Fix 'x86_64-unknown-linux-musl-gcc: error: unrecognized command-line option' error
  gccCrossCompileWorkaround = (self: super: {
    #ToDo more precise
    UNAME = ''echo "Linux"'';
    TARGET_OS = "Linux";
  });

  lz4 = super.lz4.overrideAttrs self.gccCrossCompileWorkaround;
  # # GCC 12 more strict than the old one
  rocksdb = super.rocksdb.overrideAttrs (old: rec {
    NIX_CFLAGS_COMPILE = old.NIX_CFLAGS_COMPILE
      + super.lib.optionalString super.stdenv.cc.isGNU
      " -Wno-error=format-truncation= -Wno-error=maybe-uninitialized";
  });

  rdkafka = super.callPackage ./pkgs/rdkafka.nix { };
  
  rustCrossHook = super.callPackage ./hooks/rustCrossHook.nix {};
}
