final: prev:
let
  lib = prev.lib;
  stdenv = prev.stdenv;
  isStatic = stdenv.hostPlatform.isStatic;
  isCross = stdenv.hostPlatform != stdenv.buildPlatform;
  # Disable checks
  disableChecks = (old: {
    doCheck = false;
  });
in
{
  # Useful utilites
  ldproxy = prev.callPackage ./utils/ldproxy.nix { };
  # Metapackage with all crates dependencies.
  cargoDeps = (import ./crates prev);
  # Link libc++ libraries together just like it's done in the Android NDK.
  libcxx-full-static = prev.callPackage ./libcxx_static { };
  # Use llvm_unwind as libgcc_s replacement on the LLVM targets.
  llvm-gcc_s-compat = prev.runCommand
    "llvm-gcc_s-compat"
    {
      propagatedBuildInputs = [
        final.llvmPackages.libunwind
      ];
    }
    ''
      mkdir -p $out/lib
      libdir=${final.llvmPackages.libunwind}/lib
      for dylibtype in so dylib a dll; do
        if [ -e "$libdir/libunwind.$dylibtype" ]; then
          ln -svf $libdir/libunwind.$dylibtype $out/lib/libgcc_s.$dylibtype
        fi
      done
    '';
  # Use libcxx as libstdc++ replacement on the LLVM targets.
  # It can fix some crates like Rocksdb that relies that there is only `libstdc++`
  # on Linux systems.
  libcxx-gcc-compat =
    let
      compat-dynamic = final.runCommand
        "libcxx-gcc-compat-dynamic"
        {
          propagatedBuildInputs = [
            final.llvmPackages.libcxx
          ];
        }
        ''
          mkdir -p $out/lib
          libdir=${final.llvmPackages.libcxx}/lib
          for dylibtype in so dylib a dll; do
            if [ -e "$libdir/libc++.$dylibtype" ]; then
              ln -svf $libdir/libc++.$dylibtype $out/lib/libstdc++.$dylibtype
            fi
          done
        '';

      compat-static = final.runCommand
        "libcxx-gcc-compat-static"
        {
          propagatedBuildInputs = [
            final.libcxx-full-static
          ];
        }
        ''
          mkdir -p $out/lib
          libdir=${final.libcxx-full-static}/lib
          ln -svf $libdir/libc++_static.a $out/lib/libstdc++.a
        '';

    in
    if isStatic then compat-static else compat-dynamic;

  # Cmake-built Kafka works better than the origin one.
  rdkafka = prev.rdkafka.overrideAttrs (now: old: {
    nativeBuildInputs = old.nativeBuildInputs ++ [ prev.pkgsBuildHost.cmake ];
    buildInputs = old.buildInputs ++ [ final.lz4 final.openssl.dev ];
    cmakeFlags = [
      "-DRDKAFKA_BUILD_TESTS=0"
      "-DRDKAFKA_BUILD_EXAMPLES=0"
    ] ++ lib.optional isStatic "-DRDKAFKA_BUILD_STATIC=1";
  });
  # Uncomment this line if rdkafka sys again breaks compatibility with the shipped by Nix version.
  # rdkafka = prev.callPackage ./rdkafka.nix { };


} # Special case for the Darwin platform
// lib.optionalAttrs stdenv.isDarwin {
  # Openldap checks are broken on the Darwin platform.
  openldap = prev.openldap.overrideAttrs disableChecks;
  # New version of the fakeroot package are broken on the Darwin platform.
  fakeroot = prev.callPackage ./fakeroot.nix { };
}
  # Special case for the cross-compilation.
  // lib.optionalAttrs isCross {
  libuv = prev.libuv.overrideAttrs disableChecks;
  gmp = prev.gmp.overrideAttrs disableChecks;
  zlib = prev.zlib.overrideAttrs disableChecks;
  gnugrep = prev.gnugrep.overrideAttrs disableChecks;
  # Disable liburing in rockrocksdb, because it cannot be cross compiled.
  #
  # There is no way to just override rocksdb attributes. So we have to fork it.
  rocksdb = prev.callPackage ./rocksdb.nix { };
  # Fix compilation by overriding the packages attributes.
  libopus = prev.libopus.overrideAttrs disableChecks;
}
