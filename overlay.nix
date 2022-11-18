self: super:

# Fix 'x86_64-unknown-linux-musl-gcc: error: unrecognized command-line option' error
let fixGccCliOptions = (self: super: {
  #ToDo more precise
  UNAME = ''echo "Linux"'';
  TARGET_OS = "Linux";
});
in
{
  # GCC 11 doesn't work on the darwin-aarch64 platforms
  gcc = self.gcc12;
  lz4 = super.lz4.overrideAttrs fixGccCliOptions;
  # GCC 12 more strict than the old one
  rocksdb = super.rocksdb.overrideAttrs (old: rec {
    NIX_CFLAGS_COMPILE = old.NIX_CFLAGS_COMPILE
      + self.lib.optionalString self.stdenv.cc.isGNU
      " -Wno-error=format-truncation= -Wno-error=maybe-uninitialized";
  });
}
